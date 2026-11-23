import 'diagnosis_model.dart';

class PatientModel {
  final String id;
  String name;
  String dni;
  int age;
  String phone;
  bool hasAppAccess;
  String username;
  List<DiagnosisModel> diagnoses;

  PatientModel({
    required this.id,
    required this.name,
    required this.dni,
    required this.age,
    required this.phone,
    required this.hasAppAccess,
    required this.username,
    List<DiagnosisModel>? diagnoses,
  }) : diagnoses = diagnoses ?? [];
}
