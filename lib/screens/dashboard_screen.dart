import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/feature_card.dart';
import '../data/timetable_data.dart';
import '../services/attendance_api.dart';
import '../services/student_api.dart';
import '../services/announcements_api.dart';
import 'profile_screen.dart';
import 'course_registration_screen.dart';
import 'results_screen.dart';
import 'fees_screen.dart';
import 'timetable_screen.dart';
import 'attendance_screen.dart';
import 'exam_registration_screen.dart';
import 'announcements_screen.dart';
import 'library_screen.dart';
import 'settings_screen.dart';
import 'search_screen.dart';

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
  bool _balanceError = false;

  int? _attendancePercent;
  bool _attendanceLoading = true;
  bool _attendanceError = false;

  int _unreadAnnouncements = 0;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadProfilePhoto();
    _loadBalancePreview();
    _loadAttendancePreview();
    _loadUnreadAnnouncements();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('saved_username');
    if (saved != null && saved.isNotEmpty && mounted) {
      setState(() => _username = saved[0].toUpperCase() + saved.substring(1));
    }
  }

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
      // Stay with initials if the fetch fails.
    }
  }

  Future<void> _loadBalancePreview() async {
    if (mounted) {
      setState(() {
        _balanceLoading = true;
        _balanceError = false;
      });
    }
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
        setState(() {
          _balanceLoading = false;
          _balanceError = true;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _balanceLoading = false;
        _balanceError = true;
      });
    }
  }

  Future<void> _loadAttendancePreview() async {
    if (mounted) {
      setState(() {
        _attendanceLoading = true;
        _attendanceError = false;
      });
    }
    try {
      final record = await AttendanceApi.fetchAttendance();
      if (!mounted) return;
      setState(() {
        _attendancePercent = (record.overallRate * 100).round();
        _attendanceLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _attendanceLoading = false;
        _attendanceError = true;
      });
    }
  }

  Future<void> _loadUnreadAnnouncements() async {
    try {
      final announcements = await AnnouncementsApi.fetchAnnouncements();
      final readIds = await AnnouncementsApi.getReadIds();
      final unread = announcements.where((a) => !readIds.contains(a.id)).length;
      if (mounted) setState(() => _unreadAnnouncements = unread);
    } catch (_) {
      // Stay at 0.
    }
  }

  /// UX improvement #2: pull-to-refresh for the whole summary card.
  /// Re-runs every fetch that feeds the hero card and the announcement badge.
  Future<void> _onRefresh() async {
    await Future.wait([
      _loadBalancePreview(),
      _loadAttendancePreview(),
      _loadUnreadAnnouncements(),
    ]);
  }

  Widget _headerIconButton({
    required IconData icon,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.divider),
        ),
        alignment: Alignment.center,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            if (badgeCount > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  constraints: const BoxConstraints(minWidth: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.coral,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badgeCount > 9 ? '9+' : '$badgeCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
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

  /// UX improvement #1: shimmering skeleton placeholder shown while a
  /// summary row is loading, instead of a small spinner.
  Widget _skeletonBar({double width = 54, double height = 14}) {
    return _ShimmerBox(width: width, height: height);
  }

  /// UX improvement #3: inline empty/error state with a retry action,
  /// shown when a summary row failed to load instead of a bare "—".
  Widget _retryChip(VoidCallback onRetry) {
    return InkWell(
      onTap: onRetry,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh, size: 14, color: Colors.white.withValues(alpha: 0.9)),
            const SizedBox(width: 4),
            Text(
              'Retry',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Picks the right widget for a summary row: skeleton, retry chip, or value.
  Widget _summaryValue({
    required bool loading,
    required bool error,
    required String? value,
    required VoidCallback onRetry,
  }) {
    if (loading) return _skeletonBar();
    if (error || value == null) return _retryChip(onRetry);
    return Text(
      value,
      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nextClass = TimetableData.nextClass(DateTime.now());

    // GPS tile removed — location is now captured silently at login
    // (see LocationService) instead of living on its own dashboard
    // tile, same reasoning as moving Camera into the class check-in
    // flow: these are device capabilities used inside real
    // workflows, not standalone demo screens.
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
      _Feature('Announcements', 'School updates & news', Icons.campaign_outlined,
          AppColors.sky, const AnnouncementsScreen()),
      _Feature('Library & resources', 'Notes, papers & more', Icons.local_library_outlined,
          AppColors.rose, const LibraryScreen()),
    ];

    // Performance: decode the avatar at its actual on-screen pixel
    // size (48 logical px * devicePixelRatio) instead of whatever
    // resolution the source photo happens to be. Without this, a
    // typical 3000x4000 phone photo gets fully decoded into memory
    // just to be shrunk down to a 48px circle.
    final avatarCachePx = (48 * MediaQuery.of(context).devicePixelRatio).round();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.inkPlum,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              gradient: AppColors.heroGradient,
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: (_photoUrl != null && _photoUrl!.isNotEmpty)
                                ? Image.network(
                                    _photoUrl!,
                                    fit: BoxFit.cover,
                                    cacheWidth: avatarCachePx,
                                    cacheHeight: avatarCachePx,
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
                    Row(
                      children: [
                        _headerIconButton(
                          icon: Icons.search,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SearchScreen()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _headerIconButton(
                          icon: Icons.notifications_none,
                          badgeCount: _unreadAnnouncements,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
                            );
                            _loadUnreadAnnouncements();
                          },
                        ),
                        const SizedBox(width: 8),
                        _headerIconButton(
                          icon: Icons.settings_outlined,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

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
                              size: 16, color: Colors.white.withValues(alpha: 0.75)),
                          const SizedBox(width: 6),
                          Text('Next class',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
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
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Icon(Icons.fingerprint,
                              size: 16, color: Colors.white.withValues(alpha: 0.75)),
                          const SizedBox(width: 6),
                          Text('Attendance',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                          const Spacer(),
                          _summaryValue(
                            loading: _attendanceLoading,
                            error: _attendanceError,
                            value: _attendancePercent != null ? '$_attendancePercent%' : null,
                            onRetry: _loadAttendancePreview,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined,
                              size: 16, color: Colors.white.withValues(alpha: 0.75)),
                          const SizedBox(width: 6),
                          Text('Fee balance',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                          const Spacer(),
                          _summaryValue(
                            loading: _balanceLoading,
                            error: _balanceError,
                            value: _balance != null ? _fmt(_balance!) : null,
                            onRetry: _loadBalancePreview,
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

/// Simple shimmering placeholder box — no extra package required.
/// Pulses opacity between 0.35 and 0.85 on a loop while data is loading.
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  const _ShimmerBox({required this.width, required this.height});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }
}