import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/constants/data_constants.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/view/doctor/controller/doctor_process_controller.dart';
import 'package:lungs_pneumonia_ai/view/home/view/widget/title_with_description_widget.dart';

class DoctorProcessView extends GetView<DoctorProcessController> {
  const DoctorProcessView({super.key});

  static const _steps = [
    'statusQualityCheck',
    'statusAnalyzing',
    'statusCorrelating',
    'statusProcessing',
  ];

  static const _stepStatuses = [
    'QUALITY_CHECK',
    'ANALYZING',
    'CORRELATING',
    'PENDING_REVIEW',
  ];

  int _activeStep(String label) {
    // Match the current label back to a step index
    for (int i = 0; i < _steps.length; i++) {
      if (label == _steps[i].tr) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Utility(context).dynamicWidthPixel(26),
        ),
        child: GetBuilder<DoctorProcessController>(
          builder: (_) {
            final activeStep = _activeStep(_.statusLabel);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleWithDescription(
                  title: 'scanning',
                  description: 'scanningPageDescription',
                  isBackButtonActive: true,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: Utility(context).dynamicWidthPixel(60),
                  ),
                  child: LottieBuilder.asset(
                    fit: BoxFit.contain,
                    width: Utility(context).dynamicWidth(1),
                    DataConstants.instance.jSONPath.searchLottie,
                  ),
                ),
                if (_.statusLabel.isNotEmpty) ...[
                  SizedBox(height: Utility(context).dynamicWidthPixel(24)),
                  Center(
                    child: Text(
                      _.statusLabel,
                      style: Utility(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors().mainBlueColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  SizedBox(height: Utility(context).dynamicWidthPixel(20)),
                  // Step progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_stepStatuses.length - 1, (i) {
                      final done = i < activeStep;
                      final active = i == activeStep;
                      return Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: active ? 12 : 8,
                            height: active ? 12 : 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done
                                  ? AppColors().green
                                  : active
                                      ? AppColors().mainBlueColor
                                      : AppColors().grey1.withOpacity(0.3),
                            ),
                          ),
                          if (i < _stepStatuses.length - 2)
                            Container(
                              width: Utility(context).dynamicWidthPixel(32),
                              height: 2,
                              color: done
                                  ? AppColors().green
                                  : AppColors().grey1.withOpacity(0.2),
                            ),
                        ],
                      );
                    }),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
