import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lungs_pneumonia_ai/core/network/api_service.dart';
import 'package:lungs_pneumonia_ai/view/doctor/controller/doctor_controller.dart';
import 'package:lungs_pneumonia_ai/view/doctor/view/doctor_result_view.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class DoctorProcessController extends GetxController {
  XFile? xFileImage;
  String? result;
  List<dynamic> output = [];
  bool isLoading = true;
  String statusLabel = '';
  String? backendDiagnosisId;

  bool usedBackend = false;
  bool _cancelled = false;

  @override
  void onClose() {
    _cancelled = true;
    super.onClose();
  }

  // Backend result extras
  String? riskLevel;
  int? urgencyHours;
  String? gradCamUrl;
  List<String> findings = [];
  List<String> recommendedActions = [];

  @override
  Future<void> onInit() async {
    final doctorCtrl = DoctorController.instance;
    xFileImage = doctorCtrl.xFileImage;
    await _submitToBackend();
    super.onInit();
  }

  Future<void> _submitToBackend() async {
    final doctorCtrl = DoctorController.instance;
    if (!ApiService.useBackend || doctorCtrl.selectedPatient == null || xFileImage == null) {
      await _runLocalFallback();
      return;
    }

    try {
      statusLabel = 'statusSending'.tr;
      update();

      final response = await ApiService.createDiagnosis(
        patientId: doctorCtrl.selectedPatient!.id,
        specializationId:
            doctorCtrl.selectedSpecialization?.id ?? 'pulmonology',
        imageSource: 'DOCTOR_UPLOAD',
        symptoms: {},
        imagePath: xFileImage!.path,
      );

      backendDiagnosisId = response['id'] as String;
      await _pollUntilReady(backendDiagnosisId!);
    } on DioException catch (e) {
      print('[BACKEND] DioException: ${e.type} ${e.message} ${e.response?.statusCode}');
      await _runLocalFallback();
    } catch (e) {
      print('[BACKEND] Error: $e');
      await _runLocalFallback();
    }
  }

  Future<void> _pollUntilReady(String diagnosisId) async {
    const terminalStatuses = {
      'PENDING_REVIEW', 'REJECTED', 'APPROVED', 'COMPLETED'
    };
    const maxAttempts = 60;

    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(const Duration(seconds: 2));
      if (_cancelled) return;
      try {
        final data = await ApiService.getDiagnosis(diagnosisId);
        if (_cancelled) return;
        final status = (data['status'] as String?) ?? '';
        statusLabel = _labelFor(status);
        update();

        if (terminalStatuses.contains(status)) {
          _populateOutput(data);
          _navigateToResult();
          return;
        }
      } catch (_) {}
    }
    if (!_cancelled) _navigateToResult();
  }

  void _populateOutput(Map<String, dynamic> data) {
    final res = data['result'] as Map<String, dynamic>?;
    final hasPneumonia = (res?['hasPneumonia'] as bool?) ?? false;
    final confidence = ((res?['confidence']) ?? 0.0).toDouble();

    riskLevel = res?['riskLevel'] as String?;
    urgencyHours = res?['urgencyHours'] as int?;

    final rawGradCam = res?['gradCamUrl'] as String?;
    if (rawGradCam != null && rawGradCam.isNotEmpty) {
      final base = ApiService.baseUrl.replaceAll('/v1', '');
      gradCamUrl = '$base$rawGradCam';
    }

    final rawFindings = res?['findings'] as List?;
    findings = rawFindings
            ?.map((f) => f is Map
                ? (f['description'] as String? ?? f.toString())
                : f.toString())
            .toList() ??
        [];

    final rawActions = res?['recommendedActions'] as List?;
    recommendedActions =
        rawActions?.map((a) => a.toString()).toList() ?? [];

    output = [
      {
        'index': hasPneumonia ? 1 : 0,
        'label': hasPneumonia ? 'PNEUMONIA' : 'NORMAL',
        'confidence': confidence,
      }
    ];
    usedBackend = true;
    isLoading = false;
    update();
  }

  // ── TFLite fallback ──────────────────────────────────────────────────────

  Future<void> _runLocalFallback() async {
    await loadModel();
    await classifyImage();
    _navigateToResult();
  }

  Future<void> loadModel() async {
    final spec = DoctorController.instance.selectedSpecialization;
    result = await Tflite.loadModel(
      model: spec?.modelPath ?? 'assets/tflite/resnet50_etapa2_rsna.tflite',
      labels: spec?.labelsPath ?? 'assets/tflite/labels.txt',
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
    update();
  }

  Future<void> classifyImage() async {
    final tfLiteOutput = await Tflite.runModelOnImage(
      path: xFileImage!.path,
      numResults: 2,
      threshold: 0.1,
      imageMean: 0,
      imageStd: 255,
    );
    output = tfLiteOutput ?? [];
    isLoading = false;
    update();
  }

  String _labelFor(String status) {
    switch (status) {
      case 'QUALITY_CHECK': return 'statusQualityCheck'.tr;
      case 'ANALYZING':     return 'statusAnalyzing'.tr;
      case 'CORRELATING':   return 'statusCorrelating'.tr;
      default:              return 'statusProcessing'.tr;
    }
  }

  void _navigateToResult() {
    if (_cancelled) return;
    isLoading = false;
    update();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!_cancelled) Get.off(() => const DoctorResultView());
    });
  }
}
