import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/feature_card.dart';
import '../data/timetable_data.dart';
import '../services/attendance_api.dart';
import '../services/student_api.dart';
import 'profile_screen.dart';
import 'course_registration_screen.dart';
import 'results_screen.dart';
import 'fees_screen.dart';
import 'timetable_screen.dart';
import 'attendance_screen.dart';
import 'exam_registration_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _username = 'Student';
  String? _photoUrl;
  int? _balance;
  bool _balanceLoading = true;
  int? _attendancePercent;
  bool _attendanceLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadProfilePhoto();
    _loadBalancePreview();
    _loadAttendancePreview();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('saved_username');
    if (saved != null && saved.isNotEmpty && mounted) {
      setState(() => _username = saved[0].toUpperCase() + saved.substring(1));
    }
  }

  /// Loads the same ID photo shown on the Profile screen. If nothing
  /// is cached yet (first run before Profile has ever been opened),
  /// fetches the official record once and caches the photo URL so the
  /// two screens never show different pictures.
  Future<void> _loadProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('profile_photo_url');
    if (cached != null && cached.isNotEmpty) {
      if (mounted) setState(() => _photoUrl = cached);
      return;
    }
    try {
      final record = await StudentApi.fetchStudentRecord();
      final photoUrl = record['photo_url'];
      if (photoUrl != null) {
        await prefs.setString('profile_photo_url', photoUrl);
      }
      if (mounted) setState(() => _photoUrl = photoUrl);
    } catch (_) {
      // Stay with initials if the fetch fails — Profile screen will retry.
    }
  }

  /// Quick fee balance for the summary card. Uses the same source as
  /// the Fees screen so the two numbers always agree.
  Future<void> _loadBalancePreview() async {
    try {
      final url = Uri.parse('https://jsonplaceholder.typicode.com/users/1');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _balance = 35000;
          _balanceLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _balanceLoading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _balanceLoading = false);
    }
  }

  /// Quick attendance preview for the summary card. Uses the same
  /// source as the Attendance screen so the two numbers always agree.
  Future<void> _loadAttendancePreview() async {
    try {
      final record = await AttendanceApi.fetchAttendance();
      if (!mounted) return;
      setState(() {
        _attendancePercent = (record.overallRate * 100).round();
        _attendanceLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _attendanceLoading = false);
    }
  }

  Future<void> _handleSignOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _initials() {
    if (_username.isEmpty) return 'S';
    return _username[0].toUpperCase();
  }

  String _fmt(int amount) {
    final str = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return 'KES $buf';
  }

  @override
  Widget build(BuildContext context) {
    final nextClass = TimetableData.nextClass(DateTime.now());

    final features = <_Feature>[
      _Feature('Results', 'View your grades', Icons.bar_chart_outlined,
          AppColors.amber, const ResultsScreen()),
      _Feature('Fees', 'Statement & balance', Icons.receipt_long_outlined,
          AppColors.coral, const FeesScreen()),
      _Feature('Attendance', 'Biometric attendance log', Icons.fingerprint,
          AppColors.inkPlum, const AttendanceScreen()),
      _Feature('Course registration', 'Register your units',
          Icons.menu_book_outlined, AppColors.sage, const CourseRegistrationScreen()),
      _Feature('Exam registration', 'First attempt, retakes & more',
          Icons.edit_calendar_outlined, AppColors.teal, const ExamRegistrationScreen()),
      _Feature('Timetable', 'Your class schedule', Icons.calendar_today_outlined,
          AppColors.violetLight, const TimetableScreen()),
      _Feature('Profile', 'Your personal details', Icons.badge_outlined,
          AppColors.violet, const ProfileScreen()),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting row with avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.heroGradient,
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: (_photoUrl != null && _photoUrl!.isNotEmpty)
                              ? Image.network(
                                  _photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Text(
                                      _initials(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    _initials(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_greeting(), style: Theme.of(context).textTheme.labelSmall),
                              const SizedBox(height: 2),
                              Text(
                                _username,
                                style: Theme.of(context).textTheme.headlineSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _handleSignOut,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.divider),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.logout, size: 20, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Summary hero card: next class + fee balance
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_filled,
                            size: 16, color: Colors.white.withOpacity(0.75)),
                        const SizedBox(width: 6),
                        Text('Next class',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      nextClass.unit,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${nextClass.day} · ${nextClass.time} · ${nextClass.room}',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(height: 1, color: Colors.white.withOpacity(0.15)),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Icon(Icons.fingerprint,
                            size: 16, color: Colors.white.withOpacity(0.75)),
                        const SizedBox(width: 6),
                        Text('Attendance',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75), fontSize: 12)),
                        const Spacer(),
                        _attendanceLoading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _attendancePercent != null ? '$_attendancePercent%' : '—',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                              ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(height: 1, color: Colors.white.withOpacity(0.15)),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined,
                            size: 16, color: Colors.white.withOpacity(0.75)),
                        const SizedBox(width: 6),
                        Text('Fee balance',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75), fontSize: 12)),
                        const Spacer(),
                        _balanceLoading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _balance != null ? _fmt(_balance!) : '—',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                              ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              Text('Quick access', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 2.3,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  final f = features[index];
                  return FeatureCard(
                    title: f.title,
                    subtitle: f.subtitle,
                    icon: f.icon,
                    accent: f.accent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => f.screen),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Widget screen;
  _Feature(this.title, this.subtitle, this.icon, this.accent, this.screen);
}
