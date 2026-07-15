import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_header.dart';
import '../data/timetable_data.dart';
import 'check_in_screen.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final byDay = <String, List<ClassSlot>>{};
    for (final slot in TimetableData.slots) {
      byDay.putIfAbsent(slot.day, () => []).add(slot);
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const ScreenHeader(eyebrow: 'SCHEDULE', title: 'Class timetable'),
            const SizedBox(height: AppSpacing.lg),
            ...byDay.entries.map((entry) => _DaySection(day: entry.key, slots: entry.value)),
          ],
        ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final String day;
  final List<ClassSlot> slots;
  const _DaySection({required this.day, required this.slots});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: AppSpacing.sm),
          ...slots.map((slot) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: slot.isOnline ? AppColors.violet : AppColors.violetLight,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(slot.unit,
                                      style: Theme.of(context).textTheme.titleMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                if (slot.isOnline) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.violetSoft,
                                      borderRadius: BorderRadius.circular(AppRadius.pill),
                                    ),
                                    child: const Text('Online',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.inkPlum)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text('${slot.time} · ${slot.room}',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      if (slot.isOnline) ...[
                        const SizedBox(width: AppSpacing.sm),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckInScreen(
                                unit: slot.unit,
                                day: slot.day,
                                time: slot.time,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          child: const Text('Join', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}