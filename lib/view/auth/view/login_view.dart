import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/base/components/button/base_button.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/constants/image_constants.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/core/models/user_model.dart';
import '../controller/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.doctor;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_usernameCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      Get.snackbar(
        'loginTitle'.tr,
        'fillAllFields'.tr,
        backgroundColor: AppColors().red.withOpacity(0.9),
        colorText: AppColors().white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    setState(() => _isLoading = true);
    final AuthController auth = AuthController.instance;
    final success =
        await auth.login(_usernameCtrl.text, _passwordCtrl.text, _selectedRole);
    if (!success && mounted) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'loginTitle'.tr,
        'invalidCredentials'.tr,
        backgroundColor: AppColors().red.withOpacity(0.9),
        colorText: AppColors().white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: Utility(context).dynamicWidthPixel(60)),
              Container(
                width: Utility(context).dynamicWidthPixel(90),
                height: Utility(context).dynamicWidthPixel(90),
                decoration: BoxDecoration(
                  color: AppColors().mainBlueColor,
                  borderRadius: BorderRadius.circular(
                    Utility(context).dynamicWidthPixel(20),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(Utility(context).dynamicWidthPixel(18)),
                  child: SvgPicture.asset(
                    ImageConstants.instance.svgPath.lungs,
                    color: AppColors().white,
                  ),
                ),
              ),
              SizedBox(height: Utility(context).dynamicWidthPixel(20)),
              Text(
                'appName'.tr,
                style: Utility(context).textTheme.titleLarge?.copyWith(
                      color: AppColors().mainBlueColor,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Utility(context).dynamicWidthPixel(6)),
              Text(
                'loginSubtitle'.tr,
                style: Utility(context).textTheme.bodySmall?.copyWith(
                      color: AppColors().grey1,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Utility(context).dynamicWidthPixel(36)),
              Container(
                decoration: BoxDecoration(
                  color: AppColors().white,
                  borderRadius: BorderRadius.circular(
                    Utility(context).dynamicWidthPixel(14),
                  ),
                ),
                child: Row(
                  children: [
                    _roleTab(
                      label: 'doctorRole'.tr,
                      icon: Icons.medical_services_outlined,
                      isSelected: _selectedRole == UserRole.doctor,
                      onTap: () => setState(() {
                        _selectedRole = UserRole.doctor;
                        _usernameCtrl.clear();
                        _passwordCtrl.clear();
                      }),
                    ),
                    _roleTab(
                      label: 'patientRole'.tr,
                      icon: Icons.person_outline,
                      isSelected: _selectedRole == UserRole.patient,
                      onTap: () => setState(() {
                        _selectedRole = UserRole.patient;
                        _usernameCtrl.clear();
                        _passwordCtrl.clear();
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Utility(context).dynamicWidthPixel(24)),
              _buildDemoHint(context),
              SizedBox(height: Utility(context).dynamicWidthPixel(20)),
              _buildTextField(
                context: context,
                controller: _usernameCtrl,
                label: 'username'.tr,
                icon: Icons.alternate_email,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: Utility(context).dynamicWidthPixel(14)),
              _buildTextField(
                context: context,
                controller: _passwordCtrl,
                label: 'password'.tr,
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors().grey1,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              SizedBox(height: Utility(context).dynamicWidthPixel(30)),
              _isLoading
                  ? CircularProgressIndicator(color: AppColors().mainBlueColor)
                  : BaseButton(
                      buttonText: 'loginButton'.tr,
                      backgroundColor: AppColors().mainBlueColor,
                      onPressed: _handleLogin,
                    ),
              SizedBox(height: Utility(context).dynamicWidthPixel(20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: Utility(context).dynamicWidthPixel(12),
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors().mainBlueColor : Colors.transparent,
            borderRadius: BorderRadius.circular(
              Utility(context).dynamicWidthPixel(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors().white : AppColors().grey1,
                size: Utility(context).dynamicTextSize(20),
              ),
              SizedBox(width: Utility(context).dynamicWidthPixel(6)),
              Text(
                label,
                style: Utility(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? AppColors().white : AppColors().grey1,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoHint(BuildContext context) {
    final hint = _selectedRole == UserRole.doctor
        ? 'doctor@salud.pe  /  1234'
        : 'juan.perez@salud.pe  /  1234';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Utility(context).dynamicWidthPixel(12)),
      decoration: BoxDecoration(
        color: AppColors().mainBlueColor.withOpacity(0.08),
        borderRadius:
            BorderRadius.circular(Utility(context).dynamicWidthPixel(10)),
        border: Border.all(
          color: AppColors().mainBlueColor.withOpacity(0.2),
        ),
      ),
      child: Text(
        'demoHint'.tr + hint,
        style: Utility(context).textTheme.bodySmall?.copyWith(
              color: AppColors().mainBlueColor,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors().white,
        borderRadius:
            BorderRadius.circular(Utility(context).dynamicWidthPixel(14)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: Utility(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors().grey1),
          prefixIcon: Icon(icon, color: AppColors().grey1),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: Utility(context).dynamicWidthPixel(14),
            horizontal: Utility(context).dynamicWidthPixel(16),
          ),
        ),
        onSubmitted: (_) => _handleLogin(),
      ),
    );
  }
}
