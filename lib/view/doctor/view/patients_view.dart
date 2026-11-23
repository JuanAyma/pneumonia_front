import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/core/models/diagnosis_model.dart';
import 'package:lungs_pneumonia_ai/view/doctor/controller/doctor_controller.dart';
import 'package:lungs_pneumonia_ai/view/doctor/view/patient_history_view.dart';
import 'package:lungs_pneumonia_ai/view/doctor/view/register_patient_view.dart';
import 'package:lungs_pneumonia_ai/view/home/view/widget/title_with_description_widget.dart';

class PatientsView extends GetView<DoctorController> {
  const PatientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors().mainBlueColor,
        onPressed: () => Get.to(() => const RegisterPatientView()),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Utility(context).dynamicWidthPixel(26),
        ),
        child: GetBuilder<DoctorController>(
          builder: (doctorCtrl) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleWithDescription(
                  title: 'patients',
                  description: 'patientsDesc',
                ),
                SizedBox(height: Utility(context).dynamicWidthPixel(16)),
                Expanded(
                  child: doctorCtrl.patients.isEmpty
                      ? Center(
                          child: Text(
                            'noPatients'.tr,
                            style: Utility(context).textTheme.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: doctorCtrl.patients.length,
                          itemBuilder: (context, index) {
                            final patient = doctorCtrl.patients[index];
                            final pendingCount = patient.diagnoses
                                .where((d) =>
                                    d.status == DiagnosisStatus.pendingReview)
                                .length;
                            return _PatientCard(
                              name: patient.name,
                              dni: patient.dni,
                              age: patient.age,
                              hasAppAccess: patient.hasAppAccess,
                              diagnosesCount: patient.diagnoses.length,
                              pendingCount: pendingCount,
                              onTap: () {
                                doctorCtrl.selectPatient(patient);
                                Get.to(() => const PatientHistoryView());
                              },
                              onToggleAccess: () =>
                                  doctorCtrl.toggleAppAccess(patient.id),
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

class _PatientCard extends StatelessWidget {
  final String name;
  final String dni;
  final int age;
  final bool hasAppAccess;
  final int diagnosesCount;
  final int pendingCount;
  final VoidCallback onTap;
  final VoidCallback onToggleAccess;

  const _PatientCard({
    required this.name,
    required this.dni,
    required this.age,
    required this.hasAppAccess,
    required this.diagnosesCount,
    required this.pendingCount,
    required this.onTap,
    required this.onToggleAccess,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: Utility(context).dynamicWidthPixel(12)),
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors().mainBlueColor.withOpacity(0.1),
                  radius: Utility(context).dynamicWidthPixel(24),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: AppColors().mainBlueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: Utility(context).dynamicTextSize(18),
                    ),
                  ),
                ),
                if (pendingCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: Utility(context).dynamicWidthPixel(18),
                      height: Utility(context).dynamicWidthPixel(18),
                      decoration: BoxDecoration(
                        color: AppColors().red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$pendingCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Utility(context).dynamicTextSize(10),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: Utility(context).dynamicWidthPixel(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Utility(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: Utility(context).dynamicWidthPixel(4)),
                  Text(
                    'DNI: $dni  ·  $age ${'yearsOld'.tr}',
                    style: Utility(context).textTheme.bodySmall?.copyWith(
                          color: AppColors().grey1,
                        ),
                  ),
                  SizedBox(height: Utility(context).dynamicWidthPixel(4)),
                  Text(
                    '$diagnosesCount ${'diagnoses'.tr}',
                    style: Utility(context).textTheme.bodySmall?.copyWith(
                          color: AppColors().grey1,
                        ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Icon(
                  Icons.chevron_right,
                  color: AppColors().grey1,
                ),
                SizedBox(height: Utility(context).dynamicWidthPixel(6)),
                GestureDetector(
                  onTap: onToggleAccess,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Utility(context).dynamicWidthPixel(8),
                      vertical: Utility(context).dynamicWidthPixel(4),
                    ),
                    decoration: BoxDecoration(
                      color: hasAppAccess
                          ? AppColors().green.withOpacity(0.15)
                          : AppColors().grey1.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(
                        Utility(context).dynamicWidthPixel(6),
                      ),
                    ),
                    child: Text(
                      hasAppAccess ? 'appAccess'.tr : 'noAccess'.tr,
                      style: TextStyle(
                        fontSize: Utility(context).dynamicTextSize(10),
                        color: hasAppAccess
                            ? AppColors().green
                            : AppColors().grey1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
