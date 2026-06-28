import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/exam_registration_data.dart';

class ExamRegistrationEntry {
  final ExamType type;
  final String unitCode;
  final String? reason;
  final DateTime submittedAt;

  ExamRegistrationEntry({
    required this.type,
    required this.unitCode,
    required this.submittedAt,
    this.reason,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'unitCode': unitCode,
        'reason': reason,
        'submittedAt': submittedAt.toIso8601String(),
      };

  factory ExamRegistrationEntry.fromJson(Map<String, dynamic> json) {
    return ExamRegistrationEntry(
      type: ExamType.values.firstWhere((t) => t.name == json['type']),
      unitCode: json['unitCode'] as String,
      reason: json['reason'] as String?,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }
}

class ExamRegistrationStore {
  static const _key = 'exam_registrations';

  static Future<List<ExamRegistrationEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((e) => ExamRegistrationEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  static Future<void> add(ExamRegistrationEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getAll();
    existing.insert(0, entry);
    final encoded = json.encode(existing.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
