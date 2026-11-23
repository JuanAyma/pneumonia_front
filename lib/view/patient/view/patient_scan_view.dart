import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/constants/image_constants.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/view/home/view/widget/image_source_boxes.dart';
import 'package:lungs_pneumonia_ai/view/home/view/widget/title_with_description_widget.dart';
import 'package:lungs_pneumonia_ai/view/patient/controller/patient_controller.dart';
import 'package:lungs_pneumonia_ai/view/patient/view/patient_confirm_view.dart';
import 'package:lungs_pneumonia_ai/view/specialization/widget/specialization_selector_widget.dart';

class PatientScanView extends GetView<PatientController> {
  const PatientScanView({super.key});

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
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleWithDescription(
                    title: 'patientScanTitle',
                    description: 'patientScanDesc',
                  ),
                  SizedBox(height: Utility(context).dynamicWidthPixel(8)),
                  SpecializationSelectorWidget(
                    selected: ctrl.selectedSpecialization,
                    onSelected: ctrl.selectSpecialization,
                  ),
                  if (ctrl.selectedSpecialization != null) ...[
                    SizedBox(height: Utility(context).dynamicWidthPixel(20)),
                    Text(
                      'selectImageSource'.tr,
                      style: Utility(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors().grey1,
                          ),
                    ),
                    SizedBox(height: Utility(context).dynamicWidthPixel(8)),
                    ImageSourceWidget(
                      title: 'fromCamera',
                      iconPath: ImageConstants.instance.svgPath.camera,
                      onTap: () => _pickImage(context, ImageSource.camera),
                    ),
                    ImageSourceWidget(
                      title: 'fromGallery',
                      iconPath: ImageConstants.instance.svgPath.gallery,
                      onTap: () => _pickImage(context, ImageSource.gallery),
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

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 700,
    );
    if (picked != null) {
      Get.to(() => PatientConfirmView(xFileImage: picked));
    }
  }
}
