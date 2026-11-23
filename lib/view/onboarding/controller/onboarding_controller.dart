import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/constants/enums/setting_type_enum.dart';
import 'package:lungs_pneumonia_ai/core/constants/image_constants.dart';
import 'package:lungs_pneumonia_ai/view/onboarding/model/onboarding_model.dart';
import '../view/settings_view.dart';

class OnboardingController extends GetxController {
  int selectedIndex = 0;

  // To add a new language: add its translation key here and a new case in setLanguage.
  List<String> languages = ['spanish', 'english'];

  Future<void> setLanguage(int index) async {
    switch (index) {
      case 0:
        Get.updateLocale(const Locale('es', 'LA'));
        selectedIndex = 0;
        break;
      case 1:
        Get.updateLocale(const Locale('en', 'US'));
        selectedIndex = 1;
        break;
      default:
        break;
    }
    update();
  }

  List<OnboardingModel> itemList = [
    OnboardingModel(
      title: 'welcome',
      imagePath: ImageConstants.instance.svgPath.lungs,
      description: 'welcomeDescription',
    ),
    OnboardingModel(
      title: 'safety',
      imagePath: ImageConstants.instance.svgPath.safety,
      description: 'safetyDescription',
    ),
    OnboardingModel(
      title: 'offline',
      imagePath: ImageConstants.instance.svgPath.non,
      description: 'offlineDescription',
    ),
  ];

  CarouselSliderController? buttonCarouselController;

  @override
  void onInit() {
    super.onInit();
    buttonCarouselController = CarouselSliderController();
  }

  void nextOnboardingScreen(int index) {
    if (index < itemList.length - 1) {
      buttonCarouselController?.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      update();
    } else {
      Get.to(const SettingsView(settingsType: SettingsType.splashSettings));
    }
  }
}
