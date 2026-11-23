import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/base/components/bottom_navigation_bar_widget.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/view/auth/controller/auth_controller.dart';
import 'package:lungs_pneumonia_ai/view/onboarding/controller/onboarding_controller.dart';
import '../../../core/base/components/base_selected_listview.dart';
import '../../../core/base/components/button/base_button.dart';
import '../../../core/constants/enums/setting_type_enum.dart';

class SettingsView extends GetView<OnboardingController> {
  final SettingsType settingsType;
  const SettingsView({
    Key? key,
    required this.settingsType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundColor,
      bottomNavigationBar: settingsType == SettingsType.botttomNavBarSettings
          ? const SizedBox()
          : Padding(
              padding: EdgeInsets.only(
                left: Utility(context).dynamicWidthPixel(28),
                right: Utility(context).dynamicWidthPixel(28),
                bottom: Utility(context).dynamicWidthPixel(90),
              ),
              child: BaseButton(
                buttonText: 'save'.tr,
                onPressed: () {
                  Get.off(const BottomNavigationBarView(selectedIndex: 0));
                },
              ),
            ),
      body: Padding(
        padding: EdgeInsets.only(
          top: Utility(context).dynamicWidthPixel(160),
          left: Utility(context).dynamicWidthPixel(26),
          right: Utility(context).dynamicWidthPixel(26),
        ),
        child: GetBuilder<OnboardingController>(
          init: OnboardingController(),
          builder: (onboardingController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "language".tr,
                  style: Utility(context).textTheme.titleLarge,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: Utility(context).dynamicWidthPixel(26),
                  ),
                  child: GetBuilder<OnboardingController>(
                    init: OnboardingController(),
                    builder: (onboardingController) {
                      return SizedBox(
                        width: Utility(context).dynamicWidth(1),
                        height: Utility(context).dynamicWidth(0.90),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(0),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: onboardingController.languages.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () async {
                                await onboardingController.setLanguage(index);
                              },
                              child: BaseSelectedListViewWidget(
                                buttonText: onboardingController.languages[index],
                                color: index == onboardingController.selectedIndex ? AppColors().mainBlueColor : AppColors().grey1,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (settingsType == SettingsType.botttomNavBarSettings)
                  Padding(
                    padding: EdgeInsets.only(
                      top: Utility(context).dynamicWidthPixel(20),
                    ),
                    child: GestureDetector(
                      onTap: () => AuthController.instance.logout(),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(
                            Utility(context).dynamicWidthPixel(16)),
                        decoration: BoxDecoration(
                          color: AppColors().red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            Utility(context).dynamicWidthPixel(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: AppColors().red),
                            SizedBox(
                                width: Utility(context).dynamicWidthPixel(8)),
                            Text(
                              'logout'.tr,
                              style: Utility(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors().red,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
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
