import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/base/components/image/xray_image_widget.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/core/models/diagnosis_model.dart';
import 'package:lungs_pneumonia_ai/view/doctor/controller/doctor_controller.dart';
import 'package:lungs_pneumonia_ai/view/doctor/view/doctor_validate_pending_view.dart';
import 'package:lungs_pneumonia_ai/view/home/view/widget/title_with_description_widget.dart';
import 'package:lungs_pneumonia_ai/view/specialization/widget/specialization_badge_widget.dart';

class PatientHistoryView extends GetView<DoctorController> {
  const PatientHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Utility(context).dynamicWidthPixel(26),
        ),
        child: GetBuilder<DoctorController>(
          builder: (ctrl) {
            final patient = ctrl.selectedPatient;
            final diagnoses = patient?.diagnoses ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleWithDescription(
                  title: patient != null ? patient.name : 'patientHistory',
                  description: 'patientHistoryDesc',
                  isBackButtonActive: true,
                ),
                SizedBox(height: Utility(context).dynamicWidthPixel(16)),
                Expanded(
                  child: diagnoses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.folder_open_outlined,
                                size: 48,
                                color: AppColors().grey1,
                              ),
                              SizedBox(
                                  height:
                                      Utility(context).dynamicWidthPixel(12)),
                              Text(
                                'noDiagnoses'.tr,
                                style: Utility(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors().grey1),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: diagnoses.length,
                          itemBuilder: (_, index) {
                            return _DiagnosisCard(
                              diagnosis: diagnoses[index],
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DiagnosisCard extends StatelessWidget {
  final DiagnosisModel diagnosis;
  const _DiagnosisCard({required this.diagnosis});

  bool get _isPending => diagnosis.status == DiagnosisStatus.pendingReview;

  @override
  Widget build(BuildContext context) {
    final statusColor = diagnosis.status == DiagnosisStatus.approved
        ? AppColors().green
        : diagnosis.status == DiagnosisStatus.rejected
            ? AppColors().red
            : _isPending
                ? AppColors().mainBlueColor
                : AppColors().grey1;

    final statusText = diagnosis.status == DiagnosisStatus.approved
        ? 'diagnosisApproved'.tr
        : diagnosis.status == DiagnosisStatus.rejected
            ? 'diagnosisRejected'.tr
            : 'pendingApproval'.tr;

    return GestureDetector(
      onTap: () => Get.to(
        () => DoctorValidatePendingView(diagnosis: diagnosis),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: Utility(context).dynamicWidthPixel(14)),
        decoration: BoxDecoration(
          color: AppColors().white,
          borderRadius: BorderRadius.circular(
            Utility(context).dynamicWidthPixel(14),
          ),
          border: _isPending
              ? Border.all(
                  color: AppColors().mainBlueColor.withOpacity(0.4), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            XRayImage(
              imagePath: diagnosis.imagePath,
              height: Utility(context).dynamicWidthPixel(140),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(Utility(context).dynamicWidthPixel(14)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Utility(context).dynamicWidthPixel(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        diagnosis.hasPneumonia
                            ? 'pneumonia'.tr
                            : 'healthy'.tr,
                        style: Utility(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: diagnosis.hasPneumonia
                                  ? AppColors().red
                                  : AppColors().green,
                            ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  Utility(context).dynamicWidthPixel(10),
                              vertical: Utility(context).dynamicWidthPixel(4),
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(
                                Utility(context).dynamicWidthPixel(8),
                              ),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize:
                                    Utility(context).dynamicTextSize(11),
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (_isPending) ...[
                            SizedBox(
                                width:
                                    Utility(context).dynamicWidthPixel(6)),
                            Icon(Icons.chevron_right,
                                color: AppColors().mainBlueColor, size: 18),
                          ],
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: Utility(context).dynamicWidthPixel(6)),
                  Text(
                    '${'confidence'.tr}${(diagnosis.confidence * 100).toStringAsFixed(1)}%',
                    style: Utility(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors().grey1),
                  ),
                  Text(
                    _formatDate(diagnosis.date),
                    style: Utility(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors().grey1),
                  ),
                  SizedBox(height: Utility(context).dynamicWidthPixel(6)),
                  SpecializationBadgeWidget(
                      specializationId: diagnosis.specializationId),
                  if (_isPending) ...[
                    SizedBox(height: Utility(context).dynamicWidthPixel(8)),
                    Text(
                      'tapToValidate'.tr,
                      style: TextStyle(
                        fontSize: Utility(context).dynamicTextSize(11),
                        color: AppColors().mainBlueColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (diagnosis.doctorNote != null &&
                      diagnosis.doctorNote!.isNotEmpty) ...[
                    SizedBox(height: Utility(context).dynamicWidthPixel(8)),
                    Text(
                      '${'doctorNotes'.tr}: ${diagnosis.doctorNote}',
                      style: Utility(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors().mainBlueColor),
                    ),
                  ],
                  if (diagnosis.prescription != null &&
                      diagnosis.prescription!.isNotEmpty) ...[
                    SizedBox(height: Utility(context).dynamicWidthPixel(4)),
                    Text(
                      '${'prescription'.tr}: ${diagnosis.prescription}',
                      style: Utility(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors().mainBlueColor),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}  ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
