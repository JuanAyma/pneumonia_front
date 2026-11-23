import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/base/components/button/base_button.dart';
import 'package:lungs_pneumonia_ai/core/base/components/image/full_screen_image_view.dart';
import 'package:lungs_pneumonia_ai/core/base/components/image/xray_image_widget.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/core/models/diagnosis_model.dart';
import 'package:lungs_pneumonia_ai/core/network/api_service.dart';
import 'package:lungs_pneumonia_ai/view/doctor/controller/doctor_controller.dart';
import 'package:lungs_pneumonia_ai/view/home/view/widget/title_with_description_widget.dart';
import 'package:lungs_pneumonia_ai/view/specialization/widget/specialization_badge_widget.dart';

class DoctorValidatePendingView extends StatefulWidget {
  final DiagnosisModel diagnosis;
  const DoctorValidatePendingView({super.key, required this.diagnosis});

  @override
  State<DoctorValidatePendingView> createState() =>
      _DoctorValidatePendingViewState();
}

class _DoctorValidatePendingViewState
    extends State<DoctorValidatePendingView> {
  late final TextEditingController _noteCtrl;
  late final TextEditingController _prescriptionCtrl;

  @override
  void initState() {
    super.initState();
    _noteCtrl = TextEditingController(text: widget.diagnosis.doctorNote ?? '');
    _prescriptionCtrl =
        TextEditingController(text: widget.diagnosis.prescription ?? '');
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _prescriptionCtrl.dispose();
    super.dispose();
  }

  bool get _canValidate =>
      widget.diagnosis.status == DiagnosisStatus.pendingReview;

  void _validate(DiagnosisStatus newStatus) {
    final doctorCtrl = DoctorController.instance;
    if (doctorCtrl.selectedPatient == null) return;

    final note =
        _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();
    final prescription = _prescriptionCtrl.text.trim().isEmpty
        ? null
        : _prescriptionCtrl.text.trim();

    if (newStatus == DiagnosisStatus.approved) {
      doctorCtrl.approveDiagnosis(
        doctorCtrl.selectedPatient!.id,
        widget.diagnosis.id,
        note: note,
        prescription: prescription,
      );
    } else {
      doctorCtrl.rejectDiagnosis(
        doctorCtrl.selectedPatient!.id,
        widget.diagnosis.id,
        note: note,
      );
    }

    // Fire-and-forget backend sync (only for backend-issued IDs)
    if (!widget.diagnosis.id.startsWith('diag_')) {
      ApiService.validateDiagnosis(
        widget.diagnosis.id,
        newStatus == DiagnosisStatus.approved ? 'APPROVED' : 'REJECTED',
        doctorNote: note,
        prescription: prescription,
      ).catchError((_) {});
    }

    Get.back();
    Get.snackbar(
      'scanResult'.tr,
      newStatus == DiagnosisStatus.approved
          ? 'diagnosisApproved'.tr
          : 'diagnosisRejected'.tr,
      backgroundColor: newStatus == DiagnosisStatus.approved
          ? AppColors().green.withOpacity(0.9)
          : AppColors().red.withOpacity(0.9),
      colorText: AppColors().white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.diagnosis;

    return Scaffold(
      backgroundColor: AppColors().backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Utility(context).dynamicWidthPixel(26),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleWithDescription(
              title: 'validateDiagnosis',
              description: 'validateDiagnosisDesc',
              isBackButtonActive: true,
            ),
            SizedBox(height: Utility(context).dynamicWidthPixel(16)),

            // X-ray image
            _tappableImage(
              context,
              imagePath: d.imagePath,
              height: Utility(context).dynamicWidthPixel(200),
              borderRadius: BorderRadius.circular(
                Utility(context).dynamicWidthPixel(14),
              ),
            ),

            // GradCAM heatmap
            if (d.gradCamUrl != null) ...[
              SizedBox(height: Utility(context).dynamicWidthPixel(12)),
              _gradCamSection(context, d.gradCamUrl!),
            ],

            SizedBox(height: Utility(context).dynamicWidthPixel(16)),

            // AI result card
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.all(Utility(context).dynamicWidthPixel(16)),
              decoration: BoxDecoration(
                color: d.hasPneumonia
                    ? AppColors().red.withOpacity(0.08)
                    : AppColors().green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(
                    Utility(context).dynamicWidthPixel(14)),
                border: Border.all(
                  color: d.hasPneumonia
                      ? AppColors().red.withOpacity(0.3)
                      : AppColors().green.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    d.hasPneumonia
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    color: d.hasPneumonia ? AppColors().red : AppColors().green,
                    size: 28,
                  ),
                  SizedBox(width: Utility(context).dynamicWidthPixel(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.hasPneumonia ? 'pneumonia'.tr : 'healthy'.tr,
                          style: Utility(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: d.hasPneumonia
                                    ? AppColors().red
                                    : AppColors().green,
                              ),
                        ),
                        Text(
                          '${'confidence'.tr}${(d.confidence * 100).toStringAsFixed(1)}%',
                          style: Utility(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors().grey1),
                        ),
                      ],
                    ),
                  ),
                  SpecializationBadgeWidget(
                      specializationId: d.specializationId),
                ],
              ),
            ),

            // Meta info: who uploaded + validation date
            SizedBox(height: Utility(context).dynamicWidthPixel(10)),
            _metaRow(context, d),

            // Risk badge
            if (d.riskLevel != null) ...[
              SizedBox(height: Utility(context).dynamicWidthPixel(12)),
              _riskBadge(context, d.riskLevel!, d.urgencyHours),
            ],

            // Findings
            if (d.findings.isNotEmpty) ...[
              SizedBox(height: Utility(context).dynamicWidthPixel(12)),
              _listSection(
                  context, 'findings'.tr, Icons.search, d.findings),
            ],

            // Recommended actions
            if (d.recommendedActions.isNotEmpty) ...[
              SizedBox(height: Utility(context).dynamicWidthPixel(12)),
              _listSection(
                context,
                'recommendedActions'.tr,
                Icons.medical_services_outlined,
                d.recommendedActions,
              ),
            ],

            // Symptoms summary (if available)
            if (d.symptoms != null && d.symptoms!.isNotEmpty) ...[
              SizedBox(height: Utility(context).dynamicWidthPixel(12)),
              _symptomsCard(context, d.symptoms!),
            ],

            SizedBox(height: Utility(context).dynamicWidthPixel(16)),

            // Doctor notes
            _textField(
              context,
              _noteCtrl,
              'doctorNotes'.tr,
              Icons.note_outlined,
              maxLines: 3,
              enabled: _canValidate,
            ),
            SizedBox(height: Utility(context).dynamicWidthPixel(12)),

            // Prescription (only if pneumonia)
            if (d.hasPneumonia)
              _textField(
                context,
                _prescriptionCtrl,
                'prescription'.tr,
                Icons.medication_outlined,
                maxLines: 3,
                enabled: _canValidate,
              ),

            SizedBox(height: Utility(context).dynamicWidthPixel(24)),

            // Action buttons — only shown when pending
            if (_canValidate) ...[
              BaseButton(
                buttonText: 'approve'.tr,
                backgroundColor: AppColors().green,
                onPressed: () => _validate(DiagnosisStatus.approved),
              ),
              SizedBox(height: Utility(context).dynamicWidthPixel(12)),
              BaseButton(
                buttonText: 'reject'.tr,
                borderColor: AppColors().red,
                backgroundColor: Colors.transparent,
                buttonTextColor: AppColors().red,
                onPressed: () => _validate(DiagnosisStatus.rejected),
              ),
            ],

            SizedBox(height: Utility(context).dynamicWidthPixel(30)),
          ],
        ),
      ),
    );
  }

  Color _riskColor(String risk) {
    switch (risk) {
      case 'CRITICAL':
        return AppColors().red;
      case 'HIGH':
        return Colors.orange;
      case 'MODERATE':
        return Colors.amber.shade700;
      default:
        return AppColors().green;
    }
  }

  String _riskLabel(String risk) {
    switch (risk) {
      case 'CRITICAL':
        return 'riskCritical'.tr;
      case 'HIGH':
        return 'riskHigh'.tr;
      case 'MODERATE':
        return 'riskModerate'.tr;
      default:
        return 'riskLow'.tr;
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

  Widget _symptomsCard(
      BuildContext context, Map<String, dynamic> symptoms) {
    final entries = symptoms.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty)
        .toList();
    if (entries.isEmpty) return const SizedBox.shrink();

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
            Icon(Icons.monitor_heart_outlined,
                color: AppColors().mainBlueColor, size: 18),
            SizedBox(width: Utility(context).dynamicWidthPixel(8)),
            Text('symptoms'.tr,
                style: Utility(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors().mainBlueColor,
                    )),
          ]),
          SizedBox(height: Utility(context).dynamicWidthPixel(8)),
          ...entries.map((e) => Padding(
                padding: EdgeInsets.only(
                    bottom: Utility(context).dynamicWidthPixel(4)),
                child: Row(
                  children: [
                    Text('${e.key.tr}: ',
                        style: Utility(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.w500)),
                    Expanded(
                      child: Text(
                        _formatSymptomValue(e.value),
                        style: Utility(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _tappableImage(
    BuildContext context, {
    required String imagePath,
    required double height,
    BorderRadius? borderRadius,
    String? label,
    BoxFit fit = BoxFit.cover,
  }) {
    return GestureDetector(
      onTap: () => Get.to(
        () => FullScreenImageView(imagePath: imagePath, label: label),
        transition: Transition.fade,
      ),
      child: Stack(
        children: [
          XRayImage(
            imagePath: imagePath,
            height: height,
            borderRadius: borderRadius,
            fit: fit,
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.zoom_out_map,
                  color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradCamSection(BuildContext context, String gradCamUrl) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors().white,
        borderRadius:
            BorderRadius.circular(Utility(context).dynamicWidthPixel(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              Utility(context).dynamicWidthPixel(14),
              Utility(context).dynamicWidthPixel(12),
              Utility(context).dynamicWidthPixel(14),
              Utility(context).dynamicWidthPixel(8),
            ),
            child: Row(
              children: [
                Icon(Icons.blur_on_outlined,
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
          ),
          GestureDetector(
            onTap: () => Get.to(
              () => FullScreenImageView(
                  imagePath: gradCamUrl, label: 'gradCamTitle'.tr),
              transition: Transition.fade,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(
                        Utility(context).dynamicWidthPixel(12)),
                  ),
                  child: Image.network(
                    gradCamUrl,
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
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.zoom_out_map,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow(BuildContext context, DiagnosisModel d) {
    final isUploaderPatient = d.imageSource == 'PATIENT_UPLOAD';
    final isValidated = d.status == DiagnosisStatus.approved ||
        d.status == DiagnosisStatus.rejected ||
        d.status == DiagnosisStatus.completed;

    return Wrap(
      spacing: Utility(context).dynamicWidthPixel(8),
      runSpacing: Utility(context).dynamicWidthPixel(6),
      children: [
        _chip(
          context,
          isUploaderPatient ? Icons.person_outline : Icons.medical_services_outlined,
          isUploaderPatient ? 'uploadedByPatient'.tr : 'uploadedByDoctor'.tr,
          AppColors().mainBlueColor,
        ),
        if (isValidated && d.updatedAt != null)
          _chip(
            context,
            Icons.check_circle_outline,
            '${'validatedOn'.tr} ${_formatDate(d.updatedAt!)}',
            AppColors().green,
          ),
      ],
    );
  }

  Widget _chip(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Utility(context).dynamicWidthPixel(10),
        vertical: Utility(context).dynamicWidthPixel(5),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius:
            BorderRadius.circular(Utility(context).dynamicWidthPixel(8)),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          SizedBox(width: Utility(context).dynamicWidthPixel(5)),
          Text(
            label,
            style: TextStyle(
              fontSize: Utility(context).dynamicTextSize(11),
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSymptomValue(dynamic value) {
    if (value is bool) return value ? 'yes'.tr : 'no'.tr;
    if (value == 'true') return 'yes'.tr;
    if (value == 'false') return 'no'.tr;
    return value.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}  ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _textField(
    BuildContext context,
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? AppColors().white : AppColors().grey1.withOpacity(0.05),
        borderRadius:
            BorderRadius.circular(Utility(context).dynamicWidthPixel(14)),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        enabled: enabled,
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
