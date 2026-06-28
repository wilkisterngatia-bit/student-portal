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

  int get total => cat1 + cat2 + examScore;

  String get grade {
    if (total >= 80) return 'A';
    if (total >= 70) return 'B';
    if (total >= 60) return 'C';
    if (total >= 50) return 'D';
    return 'E';
  }
}

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
      final seed = data[i]['id'] as int;
      final cat1 = 9 + (seed % 6);
      final cat2 = 8 + ((seed * 3) % 7);
      final examScore = 45 + ((seed * 5) % 26);

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
