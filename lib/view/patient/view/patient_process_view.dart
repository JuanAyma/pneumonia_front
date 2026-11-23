import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/constants/data_constants.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/view/home/view/widget/title_with_description_widget.dart';
import 'package:lungs_pneumonia_ai/view/patient/controller/patient_process_controller.dart';

class PatientProcessView extends GetView<PatientProcessController> {
  const PatientProcessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Utility(context).dynamicWidthPixel(26),
        ),
        child: GetBuilder<PatientProcessController>(
          builder: (_) {
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
                    top: Utility(context).dynamicWidthPixel(90),
                  ),
                  child: LottieBuilder.asset(
                    fit: BoxFit.contain,
                    width: Utility(context).dynamicWidth(1),
                    DataConstants.instance.jSONPath.searchLottie,
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
