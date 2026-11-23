import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/base/components/button/base_button.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/core/models/specialization_model.dart';
import 'package:lungs_pneumonia_ai/view/home/view/widget/title_with_description_widget.dart';
import 'package:lungs_pneumonia_ai/view/patient/controller/patient_controller.dart';

class SymptomsView extends GetView<PatientController> {
  const SymptomsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Utility(context).dynamicWidthPixel(26),
        ),
        child: GetBuilder<PatientController>(
          builder: (ctrl) {
            final spec = ctrl.selectedSpecialization;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleWithDescription(
                    title: 'symptomsTitle',
                    description: 'symptomsDesc',
                  ),
                  SizedBox(height: Utility(context).dynamicWidthPixel(20)),
                  if (spec == null)
                    _NoSpecSelected(context)
                  else ...[
                    ...spec.symptomFields
                        .map((field) => _buildField(context, ctrl, field)),
                    SizedBox(height: Utility(context).dynamicWidthPixel(24)),
                    if (ctrl.symptomsRegistered)
                      _SuccessBanner(context),
                    SizedBox(height: Utility(context).dynamicWidthPixel(16)),
                    BaseButton(
                      buttonText: 'submitSymptoms'.tr,
                      backgroundColor: AppColors().mainBlueColor,
                      onPressed: () {
                        ctrl.registerSymptoms();
                        Get.snackbar(
                          'symptomsTitle'.tr,
                          'symptomsRegistered'.tr,
                          backgroundColor:
                              AppColors().green.withOpacity(0.9),
                          colorText: AppColors().white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                  ],
                  SizedBox(height: Utility(context).dynamicWidthPixel(30)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _NoSpecSelected(BuildContext context) => Center(
        child: Padding(
          padding:
              EdgeInsets.only(top: Utility(context).dynamicWidthPixel(40)),
          child: Column(
            children: [
              Icon(Icons.touch_app_outlined,
                  size: 48, color: AppColors().grey1),
              SizedBox(height: Utility(context).dynamicWidthPixel(12)),
              Text(
                'selectSpecializationFirst'.tr,
                style: Utility(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors().grey1),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Widget _SuccessBanner(BuildContext context) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(Utility(context).dynamicWidthPixel(14)),
        decoration: BoxDecoration(
          color: AppColors().green.withOpacity(0.1),
          borderRadius:
              BorderRadius.circular(Utility(context).dynamicWidthPixel(12)),
          border:
              Border.all(color: AppColors().green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors().green),
            SizedBox(width: Utility(context).dynamicWidthPixel(10)),
            Text(
              'symptomsRegistered'.tr,
              style: Utility(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors().green),
            ),
          ],
        ),
      );

  Widget _buildField(
      BuildContext context, PatientController ctrl, SymptomFieldDef field) {
    final Widget fieldWidget = field.type == SymptomFieldType.slider
        ? _buildSlider(context, ctrl, field)
        : _buildToggle(context, ctrl, field);

    return Padding(
      padding:
          EdgeInsets.only(bottom: Utility(context).dynamicWidthPixel(14)),
      child: _SectionCard(
        icon: _iconFor(field.id),
        title: field.labelKey.tr,
        child: fieldWidget,
      ),
    );
  }

  Widget _buildSlider(
      BuildContext context, PatientController ctrl, SymptomFieldDef field) {
    final value = (ctrl.getSymptomValue(
            field.id, field.defaultSliderValue ?? field.min ?? 0.0) as num)
        .toDouble();
    final min = field.min ?? 0.0;
    final max = field.max ?? 100.0;
    final isAlert = _isAlert(field.id, value);

    return Column(
      children: [
        Text(
          _formatValue(field.id, value),
          style: Utility(context).textTheme.titleLarge?.copyWith(
                color: isAlert ? AppColors().red : AppColors().green,
                fontWeight: FontWeight.bold,
              ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: field.divisions ?? 100,
          activeColor:
              isAlert ? AppColors().red : AppColors().mainBlueColor,
          label: _formatValue(field.id, value),
          onChanged: (v) => ctrl.setSymptomValue(field.id, v),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatValue(field.id, min),
                style: Utility(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors().grey1)),
            Text(_formatValue(field.id, max),
                style: Utility(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors().grey1)),
          ],
        ),
      ],
    );
  }

  Widget _buildToggle(
      BuildContext context, PatientController ctrl, SymptomFieldDef field) {
    final value =
        ctrl.getSymptomValue(field.id, field.defaultToggleValue ?? false)
            as bool;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value ? 'yes'.tr : 'no'.tr,
          style: Utility(context).textTheme.bodyMedium?.copyWith(
                color: value ? AppColors().red : AppColors().green,
                fontWeight: FontWeight.w600,
              ),
        ),
        Switch(
          value: value,
          activeColor: AppColors().red,
          inactiveThumbColor: AppColors().green,
          inactiveTrackColor: AppColors().green.withOpacity(0.3),
          onChanged: (v) => ctrl.setSymptomValue(field.id, v),
        ),
      ],
    );
  }

  bool _isAlert(String id, double v) {
    switch (id) {
      case 'fever':
        return v >= 38.0;
      case 'oxygen':
        return v < 90;
      case 'painLevel':
        return v >= 7;
      default:
        return false;
    }
  }

  String _formatValue(String id, double v) {
    switch (id) {
      case 'fever':
        return '${v.toStringAsFixed(1)} °C';
      case 'oxygen':
        return '${v.toStringAsFixed(0)} %';
      case 'heartRate':
        return '${v.toStringAsFixed(0)} bpm';
      case 'painLevel':
        return v.toStringAsFixed(0);
      case 'lesionSize':
        return '${v.toStringAsFixed(1)} cm';
      default:
        return v.toStringAsFixed(1);
    }
  }

  IconData _iconFor(String id) {
    switch (id) {
      case 'fever':
        return Icons.thermostat;
      case 'cough':
        return Icons.air;
      case 'oxygen':
        return Icons.favorite_outline;
      case 'chestPain':
        return Icons.heart_broken_outlined;
      case 'heartRate':
        return Icons.monitor_heart_outlined;
      case 'painLevel':
        return Icons.sentiment_very_dissatisfied_outlined;
      case 'swelling':
        return Icons.water_outlined;
      case 'itching':
        return Icons.grain_outlined;
      case 'lesionSize':
        return Icons.straighten_outlined;
      default:
        return Icons.medical_information_outlined;
    }
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Utility(context).dynamicWidthPixel(16)),
      decoration: BoxDecoration(
        color: AppColors().white,
        borderRadius:
            BorderRadius.circular(Utility(context).dynamicWidthPixel(14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  color: AppColors().mainBlueColor,
                  size: Utility(context).dynamicTextSize(20)),
              SizedBox(width: Utility(context).dynamicWidthPixel(8)),
              Text(title,
                  style: Utility(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
            ],
          ),
          SizedBox(height: Utility(context).dynamicWidthPixel(12)),
          child,
        ],
      ),
    );
  }
}
