import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lungs_pneumonia_ai/core/base/components/button/base_button.dart';
import 'package:lungs_pneumonia_ai/core/base/components/popup/general_popup.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/view/doctor/controller/doctor_process_controller.dart';
import 'package:lungs_pneumonia_ai/view/doctor/view/doctor_process_view.dart';
import 'package:lungs_pneumonia_ai/view/home/view/widget/title_with_description_widget.dart';
// ignore_for_file: use_build_context_synchronously

class DoctorConfirmView extends StatelessWidget {
  final XFile? xFileImage;
  const DoctorConfirmView({super.key, this.xFileImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Utility(context).dynamicWidthPixel(26),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleWithDescription(
              title: 'confirmPhoto',
              description: 'confirmPhotoDescription',
              isBackButtonActive: true,
            ),
            Padding(
              padding: EdgeInsets.only(
                top: Utility(context).dynamicWidthPixel(90),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  Utility(context).dynamicHeightPixel(15),
                ),
                child: Image.file(
                  io.File(xFileImage!.path),
                  width: Utility(context).dynamicWidth(1),
                  height: Utility(context).dynamicWidthPixel(230),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: Utility(context).dynamicWidth(1),
                    height: Utility(context).dynamicWidthPixel(230),
                    color: Colors.grey.withOpacity(0.1),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_outlined,
                            color: Colors.grey, size: 40),
                        SizedBox(height: 8),
                        Text('No se pudo cargar la imagen',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: Utility(context).dynamicWidthPixel(90),
                bottom: Utility(context).dynamicWidthPixel(20),
              ),
              child: BaseButton(
                buttonText: 'confirm'.tr,
                backgroundColor: AppColors().mainBlueColor,
                onPressed: () {
                  BaseDialog.show(
                    context: context,
                    text: 'warningText'.tr,
                    buttonText: 'understand'.tr,
                    onTap: () {
                      Get.delete<DoctorProcessController>(force: true);
                      Get.put(DoctorProcessController());
                      Get.to(() => const DoctorProcessView());
                    },
                  );
                },
              ),
            ),
            BaseButton(
              buttonText: 'reselect'.tr,
              borderColor: AppColors().mainBlueColor,
              backgroundColor: Colors.transparent,
              buttonTextColor: AppColors().mainBlueColor,
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
