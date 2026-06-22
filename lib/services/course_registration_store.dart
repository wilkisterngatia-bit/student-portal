import 'package:shared_preferences/shared_preferences.dart';

/// Stores the student's currently registered course, set from the
/// Course Registration screen. This is the one piece of academic
/// record that legitimately changes through student action — unlike
/// name, admission number, or photo, which only the school can set.
/// The Profile screen reads this value to show what the student is
/// currently registered under.
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
