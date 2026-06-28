import 'package:shared_preferences/shared_preferences.dart';

class CourseRegistrationStore {
  static const _courseKey = 'registered_course';

  static Future<String?> getCurrentCourse() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_courseKey);
    return (value == null || value.isEmpty) ? null : value;
  }

  static Future<void> setCurrentCourse(String course) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_courseKey, course);
  }
}
