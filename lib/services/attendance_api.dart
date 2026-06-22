import 'dart:convert';
import 'package:http/http.dart' as http;

class UnitAttendance {
  final String unitCode;
  final int attended;
  final int totalSessions;

  const UnitAttendance({
    required this.unitCode,
    required this.attended,
    required this.totalSessions,
  });

  double get rate => totalSessions == 0 ? 0 : attended / totalSessions;
}

class AttendanceRecord {
  final List<UnitAttendance> units;
  final DateTime lastSynced;

  const AttendanceRecord({required this.units, required this.lastSynced});

  int get totalAttended => units.fold(0, (sum, u) => sum + u.attended);
  int get totalSessions => units.fold(0, (sum, u) => sum + u.totalSessions);
  double get overallRate => totalSessions == 0 ? 0 : totalAttended / totalSessions;
}

/// Reads attendance data that originates from the classroom door
/// biometric scanners. In a real deployment, the scanners log each
/// fingerprint match to the institution's central system, and this
/// app only ever reads that record back via a REST endpoint — the
/// app has no connection to the physical scanner hardware itself.
/// Here we call a public test API and map the response onto a
/// believable attendance log, following the same async fetch +
/// JSON decode pattern used for Results and Fees.
class AttendanceApi {
  static Future<AttendanceRecord> fetchAttendance() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/users/2/posts');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Server error (${response.statusCode})');
    }

    final List<dynamic> data = json.decode(response.body);
    const unitCodes = ['BIT 4107', 'BIT 4102', 'BIT 4105', 'BIT 4108', 'BIT 4109'];

    final units = <UnitAttendance>[];
    for (int i = 0; i < unitCodes.length; i++) {
      final seed = (data.length > i ? data[i]['id'] as int : i + 1);
      final total = 10 + (seed % 3);
      final missed = seed % 4;
      final attended = (total - missed).clamp(0, total);
      units.add(UnitAttendance(
        unitCode: unitCodes[i],
        attended: attended,
        totalSessions: total,
      ));
    }

    return AttendanceRecord(units: units, lastSynced: DateTime.now());
  }
}
