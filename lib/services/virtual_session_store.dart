import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VirtualSessionRecord {
  final String unit;
  final DateTime joinedAt;
  final int durationSeconds;

  VirtualSessionRecord({
    required this.unit,
    required this.joinedAt,
    required this.durationSeconds,
  });

  Map<String, dynamic> toJson() => {
        'unit': unit,
        'joinedAt': joinedAt.toIso8601String(),
        'durationSeconds': durationSeconds,
      };

  factory VirtualSessionRecord.fromJson(Map<String, dynamic> json) {
    return VirtualSessionRecord(
      unit: json['unit'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      durationSeconds: json['durationSeconds'] as int,
    );
  }
}

/// Stores how long the student stayed in each online lesson, locally
/// on the device via SharedPreferences. This is the app's own record
/// of virtual attendance — separate from the school's biometric door
/// scanner log, since virtual lessons have no physical door to scan
/// at.
class VirtualSessionStore {
  static const _key = 'virtual_sessions';

  static Future<List<VirtualSessionRecord>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((e) => VirtualSessionRecord.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.joinedAt.compareTo(a.joinedAt));
  }

  static Future<void> add(VirtualSessionRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getAll();
    existing.insert(0, record);
    final encoded = json.encode(existing.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
