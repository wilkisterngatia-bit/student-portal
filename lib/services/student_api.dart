import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simulates fetching the student's official record from the
/// institution's server. In a real system this would call a school
/// REST endpoint (e.g. GET /api/students/me) using the logged-in
/// student's session token. Here we call a public test API and map
/// its response onto a believable student profile so the async
/// fetch -> JSON decode -> UI populate pattern is real and working,
/// consistent with the Results and Fees screens.
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
      // The student's ID photo on file with the school, returned as
      // part of the same official record fetch — not something the
      // student uploads or edits from within the app. The seed keeps
      // the same face showing up on every fetch for this account,
      // simulating a stored institutional photo rather than a random
      // one each time.
      'photo_url': 'https://i.pravatar.cc/300?img=${(idSeed % 70) + 1}',
    };
  }
}
