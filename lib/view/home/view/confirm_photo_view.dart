import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lungs_pneumonia_ai/core/base/components/button/base_button.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import '../../../core/base/components/popup/general_popup.dart';
import '../../process/view/process_view.dart';
import '../controller/home_controller.dart';
import 'widget/title_with_description_widget.dart';

class ConfirmPhotoView extends GetView<HomeController> {
  final XFile? xFileImage;
  const ConfirmPhotoView({super.key, this.xFileImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundColor,
      body: Padding(
        padding: EdgeInsets.only(
          right: Utility(context).dynamicWidthPixel(26),
          left: Utility(context).dynamicWidthPixel(26),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TitleWithDescription(title: "confirmPhoto", description: "confirmPhotoDescription", isBackButtonActive: true),
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
                onPressed: () {
                  BaseDialog.show(
                    context: context,
                    text: "warningText".tr,
                    buttonText: "understand".tr,
                    onTap: () {
                      Get.to(const ProcessView());
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
              onPressed: () {
                xFileImage == null;
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
