import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _tokenKey = 'jwt_access_token';
  // El Firewall de Windows está bloqueando el puerto 3000. Agrega la regla:
  //netsh advfirewall firewall add rule name="NestJS 3000" protocol=TCP dir=in localport=3000 action=allow

  // Android emulator → 10.0.2.2   |   real device → LAN IP de tu máquina (PC)
  static const String baseUrl = 'http://192.168.18.8:3000/v1';

  /// true  → usa el backend (AWS / servidor local)
  /// false → siempre inferencia TFLite en el dispositivo
  static const bool useBackend = true;

  static final _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  static String? _token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
    ));
  }

  static Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ── Auth ──────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await _dio.post('/auth/login',
        data: {'email': email, 'password': password});
    final data = response.data as Map<String, dynamic>;
    await _saveToken(data['accessToken'] as String);
    return data;
  }

  // ── Diagnoses ─────────────────────────────────────────

  static Future<Map<String, dynamic>> createDiagnosis({
    required String patientId,
    required String specializationId,
    required String imageSource,
    required Map<String, dynamic> symptoms,
    required String imagePath,
  }) async {
    final bytes = await File(imagePath).readAsBytes();
    final imageBase64 = base64Encode(bytes);
    final response = await _dio.post('/diagnoses', data: {
      'patientId': patientId,
      'specializationId': specializationId,
      'imageSource': imageSource,
      'symptoms': symptoms,
      'imageBase64': imageBase64,
    });
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getDiagnosis(String id) async {
    final response = await _dio.get('/diagnoses/$id');
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> validateDiagnosis(
    String id,
    String status, {
    String? doctorNote,
    String? prescription,
  }) async {
    final response = await _dio.post('/diagnoses/$id/validate', data: {
      'status': status,
      if (doctorNote != null && doctorNote.isNotEmpty) 'doctorNote': doctorNote,
      if (prescription != null && prescription.isNotEmpty)
        'prescription': prescription,
    });
    return response.data as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> getPatientDiagnoses(
      String patientId) async {
    final response = await _dio.get('/patients/$patientId/diagnoses');
    return (response.data as List).cast<Map<String, dynamic>>();
  }
}
