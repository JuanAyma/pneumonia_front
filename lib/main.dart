import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/view/auth/controller/auth_controller.dart';
import 'package:lungs_pneumonia_ai/view/auth/view/login_view.dart';
import 'package:lungs_pneumonia_ai/view/doctor/controller/doctor_controller.dart';
import 'package:lungs_pneumonia_ai/view/specialization/controller/specialization_controller.dart';
import 'package:lungs_pneumonia_ai/view/splash/view/splash_view.dart';
import 'core/base/state/base_state.dart';
import 'core/constants/app_constants.dart';
import 'core/network/api_service.dart';
import 'core/init/language/language.dart';
import 'core/init/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  runApp(const MyApp());
}

// Registra los controllers globales al inicio de la app
class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(SpecializationController(), permanent: true);
    Get.put(DoctorController(), permanent: true);
    Get.put(AuthController(), permanent: true);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus!.unfocus();
            }
          },
          child: GetMaterialApp(
            enableLog: kDebugMode,
            initialBinding: AppBindings(),
            builder: (context, child) {
              SystemChrome.setSystemUIOverlayStyle(
                  Utility(context).theme.appBarTheme.systemOverlayStyle!);
              return Column(
                children: [
                  Expanded(child: child ?? const SizedBox()),
                ],
              );
            },
            locale: const Locale('es', 'LA'),
            fallbackLocale: const Locale('en', 'US'),
            translations: Language(),
            title: ApplicationConstants.APPNAME,
            themeMode: ThemeMode.light,
            theme: ThemeManager.createTheme(AppThemeLight()),
            supportedLocales: const [
              Locale('es', 'LA'),
              Locale('en', 'US'),
              // Add new locales here when adding a new language to language.dart
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            defaultTransition: Transition.fade,
            opaqueRoute: Get.isOpaqueRouteDefault,
            popGesture: Get.isPopGestureEnable,
            transitionDuration: Get.defaultTransitionDuration,
            home: const SplashView(),
          ),
        );
      },
    );
  }
}
