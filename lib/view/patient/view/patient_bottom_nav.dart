import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/constants/enums/setting_type_enum.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/view/onboarding/view/settings_view.dart';
import 'package:lungs_pneumonia_ai/view/patient/view/patient_results_view.dart';
import 'package:lungs_pneumonia_ai/view/patient/view/patient_scan_view.dart';
import 'package:lungs_pneumonia_ai/view/patient/view/symptoms_view.dart';

class PatientBottomNavView extends StatefulWidget {
  const PatientBottomNavView({super.key});

  @override
  State<PatientBottomNavView> createState() => _PatientBottomNavViewState();
}

class _PatientBottomNavViewState extends State<PatientBottomNavView> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const PatientScanView(),
    const SymptomsView(),
    const PatientResultsView(),
    const SettingsView(settingsType: SettingsType.botttomNavBarSettings),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isIOS) {
          exit(0);
        } else {
          SystemNavigator.pop();
        }
        return false;
      },
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors().white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: Utility(context).dynamicWidthPixel(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(
                      0,
                      Icons.document_scanner_outlined,
                      Icons.document_scanner,
                      'scan'.tr),
                  _navItem(
                      1,
                      Icons.monitor_heart_outlined,
                      Icons.monitor_heart,
                      'symptoms'.tr),
                  _navItem(
                      2,
                      Icons.assignment_outlined,
                      Icons.assignment,
                      'results'.tr),
                  _navItem(3, Icons.settings_outlined, Icons.settings,
                      'settings'.tr),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? AppColors().mainBlueColor : AppColors().grey1,
            size: Utility(context).dynamicTextSize(24),
          ),
          SizedBox(height: Utility(context).dynamicWidthPixel(4)),
          Text(
            label,
            style: TextStyle(
              fontSize: Utility(context).dynamicTextSize(11),
              color: isSelected ? AppColors().mainBlueColor : AppColors().grey1,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
