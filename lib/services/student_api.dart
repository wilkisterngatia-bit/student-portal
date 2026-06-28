import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentApi {
  static Future<Map<String, String>> fetchStudentRecord() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/users/3');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Server error (${response.statusCode})');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final fullName = data['name'] as String? ?? 'Student';
    final idSeed = data['id'] as int? ?? 1;

    return {
      'name': fullName,
      'admission_no': 'BIT/${2022 + (idSeed % 4)}/${1000 + idSeed * 37}',
      'course': 'BSc. Information Technology',
      'photo_url': 'https://i.pravatar.cc/300?img=${(idSeed % 70) + 1}',
    };
  }
}
