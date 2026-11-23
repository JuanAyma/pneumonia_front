import 'package:lungs_pneumonia_ai/core/network/api_service.dart';

enum DiagnosisStatus {
  submitted,
  qualityCheck,
  analyzing,
  correlating,
  pendingReview,
  approved,
  rejected,
  completed,
}

class DiagnosisModel {
  final String id;
  final String patientId;
  final String imagePath;
  final String? gradCamUrl;
  final bool hasPneumonia;
  final double confidence;
  final DateTime date;
  final DateTime? updatedAt;
  final String specializationId;
  final String imageSource;
  final Map<String, dynamic>? symptoms;
  final List<String> findings;
  final List<String> recommendedActions;
  final int? urgencyHours;
  DiagnosisStatus status;
  String? doctorNote;
  String? prescription;
  String? riskLevel;

  DiagnosisModel({
    required this.id,
    required this.patientId,
    required this.imagePath,
    this.gradCamUrl,
    required this.hasPneumonia,
    required this.confidence,
    required this.date,
    this.updatedAt,
    this.specializationId = 'pulmonology',
    this.imageSource = 'UNKNOWN',
    this.symptoms,
    this.findings = const [],
    this.recommendedActions = const [],
    this.urgencyHours,
    this.status = DiagnosisStatus.pendingReview,
    this.doctorNote,
    this.prescription,
    this.riskLevel,
  });

  static String get _backendBase => ApiService.baseUrl.replaceAll('/v1', '');

  static String _resolveUrl(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    if (raw.startsWith('http')) return raw;
    return '$_backendBase$raw';
  }

  factory DiagnosisModel.fromBackend(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>?;
    return DiagnosisModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      imagePath: _resolveUrl(json['imageUrl'] as String?),
      gradCamUrl: result != null
          ? _resolveUrl(result['gradCamUrl'] as String?).nullIfEmpty
          : null,
      hasPneumonia: (result?['hasPneumonia'] as bool?) ?? false,
      confidence: ((result?['confidence']) ?? 0.0).toDouble(),
      date: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      specializationId:
          (json['specializationId'] as String?) ?? 'pulmonology',
      imageSource: (json['imageSource'] as String?) ?? 'UNKNOWN',
      symptoms: json['symptoms'] != null
          ? Map<String, dynamic>.from(json['symptoms'] as Map)
          : null,
      findings: (result?['findings'] as List?)
              ?.map((e) {
                if (e is String) return e;
                if (e is Map) return (e['description'] as String?) ?? '';
                return e.toString();
              })
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      recommendedActions: (result?['recommendedActions'] as List?)
              ?.map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      urgencyHours: result?['urgencyHours'] as int?,
      status: _parseStatus(json['status'] as String?),
      doctorNote: json['doctorNote'] as String?,
      prescription: json['prescription'] as String?,
      riskLevel: result?['riskLevel'] as String?,
    );
  }

  static DiagnosisStatus _parseStatus(String? s) {
    switch (s) {
      case 'SUBMITTED':
        return DiagnosisStatus.submitted;
      case 'QUALITY_CHECK':
        return DiagnosisStatus.qualityCheck;
      case 'ANALYZING':
        return DiagnosisStatus.analyzing;
      case 'CORRELATING':
        return DiagnosisStatus.correlating;
      case 'PENDING_REVIEW':
        return DiagnosisStatus.pendingReview;
      case 'APPROVED':
        return DiagnosisStatus.approved;
      case 'REJECTED':
        return DiagnosisStatus.rejected;
      case 'COMPLETED':
        return DiagnosisStatus.completed;
      default:
        return DiagnosisStatus.pendingReview;
    }
  }
}

extension _StringNull on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
