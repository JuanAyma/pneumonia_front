import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/base/components/button/base_button.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/core/models/diagnosis_model.dart';
import 'package:lungs_pneumonia_ai/core/network/api_service.dart';
import 'package:lungs_pneumonia_ai/view/doctor/controller/doctor_controller.dart';
import 'package:lungs_pneumonia_ai/view/doctor/controller/doctor_process_controller.dart';
import 'package:lungs_pneumonia_ai/view/doctor/view/doctor_bottom_nav.dart';
import 'package:lungs_pneumonia_ai/view/home/view/widget/title_with_description_widget.dart';
import 'package:lungs_pneumonia_ai/view/specialization/widget/specialization_badge_widget.dart';

class DoctorResultView extends GetView<DoctorProcessController> {
  const DoctorResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final noteCtrl = TextEditingController();
    final prescriptionCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors().backgroundColor,
      body: GetBuilder<DoctorProcessController>(
        builder: (processCtrl) {
          final hasPneumonia = processCtrl.output.isNotEmpty &&
              processCtrl.output[0]['index'] == 1;
          final confidence = processCtrl.output.isNotEmpty
              ? (processCtrl.output[0]['confidence'] as double)
              : 0.0;
          final doctorCtrl = DoctorController.instance;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: Utility(context).dynamicWidthPixel(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleWithDescription(
                  title: 'scanResult',
                  description: 'scanResultDescription',
                  isBackButtonActive: true,
                ),
                SizedBox(height: Utility(context).dynamicWidthPixel(20)),

                // X-ray image
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    Utility(context).dynamicWidthPixel(14),
                  ),
                  child: Image.file(
                    io.File(processCtrl.xFileImage!.path),
                    width: Utility(context).dynamicWidth(1),
                    height: Utility(context).dynamicWidthPixel(200),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: Utility(context).dynamicWidth(1),
                      height: Utility(context).dynamicWidthPixel(200),
                      color: Colors.grey.withOpacity(0.1),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_outlined,
                              color: Colors.grey, size: 40),
                          SizedBox(height: 8),
                          Text('No se pudo cargar la imagen',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Utility(context).dynamicWidthPixel(16)),

                // Grad-CAM heatmap
                if (processCtrl.usedBackend) ...[
                  processCtrl.gradCamUrl != null
                      ? _gradCamCard(context, processCtrl.gradCamUrl!)
                      : _gradCamUnavailableCard(context),
                  SizedBox(height: Utility(context).dynamicWidthPixel(16)),
                ],

                // AI result
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(
                    Utility(context).dynamicWidthPixel(16),
                  ),
                  decoration: BoxDecoration(
                    color: hasPneumonia
                        ? AppColors().red.withOpacity(0.1)
                        : AppColors().green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      Utility(context).dynamicWidthPixel(14),
                    ),
                    border: Border.all(
                      color: hasPneumonia
                          ? AppColors().red.withOpacity(0.3)
                          : AppColors().green.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        hasPneumonia
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline,
                        color: hasPneumonia
                            ? AppColors().red
                            : AppColors().green,
                        size: Utility(context).dynamicTextSize(36),
                      ),
                      SizedBox(
                          height: Utility(context).dynamicWidthPixel(8)),
                      Text(
                        hasPneumonia ? 'pneumonia'.tr : 'healthy'.tr,
                        style: Utility(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              color: hasPneumonia
                                  ? AppColors().red
                                  : AppColors().green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(
                          height: Utility(context).dynamicWidthPixel(6)),
                      Text(
                        '${'confidence'.tr}${(confidence * 100).toStringAsFixed(1)}%',
                        style: Utility(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors().grey1),
                      ),
                      SizedBox(height: Utility(context).dynamicWidthPixel(8)),
                      _sourceChip(context, processCtrl.usedBackend),
                    ],
                  ),
                ),

                // Risk level + urgency (backend only)
                if (processCtrl.riskLevel != null) ...[
                  SizedBox(height: Utility(context).dynamicWidthPixel(12)),
                  _riskBadge(context, processCtrl.riskLevel!,
                      processCtrl.urgencyHours),
                ],

                SizedBox(height: Utility(context).dynamicWidthPixel(16)),

                // Specialization + patient info
                if (doctorCtrl.selectedSpecialization != null)
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: Utility(context).dynamicWidthPixel(8)),
                    child: SpecializationBadgeWidget(
                      specializationId:
                          doctorCtrl.selectedSpecialization!.id,
                    ),
                  ),
                if (doctorCtrl.selectedPatient != null)
                  _infoCard(
                    context,
                    Icons.person_outline,
                    '${'patient'.tr}: ${doctorCtrl.selectedPatient!.name}',
                  ),

                // Findings
                if (processCtrl.findings.isNotEmpty) ...[
                  SizedBox(height: Utility(context).dynamicWidthPixel(12)),
                  _listSection(context, 'findings'.tr,
                      Icons.search, processCtrl.findings),
                ],

                // Recommended actions
                if (processCtrl.recommendedActions.isNotEmpty) ...[
                  SizedBox(height: Utility(context).dynamicWidthPixel(12)),
                  _listSection(context, 'recommendedActions'.tr,
                      Icons.medical_services_outlined,
                      processCtrl.recommendedActions),
                ],

                SizedBox(height: Utility(context).dynamicWidthPixel(16)),

                // Doctor notes
                _textField(
                  context,
                  noteCtrl,
                  'doctorNotes'.tr,
                  Icons.note_outlined,
                  maxLines: 3,
                ),
                SizedBox(height: Utility(context).dynamicWidthPixel(12)),

                // Prescription (only if pneumonia detected)
                if (hasPneumonia)
                  _textField(
                    context,
                    prescriptionCtrl,
                    'prescription'.tr,
                    Icons.medication_outlined,
                    maxLines: 3,
                  ),

                SizedBox(height: Utility(context).dynamicWidthPixel(24)),

                // Action buttons
                BaseButton(
                  buttonText: 'approve'.tr,
                  backgroundColor: AppColors().green,
                  onPressed: () {
                    _saveAndNavigate(
                      context,
                      processCtrl,
                      doctorCtrl,
                      DiagnosisStatus.approved,
                      hasPneumonia,
                      confidence,
                      noteCtrl.text,
                      prescriptionCtrl.text,
                    );
                  },
                ),
                SizedBox(height: Utility(context).dynamicWidthPixel(12)),
                BaseButton(
                  buttonText: 'reject'.tr,
                  borderColor: AppColors().red,
                  backgroundColor: Colors.transparent,
                  buttonTextColor: AppColors().red,
                  onPressed: () {
                    _saveAndNavigate(
                      context,
                      processCtrl,
                      doctorCtrl,
                      DiagnosisStatus.rejected,
                      hasPneumonia,
                      confidence,
                      noteCtrl.text,
                      null,
                    );
                  },
                ),
                SizedBox(height: Utility(context).dynamicWidthPixel(30)),
              ],
            ),
          );
        },
      ),
    );
  }

  void _saveAndNavigate(
    BuildContext context,
    DoctorProcessController processCtrl,
    DoctorController doctorCtrl,
    DiagnosisStatus status,
    bool hasPneumonia,
    double confidence,
    String? note,
    String? prescription,
  ) {
    if (doctorCtrl.selectedPatient == null) return;

    final diagnosis = DiagnosisModel(
      id: processCtrl.backendDiagnosisId ??
          'diag_${DateTime.now().millisecondsSinceEpoch}',
      patientId: doctorCtrl.selectedPatient!.id,
      imagePath: processCtrl.xFileImage!.path,
      hasPneumonia: hasPneumonia,
      confidence: confidence,
      date: DateTime.now(),
      specializationId:
          doctorCtrl.selectedSpecialization?.id ?? 'pulmonology',
      status: status,
      doctorNote: note?.isEmpty == true ? null : note,
      prescription: prescription?.isEmpty == true ? null : prescription,
    );

    doctorCtrl.addDiagnosis(doctorCtrl.selectedPatient!.id, diagnosis);

    // Sync validation to backend (fire and forget — UI doesn't wait)
    if (processCtrl.backendDiagnosisId != null) {
      ApiService.validateDiagnosis(
        processCtrl.backendDiagnosisId!,
        status == DiagnosisStatus.approved ? 'APPROVED' : 'REJECTED',
        doctorNote: note,
        prescription: prescription,
      ).catchError((_) {});
    }

    Get.off(() => const DoctorBottomNavView());
    Get.snackbar(
      'scanResult'.tr,
      status == DiagnosisStatus.approved
          ? 'diagnosisApproved'.tr
          : 'diagnosisRejected'.tr,
      backgroundColor: status == DiagnosisStatus.approved
          ? AppColors().green.withOpacity(0.9)
          : AppColors().red.withOpacity(0.9),
      colorText: AppColors().white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Widget _gradCamCard(BuildContext context, String url) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors().white,
        borderRadius:
            BorderRadius.circular(Utility(context).dynamicWidthPixel(14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              Utility(context).dynamicWidthPixel(14),
              Utility(context).dynamicWidthPixel(12),
              Utility(context).dynamicWidthPixel(14),
              Utility(context).dynamicWidthPixel(6),
            ),
            child: Row(
              children: [
                Icon(Icons.blur_on,
                    color: AppColors().mainBlueColor, size: 18),
                SizedBox(width: Utility(context).dynamicWidthPixel(8)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'gradCamTitle'.tr,
                        style: Utility(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors().mainBlueColor,
                            ),
                      ),
                      Text(
                        'gradCamDesc'.tr,
                        style: Utility(context).textTheme.bodySmall?.copyWith(
                              color: AppColors().grey1,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(
                  Utility(context).dynamicWidthPixel(14)),
              bottomRight: Radius.circular(
                  Utility(context).dynamicWidthPixel(14)),
            ),
            child: Image.network(
              url,
              width: double.infinity,
              fit: BoxFit.fitWidth,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return SizedBox(
                  height: Utility(context).dynamicWidthPixel(200),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                      color: AppColors().mainBlueColor,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => SizedBox(
                height: Utility(context).dynamicWidthPixel(80),
                child: Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      color: AppColors().grey1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradCamUnavailableCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Utility(context).dynamicWidthPixel(16)),
      decoration: BoxDecoration(
        color: AppColors().white,
        borderRadius:
            BorderRadius.circular(Utility(context).dynamicWidthPixel(14)),
      ),
      child: Row(
        children: [
          Icon(Icons.blur_on, color: AppColors().grey1, size: 18),
          SizedBox(width: Utility(context).dynamicWidthPixel(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'gradCamTitle'.tr,
                  style: Utility(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors().grey1,
                      ),
                ),
                Text(
                  'Mapa de calor no disponible para este diagnóstico',
                  style: Utility(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors().grey1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context, IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Utility(context).dynamicWidthPixel(14)),
      decoration: BoxDecoration(
        color: AppColors().white,
        borderRadius:
            BorderRadius.circular(Utility(context).dynamicWidthPixel(12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors().mainBlueColor, size: 20),
          SizedBox(width: Utility(context).dynamicWidthPixel(10)),
          Expanded(
            child: Text(text,
                style: Utility(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _sourceChip(BuildContext context, bool usedBackend) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Utility(context).dynamicWidthPixel(10),
        vertical: Utility(context).dynamicWidthPixel(4),
      ),
      decoration: BoxDecoration(
        color: usedBackend
            ? AppColors().mainBlueColor.withOpacity(0.1)
            : AppColors().grey1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            usedBackend ? Icons.cloud_done_outlined : Icons.phone_android,
            size: 13,
            color: usedBackend ? AppColors().mainBlueColor : AppColors().grey1,
          ),
          SizedBox(width: Utility(context).dynamicWidthPixel(4)),
          Text(
            usedBackend ? 'Servidor IA' : 'Modelo local',
            style: Utility(context).textTheme.bodySmall?.copyWith(
                  color: usedBackend
                      ? AppColors().mainBlueColor
                      : AppColors().grey1,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }

  Color _riskColor(String risk) {
    switch (risk) {
      case 'CRITICAL': return AppColors().red;
      case 'HIGH':     return Colors.orange;
      case 'MODERATE': return Colors.amber.shade700;
      default:         return AppColors().green;
    }
  }

  String _riskLabel(String risk) {
    switch (risk) {
      case 'CRITICAL': return 'riskCritical'.tr;
      case 'HIGH':     return 'riskHigh'.tr;
      case 'MODERATE': return 'riskModerate'.tr;
      default:         return 'riskLow'.tr;
    }
  }

  Widget _riskBadge(BuildContext context, String risk, int? urgencyHours) {
    final color = _riskColor(risk);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Utility(context).dynamicWidthPixel(16),
        vertical: Utility(context).dynamicWidthPixel(12),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius:
            BorderRadius.circular(Utility(context).dynamicWidthPixel(12)),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.flag_outlined, color: color, size: 20),
          SizedBox(width: Utility(context).dynamicWidthPixel(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'riskLevel'.tr}${_riskLabel(risk)}',
                  style: Utility(context).textTheme.bodyMedium?.copyWith(
                        color: color, fontWeight: FontWeight.bold),
                ),
                if (urgencyHours != null)
                  Text(
                    '${'urgencyIn'.tr}$urgencyHours${'urgencyHoursSuffix'.tr}',
                    style: Utility(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: color.withOpacity(0.8)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _listSection(
      BuildContext context, String title, IconData icon, List<String> items) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Utility(context).dynamicWidthPixel(14)),
      decoration: BoxDecoration(
        color: AppColors().white,
        borderRadius:
            BorderRadius.circular(Utility(context).dynamicWidthPixel(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppColors().mainBlueColor, size: 18),
            SizedBox(width: Utility(context).dynamicWidthPixel(8)),
            Text(title,
                style: Utility(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors().mainBlueColor,
                    )),
          ]),
          SizedBox(height: Utility(context).dynamicWidthPixel(8)),
          ...items.map((item) => Padding(
                padding: EdgeInsets.only(
                    bottom: Utility(context).dynamicWidthPixel(4)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: Utility(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors().mainBlueColor)),
                    Expanded(
                      child: Text(item,
                          style: Utility(context).textTheme.bodySmall),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _textField(
    BuildContext context,
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors().white,
        borderRadius:
            BorderRadius.circular(Utility(context).dynamicWidthPixel(14)),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: Utility(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors().grey1),
          prefixIcon: Icon(icon, color: AppColors().grey1),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(
            Utility(context).dynamicWidthPixel(14),
          ),
        ),
      ),
    );
  }
}
