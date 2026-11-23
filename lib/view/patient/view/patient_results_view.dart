import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/base/components/image/xray_image_widget.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/core/models/diagnosis_model.dart';
import 'package:lungs_pneumonia_ai/view/home/view/widget/title_with_description_widget.dart';
import 'package:lungs_pneumonia_ai/view/patient/controller/patient_controller.dart';
import 'package:lungs_pneumonia_ai/view/specialization/widget/specialization_badge_widget.dart';

class PatientResultsView extends GetView<PatientController> {
  const PatientResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Utility(context).dynamicWidthPixel(26),
        ),
        child: GetBuilder<PatientController>(
          builder: (ctrl) {
            final diagnoses = ctrl.currentPatient?.diagnoses ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleWithDescription(
                  title: 'myResults',
                  description: 'myResultsDesc',
                ),
                SizedBox(height: Utility(context).dynamicWidthPixel(8)),
                Expanded(
                  child: diagnoses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 48,
                                color: AppColors().grey1,
                              ),
                              SizedBox(
                                  height: Utility(context)
                                      .dynamicWidthPixel(12)),
                              Text(
                                'noResults'.tr,
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
                            return _ResultCard(
                                diagnosis: diagnoses[index]);
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

class _ResultCard extends StatelessWidget {
  final DiagnosisModel diagnosis;
  const _ResultCard({required this.diagnosis});

  @override
  Widget build(BuildContext context) {
    final isPending = diagnosis.status == DiagnosisStatus.pendingReview ||
        diagnosis.status == DiagnosisStatus.submitted ||
        diagnosis.status == DiagnosisStatus.analyzing ||
        diagnosis.status == DiagnosisStatus.qualityCheck ||
        diagnosis.status == DiagnosisStatus.correlating;
    final isApproved = diagnosis.status == DiagnosisStatus.approved;

    final statusColor = isApproved
        ? AppColors().green
        : isPending
            ? AppColors().grey1
            : AppColors().red;
    final statusText = isApproved
        ? 'diagnosisApproved'.tr
        : isPending
            ? 'pendingApproval'.tr
            : 'diagnosisRejected'.tr;
    final statusIcon = isApproved
        ? Icons.check_circle
        : isPending
            ? Icons.hourglass_top
            : Icons.cancel;

    return Container(
      margin: EdgeInsets.only(bottom: Utility(context).dynamicWidthPixel(14)),
      decoration: BoxDecoration(
        color: AppColors().white,
        borderRadius: BorderRadius.circular(
          Utility(context).dynamicWidthPixel(14),
        ),
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
            height: Utility(context).dynamicWidthPixel(130),
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
                      diagnosis.hasPneumonia ? 'pneumonia'.tr : 'healthy'.tr,
                      style: Utility(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: diagnosis.hasPneumonia
                                ? AppColors().red
                                : AppColors().green,
                          ),
                    ),
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 16),
                        SizedBox(
                            width: Utility(context).dynamicWidthPixel(4)),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: Utility(context).dynamicTextSize(11),
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: Utility(context).dynamicWidthPixel(4)),
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
                if (isApproved) ...[
                  if (diagnosis.doctorNote != null &&
                      diagnosis.doctorNote!.isNotEmpty) ...[
                    SizedBox(
                        height: Utility(context).dynamicWidthPixel(8)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                          Utility(context).dynamicWidthPixel(10)),
                      decoration: BoxDecoration(
                        color: AppColors().mainBlueColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(
                            Utility(context).dynamicWidthPixel(8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${'doctorNotes'.tr}:',
                            style: Utility(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors().mainBlueColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            diagnosis.doctorNote!,
                            style: Utility(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (diagnosis.prescription != null &&
                      diagnosis.prescription!.isNotEmpty) ...[
                    SizedBox(
                        height: Utility(context).dynamicWidthPixel(6)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                          Utility(context).dynamicWidthPixel(10)),
                      decoration: BoxDecoration(
                        color: AppColors().green.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(
                            Utility(context).dynamicWidthPixel(8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${'prescription'.tr}:',
                            style: Utility(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors().green,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            diagnosis.prescription!,
                            style: Utility(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
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
