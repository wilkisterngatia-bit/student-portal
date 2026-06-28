import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Announcement {
  final String id;
  final String title;
  final String body;
  final DateTime postedAt;
  final String category;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.postedAt,
    required this.category,
  });
}

class AnnouncementsApi {
  static const _readIdsKey = 'announcement_read_ids';

  static Future<List<Announcement>> fetchAnnouncements() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=6');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Server error (${response.statusCode})');
    }

    final List<dynamic> data = json.decode(response.body);
    const categories = ['Exams', 'Fees', 'General', 'Library', 'Timetable'];
    const titles = [
      'Exam timetable released for this semester',
      'Fee payment deadline extended',
      'Library hours extended during exam week',
      'Mid-semester break dates announced',
      'New online learning resources added',
      'Special exam application window now open',
    ];
    const bodies = [
      'The full exam timetable is now available. Check your Timetable screen for your specific slots and venues.',
      'Students now have an additional two weeks to clear outstanding balances before the original deadline.',
      'The library will remain open until 10pm on weekdays during the exam period to support revision.',
      'Classes will be suspended for the mid-semester break starting next Monday. Regular classes resume the following week.',
      'Additional reading materials and past papers have been added to the Library & Resources section.',
      'Students who missed a first-sitting exam for a valid reason can now apply under Exam registration.',
    ];

    final announcements = <Announcement>[];
    for (int i = 0; i < data.length; i++) {
      final seed = data[i]['id'] as int;
      announcements.add(Announcement(
        id: 'ann_$seed',
        title: titles[i % titles.length],
        body: bodies[i % bodies.length],
        postedAt: DateTime.now().subtract(Duration(hours: seed * 7)),
        category: categories[seed % categories.length],
      ));
    }

    announcements.sort((a, b) => b.postedAt.compareTo(a.postedAt));
    return announcements;
  }

  static Future<Set<String>> getReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_readIdsKey) ?? [];
    return list.toSet();
  }

  static Future<void> markAsRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getReadIds();
    current.add(id);
    await prefs.setStringList(_readIdsKey, current.toList());
  }

  static Future<void> markAllAsRead(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getReadIds();
    current.addAll(ids);
    await prefs.setStringList(_readIdsKey, current.toList());
  }
}
