import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/constants/image_constants.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/core/models/patient_model.dart';
import 'package:lungs_pneumonia_ai/view/doctor/controller/doctor_controller.dart';
import 'package:lungs_pneumonia_ai/view/doctor/view/doctor_confirm_view.dart';
import 'package:lungs_pneumonia_ai/view/home/view/widget/image_source_boxes.dart';
import 'package:lungs_pneumonia_ai/view/home/view/widget/title_with_description_widget.dart';
import 'package:lungs_pneumonia_ai/view/specialization/widget/specialization_selector_widget.dart';

class DoctorScanView extends GetView<DoctorController> {
  const DoctorScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Utility(context).dynamicWidthPixel(26),
        ),
        child: GetBuilder<DoctorController>(
          builder: (ctrl) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleWithDescription(
                    title: 'scan',
                    description: 'doctorScanDesc',
                  ),
                  SizedBox(height: Utility(context).dynamicWidthPixel(16)),
                  SpecializationSelectorWidget(
                    selected: ctrl.selectedSpecialization,
                    onSelected: ctrl.selectSpecialization,
                  ),
                  if (ctrl.selectedSpecialization != null) ...[
                    SizedBox(height: Utility(context).dynamicWidthPixel(20)),
                    _PatientSelector(
                      patients: ctrl.patients,
                      selected: ctrl.selectedPatient,
                      onSelected: ctrl.selectPatient,
                    ),
                  ],
                  if (ctrl.selectedSpecialization != null &&
                      ctrl.selectedPatient != null) ...[
                    SizedBox(height: Utility(context).dynamicWidthPixel(20)),
                    Text(
                      'selectImageSource'.tr,
                      style: Utility(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors().grey1,
                          ),
                    ),
                    SizedBox(height: Utility(context).dynamicWidthPixel(12)),
                    ImageSourceWidget(
                      title: 'fromCamera',
                      iconPath: ImageConstants.instance.svgPath.camera,
                      onTap: () =>
                          _pickImage(context, ImageSource.camera, ctrl),
                    ),
                    ImageSourceWidget(
                      title: 'fromGallery',
                      iconPath: ImageConstants.instance.svgPath.gallery,
                      onTap: () =>
                          _pickImage(context, ImageSource.gallery, ctrl),
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

  Future<void> _pickImage(
      BuildContext context, ImageSource source, DoctorController ctrl) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 700,
    );
    if (picked != null) {
      ctrl.setImage(picked);
      Get.to(() => DoctorConfirmView(xFileImage: picked));
    }
  }
}

class _PatientSelector extends StatelessWidget {
  final List<PatientModel> patients;
  final PatientModel? selected;
  final ValueChanged<PatientModel> onSelected;

  const _PatientSelector({
    required this.patients,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'selectPatient'.tr,
          style: Utility(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: Utility(context).dynamicWidthPixel(10)),
        Container(
          decoration: BoxDecoration(
            color: AppColors().white,
            borderRadius: BorderRadius.circular(
                Utility(context).dynamicWidthPixel(14)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PatientModel>(
              value: selected,
              hint: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Utility(context).dynamicWidthPixel(16)),
                child: Text(
                  'selectPatientHint'.tr,
                  style: Utility(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors().grey1),
                ),
              ),
              isExpanded: true,
              padding: EdgeInsets.symmetric(
                  horizontal: Utility(context).dynamicWidthPixel(16)),
              borderRadius: BorderRadius.circular(
                  Utility(context).dynamicWidthPixel(14)),
              items: patients
                  .map((p) => DropdownMenuItem<PatientModel>(
                        value: p,
                        child: Text('${p.name} — DNI: ${p.dni}',
                            style: Utility(context).textTheme.bodyMedium),
                      ))
                  .toList(),
              onChanged: (p) {
                if (p != null) onSelected(p);
              },
            ),
          ),
        ),
      ],
    );
  }
}
