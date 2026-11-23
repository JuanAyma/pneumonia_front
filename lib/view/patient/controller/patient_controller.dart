import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/models/patient_model.dart';
import 'package:lungs_pneumonia_ai/core/models/specialization_model.dart';

class PatientController extends GetxController {
  static PatientController get instance => Get.find();

  PatientModel? currentPatient;
  SpecializationModel? selectedSpecialization;
  Map<String, dynamic> symptomValues = {};
  bool symptomsRegistered = false;

  void setCurrentPatient(PatientModel patient) {
    currentPatient = patient;
    update();
  }

  void selectSpecialization(SpecializationModel spec) {
    selectedSpecialization = spec;
    symptomValues = _defaultValues(spec.symptomFields);
    symptomsRegistered = false;
    update();
  }

  void setSymptomValue(String fieldId, dynamic value) {
    symptomValues[fieldId] = value;
    update();
  }

  dynamic getSymptomValue(String fieldId, dynamic fallback) =>
      symptomValues[fieldId] ?? fallback;

  void registerSymptoms() {
    symptomsRegistered = true;
    update();
  }

  Map<String, dynamic> _defaultValues(List<SymptomFieldDef> fields) {
    final map = <String, dynamic>{};
    for (final field in fields) {
      if (field.type == SymptomFieldType.slider) {
        map[field.id] = field.defaultSliderValue ?? field.min ?? 0.0;
      } else {
        map[field.id] = field.defaultToggleValue ?? false;
      }
    }
    return map;
  }
}
