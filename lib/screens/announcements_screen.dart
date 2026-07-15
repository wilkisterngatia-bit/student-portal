import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/app_theme.dart';
import '../widgets/screen_header.dart';
import '../services/announcements_api.dart';
import '../services/gesture_handler_service.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  static const _dismissedKey = 'dismissed_announcement_ids';

  List<Announcement> _announcements = [];
  Set<String> _readIds = {};
  Set<String> _dismissedIds = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final announcements = await AnnouncementsApi.fetchAnnouncements();
      final readIds = await AnnouncementsApi.getReadIds();
      await AnnouncementsApi.markAllAsRead(announcements.map((a) => a.id).toList());

      final prefs = await SharedPreferences.getInstance();
      final rawDismissed = prefs.getString(_dismissedKey);
      final dismissedIds = rawDismissed != null
          ? Set<String>.from(json.decode(rawDismissed) as List)
          : <String>{};

      setState(() {
        _announcements = announcements;
        _readIds = readIds;
        _dismissedIds = dismissedIds;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Could not load announcements. Check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  /// Persists the dismissed-announcement set. This is deliberately
  /// kept local to this screen (SharedPreferences, not a server call)
  /// since "dismiss from my list" is a per-device UI preference, not
  /// data the school's records need to know about.
  Future<void> _saveDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dismissedKey, json.encode(_dismissedIds.toList()));
  }

  /// Swipe-left-to-dismiss, using the real GestureHandlerService from
  /// Week 8 rather than Flutter's built-in Dismissible — this is the
  /// gesture-handling class doing actual work in the app, instead of
  /// living only on its own demo tab. Includes an Undo action since a
  /// swipe-based destructive action needs an easy way back.
  void _dismiss(Announcement a) {
    setState(() => _dismissedIds.add(a.id));
    _saveDismissed();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dismissed "${a.title}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() => _dismissedIds.remove(a.id));
            _saveDismissed();
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Exams':
        return AppColors.amber;
      case 'Fees':
        return AppColors.coral;
      case 'Library':
        return AppColors.teal;
      case 'Timetable':
        return AppColors.violetLight;
      default:
        return AppColors.violet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(eyebrow: 'UPDATES', title: 'Announcements'),
              const SizedBox(height: 4),
              Text(
                'Swipe left on an announcement to dismiss it from your list.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11.5),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.violet));
    }
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 36, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.sm),
            Text(_errorMessage, textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final visible = _announcements.where((a) => !_dismissedIds.contains(a.id)).toList();

    if (visible.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none, size: 36, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _announcements.isEmpty ? 'No announcements yet' : 'All caught up — nothing left to show',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final a = visible[index];
          final wasUnread = !_readIds.contains(a.id);
          final color = _categoryColor(a.category);

          final card = Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: wasUnread ? color.withValues(alpha: 0.4) : AppColors.divider,
                width: wasUnread ? 1.4 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(a.category,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                    ),
                    if (wasUnread) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      DateFormat('MMM d').format(a.postedAt),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(a.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(a.body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          );

          // Real usage of GestureHandlerService (Week 8): swipe-left
          // on a card dismisses it. Tap/double-tap/long-press are
          // also live on this same wrapped widget, even though this
          // screen only acts on the swipe — the service still
          // recognizes all of them uniformly.
          return GestureHandlerService(
            onGesture: (event) {
              if (event.type == GestureType.swipeLeft) {
                _dismiss(a);
              }
            },
          ).wrap(child: card);
        },
      ),
    );
  }
}