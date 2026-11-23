import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/models/user_model.dart';
import 'package:lungs_pneumonia_ai/core/network/api_service.dart';
import 'package:lungs_pneumonia_ai/view/doctor/controller/doctor_controller.dart';
import 'package:lungs_pneumonia_ai/view/doctor/view/doctor_bottom_nav.dart';
import 'package:lungs_pneumonia_ai/view/patient/controller/patient_controller.dart';
import 'package:lungs_pneumonia_ai/view/patient/view/patient_bottom_nav.dart';
import '../view/login_view.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  UserModel? currentUser;

  Future<bool> login(String username, String password, UserRole role) async {
    try {
      final data = await ApiService.login(username.trim(), password);
      final user = data['user'] as Map<String, dynamic>;
      final backendRole = user['role'] as String;

      if (role == UserRole.doctor && backendRole != 'DOCTOR') return false;
      if (role == UserRole.patient && backendRole != 'PATIENT') return false;

      currentUser = UserModel(
        id: user['id'] as String,
        name: user['name'] as String,
        username: user['email'] as String,
        role: role,
      );

      if (role == UserRole.doctor) {
        Get.offAll(() => const DoctorBottomNavView());
      } else {
        final doctorCtrl = DoctorController.instance;
        final patient = doctorCtrl.patients.firstWhereOrNull(
          (p) => p.username.trim().toLowerCase() == username.trim().toLowerCase(),
        );
        final patientCtrl = Get.put(PatientController(), permanent: true);
        if (patient != null) {
          patientCtrl.setCurrentPatient(patient);
        }
        Get.offAll(() => const PatientBottomNavView());
      }
      return true;
    } on DioException {
      // Backend unreachable — fall back to local demo credentials
      return _localFallback(username, password, role);
    } catch (_) {
      return _localFallback(username, password, role);
    }
  }

  bool _localFallback(String username, String password, UserRole role) {
    if (role == UserRole.doctor) {
      if (username.trim() == 'doctor@hospital.com' && password == 'doctor123' ||
          username.trim() == 'doctor@salud.pe' && password == '1234') {
        currentUser = UserModel(
          id: 'user_doctor_001',
          name: 'Dr. García',
          username: username.trim(),
          role: UserRole.doctor,
        );
        Get.offAll(() => const DoctorBottomNavView());
        return true;
      }
    } else {
      final doctorCtrl = DoctorController.instance;
      final patient = doctorCtrl.patients.firstWhereOrNull(
        (p) => p.username.trim().toLowerCase() == username.trim().toLowerCase(),
      );
      if (patient != null && password == '1234') {
        currentUser = UserModel(
          id: patient.id,
          name: patient.name,
          username: username.trim(),
          role: UserRole.patient,
        );
        final patientCtrl = Get.put(PatientController(), permanent: true);
        patientCtrl.setCurrentPatient(patient);
        Get.offAll(() => const PatientBottomNavView());
        return true;
      }
    }
    return false;
  }

  void logout() {
    currentUser = null;
    ApiService.clearToken();
    Get.delete<PatientController>(force: true);
    Get.offAll(() => const LoginView());
  }
}
