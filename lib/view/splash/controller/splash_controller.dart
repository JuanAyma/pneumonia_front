import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:lungs_pneumonia_ai/view/auth/view/login_view.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    Get.updateLocale(const Locale('es', 'LA'));
    routePage();
    super.onInit();
  }

  routePage() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.off(const LoginView());
    });
  }
}
