import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/base/components/button/base_button.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/core/models/patient_model.dart';
import 'package:lungs_pneumonia_ai/view/doctor/controller/doctor_controller.dart';
import 'package:lungs_pneumonia_ai/view/home/view/widget/title_with_description_widget.dart';

class RegisterPatientView extends StatefulWidget {
  const RegisterPatientView({super.key});

  @override
  State<RegisterPatientView> createState() => _RegisterPatientViewState();
}

class _RegisterPatientViewState extends State<RegisterPatientView> {
  final _nameCtrl = TextEditingController();
  final _dniCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  bool _hasAppAccess = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dniCtrl.dispose();
    _ageCtrl.dispose();
    _phoneCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  void _register() {
    if (_nameCtrl.text.isEmpty ||
        _dniCtrl.text.isEmpty ||
        _ageCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty) {
      Get.snackbar(
        'registerPatient'.tr,
        'fillAllFields'.tr,
        backgroundColor: AppColors().red.withOpacity(0.9),
        colorText: AppColors().white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final newPatient = PatientModel(
      id: 'p${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      dni: _dniCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
      phone: _phoneCtrl.text.trim(),
      hasAppAccess: _hasAppAccess,
      username: _usernameCtrl.text.trim().isEmpty
          ? '${_nameCtrl.text.trim().toLowerCase().replaceAll(' ', '.')}@salud.pe'
          : _usernameCtrl.text.trim(),
    );
    DoctorController.instance.addPatient(newPatient);
    Get.back();
    Get.snackbar(
      'registerPatient'.tr,
      'patientRegistered'.tr,
      backgroundColor: AppColors().green.withOpacity(0.9),
      colorText: AppColors().white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Utility(context).dynamicWidthPixel(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleWithDescription(
                title: 'registerPatient',
                description: 'registerPatientDesc',
                isBackButtonActive: true,
              ),
              SizedBox(height: Utility(context).dynamicWidthPixel(20)),
              _field(context, _nameCtrl, 'fullName'.tr, Icons.person_outline),
              SizedBox(height: Utility(context).dynamicWidthPixel(12)),
              _field(context, _dniCtrl, 'dni'.tr, Icons.badge_outlined,
                  keyboardType: TextInputType.number),
              SizedBox(height: Utility(context).dynamicWidthPixel(12)),
              _field(context, _ageCtrl, 'age'.tr, Icons.cake_outlined,
                  keyboardType: TextInputType.number),
              SizedBox(height: Utility(context).dynamicWidthPixel(12)),
              _field(context, _phoneCtrl, 'phone'.tr, Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              SizedBox(height: Utility(context).dynamicWidthPixel(12)),
              _field(context, _usernameCtrl, 'emailOptional'.tr,
                  Icons.alternate_email,
                  keyboardType: TextInputType.emailAddress),
              SizedBox(height: Utility(context).dynamicWidthPixel(16)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Utility(context).dynamicWidthPixel(16),
                  vertical: Utility(context).dynamicWidthPixel(12),
                ),
                decoration: BoxDecoration(
                  color: AppColors().white,
                  borderRadius: BorderRadius.circular(
                    Utility(context).dynamicWidthPixel(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('appAccess'.tr,
                            style: Utility(context).textTheme.bodyMedium),
                        Text(
                          'appAccessDesc'.tr,
                          style: Utility(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors().grey1),
                        ),
                      ],
                    ),
                    Switch(
                      value: _hasAppAccess,
                      activeColor: AppColors().mainBlueColor,
                      onChanged: (v) => setState(() => _hasAppAccess = v),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Utility(context).dynamicWidthPixel(30)),
              BaseButton(
                buttonText: 'register'.tr,
                backgroundColor: AppColors().mainBlueColor,
                onPressed: _register,
              ),
              SizedBox(height: Utility(context).dynamicWidthPixel(20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    BuildContext context,
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors().white,
        borderRadius:
            BorderRadius.circular(Utility(context).dynamicWidthPixel(14)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: Utility(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors().grey1),
          prefixIcon: Icon(icon, color: AppColors().grey1),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: Utility(context).dynamicWidthPixel(14),
            horizontal: Utility(context).dynamicWidthPixel(16),
          ),
        ),
      ),
    );
  }
}
