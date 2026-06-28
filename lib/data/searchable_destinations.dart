import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import '../screens/course_registration_screen.dart';
import '../screens/exam_registration_screen.dart';
import '../screens/results_screen.dart';
import '../screens/fees_screen.dart';
import '../screens/attendance_screen.dart';
import '../screens/timetable_screen.dart';
import '../screens/announcements_screen.dart';
import '../screens/library_screen.dart';
import '../screens/settings_screen.dart';

class SearchableDestination {
  final String title;
  final List<String> keywords;
  final IconData icon;
  final Widget Function() builder;

  const SearchableDestination({
    required this.title,
    required this.keywords,
    required this.icon,
    required this.builder,
  });

  bool matches(String query) {
    final q = query.toLowerCase();
    if (title.toLowerCase().contains(q)) return true;
    return keywords.any((k) => k.toLowerCase().contains(q));
  }
}

class SearchableDestinations {
  SearchableDestinations._();

  static final List<SearchableDestination> all = [
    SearchableDestination(
      title: 'Profile',
      keywords: ['name', 'admission', 'course', 'photo', 'id'],
      icon: Icons.badge_outlined,
      builder: () => const ProfileScreen(),
    ),
    SearchableDestination(
      title: 'Course registration',
      keywords: ['unit', 'semester', 'register', 'course'],
      icon: Icons.menu_book_outlined,
      builder: () => const CourseRegistrationScreen(),
    ),
    SearchableDestination(
      title: 'Exam registration',
      keywords: ['retake', 're-retake', 'special exam', 'first attempt'],
      icon: Icons.edit_calendar_outlined,
      builder: () => const ExamRegistrationScreen(),
    ),
    SearchableDestination(
      title: 'Results',
      keywords: ['grade', 'cat', 'marks', 'exam score'],
      icon: Icons.bar_chart_outlined,
      builder: () => const ResultsScreen(),
    ),
    SearchableDestination(
      title: 'Fees',
      keywords: ['balance', 'pay', 'statement', 'billed'],
      icon: Icons.receipt_long_outlined,
      builder: () => const FeesScreen(),
    ),
    SearchableDestination(
      title: 'Attendance',
      keywords: ['biometric', 'present', 'absent', 'virtual session'],
      icon: Icons.fingerprint,
      builder: () => const AttendanceScreen(),
    ),
    SearchableDestination(
      title: 'Timetable',
      keywords: ['schedule', 'class', 'online lesson', 'join'],
      icon: Icons.calendar_today_outlined,
      builder: () => const TimetableScreen(),
    ),
    SearchableDestination(
      title: 'Announcements',
      keywords: ['notification', 'news', 'update'],
      icon: Icons.campaign_outlined,
      builder: () => const AnnouncementsScreen(),
    ),
    SearchableDestination(
      title: 'Library & resources',
      keywords: ['notes', 'past paper', 'ebook', 'slides', 'download'],
      icon: Icons.local_library_outlined,
      builder: () => const LibraryScreen(),
    ),
    SearchableDestination(
      title: 'Settings',
      keywords: ['sign out', 'logout', 'preferences', 'notifications toggle'],
      icon: Icons.settings_outlined,
      builder: () => const SettingsScreen(),
    ),
  ];
}
