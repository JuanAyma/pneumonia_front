import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lungs_pneumonia_ai/view/home/controller/home_controller.dart';
import '../../result/view/process_result_view.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class ProcessController extends GetxController {
  XFile? xFileImage;
  HomeController homeController = Get.find();

  @override
  Future<void> onInit() async {
    Get.put(HomeController());
    xFileImage = homeController.xFileImage;
    await loadModel();
    await classifyImage();
    navigateToPage();
    super.onInit();
  }

  navigateToPage() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.off(const ProcessResultView());
    });
  }

  String? result;

  Future loadModel() async {
    result = await Tflite.loadModel(
      model: "assets/tflite/resnet50_etapa2_rsna.tflite",
      labels: "assets/tflite/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
    update();
  }

  late List<dynamic> output;
  Future classifyImage() async {
    Tflite.runModelOnImage(
      path: xFileImage!.path,
      numResults: 2,
      threshold: 0.1,
      imageMean: 0,
      imageStd: 255,
    ).then((tfLiteOutput) {
      output = tfLiteOutput!;
    });
    update();
  }
}
