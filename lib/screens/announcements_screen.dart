import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_header.dart';
import '../services/announcements_api.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<Announcement> _announcements = [];
  Set<String> _readIds = {};
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
      // Capture read state before marking everything read, so we can
      // still show the unread dot for this one viewing — it then
      // clears on the next visit since these get marked read here.
      final readIds = await AnnouncementsApi.getReadIds();
      await AnnouncementsApi.markAllAsRead(announcements.map((a) => a.id).toList());
      setState(() {
        _announcements = announcements;
        _readIds = readIds;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Could not load announcements. Check your connection and try again.';
        _isLoading = false;
      });
    }
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
              const SizedBox(height: AppSpacing.lg),
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
    if (_announcements.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none, size: 36, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.sm),
            Text('No announcements yet', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: _announcements.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final a = _announcements[index];
          final wasUnread = !_readIds.contains(a.id);
          final color = _categoryColor(a.category);

          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: wasUnread ? color.withOpacity(0.4) : AppColors.divider,
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
                        color: color.withOpacity(0.12),
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
        },
      ),
    );
  }
}
