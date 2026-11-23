import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/models/specialization_model.dart';

class SpecializationController extends GetxController {
  static SpecializationController get instance => Get.find();

  final List<SpecializationModel> specializations = const [
    SpecializationModel(
      id: 'pulmonology',
      nameKey: 'specPulmonology',
      descriptionKey: 'specPulmonologyDesc',
      icon: Icons.air_outlined,
      color: Color(0xFF1565C0),
      modelPath: 'assets/tflite/resnet50_etapa2_rsna.tflite',
      labelsPath: 'assets/tflite/labels.txt',
      isAvailable: true,
      symptomFields: [
        SymptomFieldDef(
          id: 'fever',
          labelKey: 'fever',
          type: SymptomFieldType.slider,
          min: 35.0,
          max: 42.0,
          divisions: 70,
          defaultSliderValue: 36.5,
        ),
        SymptomFieldDef(
          id: 'cough',
          labelKey: 'cough',
          type: SymptomFieldType.toggle,
          defaultToggleValue: false,
        ),
        SymptomFieldDef(
          id: 'oxygen',
          labelKey: 'oxygenSat',
          type: SymptomFieldType.slider,
          min: 70.0,
          max: 100.0,
          divisions: 30,
          defaultSliderValue: 95.0,
        ),
      ],
    ),
    SpecializationModel(
      id: 'cardiology',
      nameKey: 'specCardiology',
      descriptionKey: 'specCardiologyDesc',
      icon: Icons.favorite_outline,
      color: Color(0xFFB71C1C),
      modelPath: 'assets/tflite/resnet50_etapa2_rsna.tflite',
      labelsPath: 'assets/tflite/labels.txt',
      isAvailable: false,
      symptomFields: [
        SymptomFieldDef(
          id: 'chestPain',
          labelKey: 'chestPain',
          type: SymptomFieldType.toggle,
          defaultToggleValue: false,
        ),
        SymptomFieldDef(
          id: 'heartRate',
          labelKey: 'heartRate',
          type: SymptomFieldType.slider,
          min: 40,
          max: 180,
          divisions: 140,
          defaultSliderValue: 75,
        ),
      ],
    ),
    SpecializationModel(
      id: 'traumatology',
      nameKey: 'specTraumatology',
      descriptionKey: 'specTraumatologyDesc',
      icon: Icons.accessibility_new_outlined,
      color: Color(0xFFE65100),
      modelPath: 'assets/tflite/resnet50_etapa2_rsna.tflite',
      labelsPath: 'assets/tflite/labels.txt',
      isAvailable: false,
      symptomFields: [
        SymptomFieldDef(
          id: 'painLevel',
          labelKey: 'painLevel',
          type: SymptomFieldType.slider,
          min: 0,
          max: 10,
          divisions: 10,
          defaultSliderValue: 0,
        ),
        SymptomFieldDef(
          id: 'swelling',
          labelKey: 'swelling',
          type: SymptomFieldType.toggle,
          defaultToggleValue: false,
        ),
      ],
    ),
    SpecializationModel(
      id: 'dermatology',
      nameKey: 'specDermatology',
      descriptionKey: 'specDermatologyDesc',
      icon: Icons.healing_outlined,
      color: Color(0xFF2E7D32),
      modelPath: 'assets/tflite/resnet50_etapa2_rsna.tflite',
      labelsPath: 'assets/tflite/labels.txt',
      isAvailable: false,
      symptomFields: [
        SymptomFieldDef(
          id: 'itching',
          labelKey: 'itching',
          type: SymptomFieldType.toggle,
          defaultToggleValue: false,
        ),
        SymptomFieldDef(
          id: 'lesionSize',
          labelKey: 'lesionSize',
          type: SymptomFieldType.slider,
          min: 0,
          max: 10,
          divisions: 10,
          defaultSliderValue: 1,
        ),
      ],
    ),
  ];
}
