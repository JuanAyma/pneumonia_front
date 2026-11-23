import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/view/auth/controller/auth_controller.dart';
import 'package:lungs_pneumonia_ai/view/doctor/view/patients_view.dart';
import 'package:lungs_pneumonia_ai/view/doctor/view/doctor_scan_view.dart';
import 'package:lungs_pneumonia_ai/view/doctor/view/doctor_history_overview_view.dart';
import 'package:lungs_pneumonia_ai/view/onboarding/view/settings_view.dart';
import '../../../core/constants/enums/setting_type_enum.dart';

class DoctorBottomNavView extends StatefulWidget {
  const DoctorBottomNavView({super.key});

  @override
  State<DoctorBottomNavView> createState() => _DoctorBottomNavViewState();
}

class _DoctorBottomNavViewState extends State<DoctorBottomNavView> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const PatientsView(),
    const DoctorScanView(),
    const DoctorHistoryOverviewView(),
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
                  _navItem(0, Icons.people_outline, Icons.people, 'patients'.tr),
                  _navItem(1, Icons.document_scanner_outlined,
                      Icons.document_scanner, 'scan'.tr),
                  _navItem(2, Icons.history_outlined, Icons.history,
                      'history'.tr),
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

// Logout button helper used in doctor/patient settings
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Utility(context).dynamicWidthPixel(26)),
      child: GestureDetector(
        onTap: () => AuthController.instance.logout(),
        child: Container(
          padding: EdgeInsets.all(Utility(context).dynamicWidthPixel(16)),
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
              SizedBox(width: Utility(context).dynamicWidthPixel(8)),
              Text(
                'logout'.tr,
                style: Utility(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors().red,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
