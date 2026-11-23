import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lungs_pneumonia_ai/core/base/components/button/base_button.dart';
import 'package:lungs_pneumonia_ai/core/base/components/popup/general_popup.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/core/models/diagnosis_model.dart';
import 'package:lungs_pneumonia_ai/view/home/view/widget/title_with_description_widget.dart';
import 'package:lungs_pneumonia_ai/view/patient/controller/patient_controller.dart';
import 'package:lungs_pneumonia_ai/view/patient/controller/patient_process_controller.dart';
import 'package:lungs_pneumonia_ai/view/patient/view/patient_process_view.dart';
import 'package:lungs_pneumonia_ai/view/patient/view/symptoms_view.dart';

class PatientConfirmView extends StatelessWidget {
  final XFile? xFileImage;
  const PatientConfirmView({super.key, this.xFileImage});

  static const _pendingStatuses = {
    DiagnosisStatus.submitted,
    DiagnosisStatus.qualityCheck,
    DiagnosisStatus.analyzing,
    DiagnosisStatus.correlating,
    DiagnosisStatus.pendingReview,
  };

  bool _hasPendingDiagnosis() {
    final diagnoses =
        PatientController.instance.currentPatient?.diagnoses ?? [];
    return diagnoses.any((d) => _pendingStatuses.contains(d.status));
  }

  void _onConfirmPressed(BuildContext context) {
    // 1 — Bloquear si hay diagnóstico en proceso
    if (_hasPendingDiagnosis()) {
      BaseDialog.show(
        context: context,
        barrierDismissible: false,
        text: 'pendingDiagnosisMsg'.tr,
        buttonText: 'understood'.tr,
        onTap: () => Get.back(),
      );
      return;
    }

    // 2 — Advertir si no registró síntomas
    if (!PatientController.instance.symptomsRegistered) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Utility(context).dynamicWidthPixel(16),
            ),
          ),
          content: Text(
            'noSymptomsMsg'.tr,
            style: Utility(context).textTheme.bodySmall?.copyWith(
                  fontSize: Utility(context).dynamicTextSize(15),
                ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // cierra el dialog
                Get.to(() => const SymptomsView());
              },
              child: Text(
                'goToSymptoms'.tr,
                style: TextStyle(color: AppColors().mainBlueColor),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back(); // cierra el dialog
                _showPrivacyAndProceed(context);
              },
              child: Text(
                'continueAnyway'.tr,
                style: TextStyle(color: AppColors().grey1),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // 3 — Todo OK: mostrar aviso de privacidad y proceder
    _showPrivacyAndProceed(context);
  }

  void _showPrivacyAndProceed(BuildContext context) {
    BaseDialog.show(
      context: context,
      text: 'warningText'.tr,
      buttonText: 'understand'.tr,
      onTap: () {
        Get.delete<PatientProcessController>(force: true);
        Get.put(PatientProcessController(xFileImage: xFileImage!));
        Get.to(() => const PatientProcessView());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Utility(context).dynamicWidthPixel(26),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleWithDescription(
              title: 'confirmPhoto',
              description: 'confirmPhotoDescription',
              isBackButtonActive: true,
            ),
            Padding(
              padding: EdgeInsets.only(
                top: Utility(context).dynamicWidthPixel(90),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  Utility(context).dynamicHeightPixel(15),
                ),
                child: Image.file(
                  io.File(xFileImage!.path),
                  width: Utility(context).dynamicWidth(1),
                  height: Utility(context).dynamicWidthPixel(230),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: Utility(context).dynamicWidth(1),
                    height: Utility(context).dynamicWidthPixel(230),
                    color: Colors.grey.withOpacity(0.1),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_outlined,
                            color: Colors.grey, size: 40),
                        SizedBox(height: 8),
                        Text('No se pudo cargar la imagen',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: Utility(context).dynamicWidthPixel(90),
                bottom: Utility(context).dynamicWidthPixel(20),
              ),
              child: BaseButton(
                buttonText: 'confirm'.tr,
                backgroundColor: AppColors().mainBlueColor,
                onPressed: () => _onConfirmPressed(context),
              ),
            ),
            BaseButton(
              buttonText: 'reselect'.tr,
              borderColor: AppColors().mainBlueColor,
              backgroundColor: Colors.transparent,
              buttonTextColor: AppColors().mainBlueColor,
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
