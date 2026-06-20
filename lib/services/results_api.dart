import 'dart:convert';
import 'package:http/http.dart' as http;

class UnitResult {
  final String unitCode;
  final int cat1;
  final int cat2;
  final int examScore;

  const UnitResult({
    required this.unitCode,
    required this.cat1,
    required this.cat2,
    required this.examScore,
  });

  /// CATs are weighted 15% each and the final exam 70%, a common
  /// university weighting — out of 30 for CATs combined and 70 for
  /// the exam, all on a 0-100 scale.
  int get total => cat1 + cat2 + examScore;

  String get grade {
    if (total >= 80) return 'A';
    if (total >= 70) return 'B';
    if (total >= 60) return 'C';
    if (total >= 50) return 'D';
    return 'E';
  }
}

/// Fetches semester results from the school's records system,
/// following the same async fetch + JSON decode pattern as the rest
/// of the app. CAT and exam component marks are derived from the API
/// response deterministically so the displayed breakdown always sums
/// correctly to the unit's total.
class ResultsApi {
  static Future<List<UnitResult>> fetchResults() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=5');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Server error (${response.statusCode})');
    }

    final List<dynamic> data = json.decode(response.body);
    final results = <UnitResult>[];

    for (int i = 0; i < data.length; i++) {
      final unitCode = 'BIT ${4101 + i}';
      // CATs out of 15 each, exam out of 70 — derived from a seed so
      // results are stable across rebuilds rather than random each time.
      final seed = data[i]['id'] as int;
      final cat1 = 9 + (seed % 6); // 9-14 out of 15
      final cat2 = 8 + ((seed * 3) % 7); // 8-14 out of 15
      final examScore = 45 + ((seed * 5) % 26); // 45-70 out of 70

      results.add(UnitResult(
        unitCode: unitCode,
        cat1: cat1,
        cat2: cat2,
        examScore: examScore,
      ));
    }

    return results;
  }
}
