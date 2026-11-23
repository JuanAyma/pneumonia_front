import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lungs_pneumonia_ai/core/models/diagnosis_model.dart';
import 'package:lungs_pneumonia_ai/core/models/patient_model.dart';
import 'package:lungs_pneumonia_ai/core/models/specialization_model.dart';

class DoctorController extends GetxController {
  static DoctorController get instance => Get.find();

  final List<PatientModel> patients = [
    PatientModel(
      id: 'p001',
      name: 'Juan Pérez Torres',
      dni: '12345678',
      age: 45,
      phone: '999888777',
      hasAppAccess: true,
      username: 'juan.perez@salud.pe',
    ),
    PatientModel(
      id: 'p002',
      name: 'María López Ramos',
      dni: '87654321',
      age: 30,
      phone: '888777666',
      hasAppAccess: false,
      username: 'maria.lopez@salud.pe',
    ),
    PatientModel(
      id: 'p003',
      name: 'Carlos Quispe Huanca',
      dni: '45612378',
      age: 58,
      phone: '777666555',
      hasAppAccess: true,
      username: 'carlos.quispe@salud.pe',
    ),
  ];

  PatientModel? selectedPatient;
  XFile? xFileImage;
  SpecializationModel? selectedSpecialization;

  void selectPatient(PatientModel patient) {
    selectedPatient = patient;
    update();
  }

  void setImage(XFile image) {
    xFileImage = image;
    update();
  }

  void selectSpecialization(SpecializationModel spec) {
    selectedSpecialization = spec;
    selectedPatient = null;
    xFileImage = null;
    update();
  }

  void addPatient(PatientModel patient) {
    patients.add(patient);
    update();
  }

  void addDiagnosis(String patientId, DiagnosisModel diagnosis) {
    final patient = patients.firstWhere((p) => p.id == patientId);
    final idx = patient.diagnoses.indexWhere((d) => d.id == diagnosis.id);
    if (idx >= 0) {
      patient.diagnoses[idx] = diagnosis;
    } else {
      patient.diagnoses.insert(0, diagnosis);
    }
    update();
  }

  void approveDiagnosis(String patientId, String diagnosisId,
      {String? note, String? prescription}) {
    final patient = patients.firstWhere((p) => p.id == patientId);
    final diagnosis = patient.diagnoses.firstWhere((d) => d.id == diagnosisId);
    diagnosis.status = DiagnosisStatus.approved;
    diagnosis.doctorNote = note;
    diagnosis.prescription = prescription;
    update();
  }

  void rejectDiagnosis(String patientId, String diagnosisId, {String? note}) {
    final patient = patients.firstWhere((p) => p.id == patientId);
    final diagnosis = patient.diagnoses.firstWhere((d) => d.id == diagnosisId);
    diagnosis.status = DiagnosisStatus.rejected;
    diagnosis.doctorNote = note;
    update();
  }

  void toggleAppAccess(String patientId) {
    final patient = patients.firstWhere((p) => p.id == patientId);
    patient.hasAppAccess = !patient.hasAppAccess;
    update();
  }

  List<PatientModel> get patientsWithAccess =>
      patients.where((p) => p.hasAppAccess).toList();
}
