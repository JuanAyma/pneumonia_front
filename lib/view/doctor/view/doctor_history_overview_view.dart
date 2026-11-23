import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/core/models/diagnosis_model.dart';
import 'package:lungs_pneumonia_ai/core/models/patient_model.dart';
import 'package:lungs_pneumonia_ai/view/doctor/controller/doctor_controller.dart';
import 'package:lungs_pneumonia_ai/view/doctor/view/patient_history_view.dart';
import 'package:lungs_pneumonia_ai/view/home/view/widget/title_with_description_widget.dart';

class DoctorHistoryOverviewView extends GetView<DoctorController> {
  const DoctorHistoryOverviewView({super.key});

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
            final patientsWithDiagnoses = ctrl.patients
                .where((p) => p.diagnoses.isNotEmpty)
                .toList()
              ..sort((a, b) =>
                  b.diagnoses.first.date.compareTo(a.diagnoses.first.date));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TitleWithDescription(
                  title: 'history',
                  description: 'historyDesc',
                ),
                SizedBox(height: Utility(context).dynamicWidthPixel(8)),
                Expanded(
                  child: patientsWithDiagnoses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.history,
                                  size: 48, color: AppColors().grey1),
                              SizedBox(
                                  height: Utility(context)
                                      .dynamicWidthPixel(12)),
                              Text(
                                'noHistory'.tr,
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
                          itemCount: patientsWithDiagnoses.length,
                          itemBuilder: (_, index) {
                            final patient = patientsWithDiagnoses[index];
                            return _PatientHistoryCard(
                              patient: patient,
                              onTap: () {
                                ctrl.selectPatient(patient);
                                Get.to(() => const PatientHistoryView());
                              },
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

class _PatientHistoryCard extends StatelessWidget {
  final PatientModel patient;
  final VoidCallback onTap;

  const _PatientHistoryCard({
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastDiagnosis = patient.diagnoses.first;
    final pendingCount =
        patient.diagnoses.where((d) => d.status == DiagnosisStatus.pendingReview ||
            d.status == DiagnosisStatus.submitted ||
            d.status == DiagnosisStatus.analyzing ||
            d.status == DiagnosisStatus.qualityCheck ||
            d.status == DiagnosisStatus.correlating).length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
            EdgeInsets.only(bottom: Utility(context).dynamicWidthPixel(12)),
        padding: EdgeInsets.all(Utility(context).dynamicWidthPixel(16)),
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
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors().mainBlueColor.withOpacity(0.1),
              radius: Utility(context).dynamicWidthPixel(22),
              child: Text(
                patient.name[0].toUpperCase(),
                style: TextStyle(
                  color: AppColors().mainBlueColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: Utility(context).dynamicWidthPixel(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: Utility(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: Utility(context).dynamicWidthPixel(3)),
                  Text(
                    '${patient.diagnoses.length} ${'diagnoses'.tr}  ·  '
                    '${_formatDate(lastDiagnosis.date)}',
                    style: Utility(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors().grey1),
                  ),
                ],
              ),
            ),
            if (pendingCount > 0)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Utility(context).dynamicWidthPixel(8),
                  vertical: Utility(context).dynamicWidthPixel(4),
                ),
                decoration: BoxDecoration(
                  color: AppColors().red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(
                    Utility(context).dynamicWidthPixel(8),
                  ),
                ),
                child: Text(
                  '$pendingCount',
                  style: TextStyle(
                    color: AppColors().red,
                    fontWeight: FontWeight.bold,
                    fontSize: Utility(context).dynamicTextSize(12),
                  ),
                ),
              ),
            SizedBox(width: Utility(context).dynamicWidthPixel(8)),
            Icon(Icons.chevron_right, color: AppColors().grey1),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
