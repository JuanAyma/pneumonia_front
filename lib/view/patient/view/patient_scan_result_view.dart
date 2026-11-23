import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/base/components/button/base_button.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/view/home/view/widget/title_with_description_widget.dart';
import 'package:lungs_pneumonia_ai/view/patient/controller/patient_process_controller.dart';
import 'package:lungs_pneumonia_ai/view/patient/view/patient_bottom_nav.dart';

class PatientScanResultView extends GetView<PatientProcessController> {
  const PatientScanResultView({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundColor,
      body: GetBuilder<PatientProcessController>(
        builder: (processCtrl) {
          final hasPneumonia = processCtrl.output.isNotEmpty &&
              processCtrl.output[0]['index'] == 1;
          final confidence = processCtrl.output.isNotEmpty
              ? (processCtrl.output[0]['confidence'] as double)
              : 0.0;

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
                  isBackButtonActive: false,
                ),
                SizedBox(height: Utility(context).dynamicWidthPixel(16)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    Utility(context).dynamicWidthPixel(14),
                  ),
                  child: Image.file(
                    io.File(processCtrl.xFileImage.path),
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
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Utility(context).dynamicWidthPixel(16)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(
                    Utility(context).dynamicWidthPixel(16),
                  ),
                  decoration: BoxDecoration(
                    color: hasPneumonia
                        ? AppColors().red.withOpacity(0.08)
                        : AppColors().green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(
                      Utility(context).dynamicWidthPixel(14),
                    ),
                    border: Border.all(
                      color: hasPneumonia
                          ? AppColors().red.withOpacity(0.25)
                          : AppColors().green.withOpacity(0.25),
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
                SizedBox(height: Utility(context).dynamicWidthPixel(20)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(
                    Utility(context).dynamicWidthPixel(16),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors().mainBlueColor.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(
                      Utility(context).dynamicWidthPixel(14),
                    ),
                    border: Border.all(
                      color: AppColors().mainBlueColor.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_top,
                          color: AppColors().mainBlueColor),
                      SizedBox(
                          width: Utility(context).dynamicWidthPixel(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'scanResultPending'.tr,
                              style: Utility(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors().mainBlueColor,
                                  ),
                            ),
                            SizedBox(
                                height: Utility(context)
                                    .dynamicWidthPixel(4)),
                            Text(
                              'scanResultPendingDesc'.tr,
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
                SizedBox(height: Utility(context).dynamicWidthPixel(30)),
                BaseButton(
                  buttonText: 'complete'.tr,
                  backgroundColor: AppColors().mainBlueColor,
                  onPressed: () =>
                      Get.off(() => const PatientBottomNavView()),
                ),
                SizedBox(height: Utility(context).dynamicWidthPixel(20)),
              ],
            ),
          );
        },
      ),
    );
  }
}
