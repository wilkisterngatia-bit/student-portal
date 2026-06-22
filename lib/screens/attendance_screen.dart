import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_header.dart';
import '../widgets/status_pill.dart';
import '../services/attendance_api.dart';
import '../services/virtual_session_store.dart';
import '../widgets/ai_insight_card.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  AttendanceRecord? _record;
  bool _isLoading = true;
  String _errorMessage = '';
  List<VirtualSessionRecord> _virtualSessions = [];

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
    _loadVirtualSessions();
  }

  Future<void> _loadVirtualSessions() async {
    final sessions = await VirtualSessionStore.getAll();
    if (mounted) setState(() => _virtualSessions = sessions);
  }

  Future<void> _fetchAttendance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final record = await AttendanceApi.fetchAttendance();
      setState(() {
        _record = record;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Could not reach the attendance system. Check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  /// Rule-based insight derived from the units already on screen — no
  /// external AI call, just thresholds applied to data the app already
  /// has. Flags the unit with the lowest attendance if it's below the
  /// typical 75% eligibility threshold; otherwise gives positive
  /// reinforcement.
  Widget _buildAttendanceInsight(AttendanceRecord record) {
    if (record.units.isEmpty) return const SizedBox.shrink();

    final lowest = record.units.reduce((a, b) => a.rate < b.rate ? a : b);
    final lowestPercent = (lowest.rate * 100).round();

    if (lowestPercent < 75) {
      return AiInsightCard(
        tone: InsightTone.warning,
        message:
            'Your ${lowest.unitCode} attendance is $lowestPercent% — below the 75% typically required for exam eligibility. Consider attending upcoming sessions, including any virtual ones, to bring this up.',
      );
    }
    return AiInsightCard(
      tone: InsightTone.positive,
      message: 'You\'re meeting the attendance requirement in all your units. Keep it up.',
    );
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
              const ScreenHeader(eyebrow: 'ACADEMICS', title: 'Attendance'),
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

    if (_errorMessage.isNotEmpty || _record == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 36, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.sm),
            Text(_errorMessage, textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: _fetchAttendance, child: const Text('Retry')),
          ],
        ),
      );
    }

    final record = _record!;
    final overallPercent = (record.overallRate * 100).round();
    final kind = overallPercent >= 75
        ? StatusKind.positive
        : (overallPercent >= 50 ? StatusKind.pending : StatusKind.negative);

    return RefreshIndicator(
      onRefresh: () async {
        await _fetchAttendance();
        await _loadVirtualSessions();
      },
      child: ListView(
        children: [
          // Overall summary card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overall attendance',
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                const SizedBox(height: 6),
                Text('$overallPercent%',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  '${record.totalAttended} of ${record.totalSessions} sessions attended',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                ),
                const SizedBox(height: AppSpacing.sm),
                StatusPill(
                  label: overallPercent >= 75
                      ? 'Good standing'
                      : (overallPercent >= 50 ? 'Below recommended' : 'At risk'),
                  kind: kind,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildAttendanceInsight(record),

          const SizedBox(height: AppSpacing.lg),
          Text('By unit', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),

          // Bar chart per unit
          Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.lg, AppSpacing.sm, AppSpacing.sm),
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.divider),
            ),
            child: BarChart(
              BarChartData(
                maxY: 100,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: AppColors.divider, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 25,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= record.units.length) {
                          return const SizedBox.shrink();
                        }
                        final code = record.units[index].unitCode.split(' ').last;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(code,
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(record.units.length, (i) {
                  final unit = record.units[i];
                  final percent = unit.rate * 100;
                  final color = percent >= 75
                      ? AppColors.sage
                      : (percent >= 50 ? AppColors.amber : AppColors.coral);
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: percent,
                        color: color,
                        width: 22,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Per-unit list with counts
          ...record.units.map((unit) {
            final percent = (unit.rate * 100).round();
            return Padding(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(unit.unitCode, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text('${unit.attended} of ${unit.totalSessions} sessions',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    Text('$percent%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: percent >= 75
                                  ? AppColors.sage
                                  : (percent >= 50 ? AppColors.amber : AppColors.coral),
                            )),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: AppSpacing.lg),
          Text('Virtual sessions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Time logged in online lessons joined from this app',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),

          if (_virtualSessions.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.divider),
              ),
              child: Center(
                child: Text(
                  'No virtual lessons joined yet. Join one from your Timetable.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            ..._virtualSessions.map((session) {
              final minutes = (session.durationSeconds / 60).toStringAsFixed(1);
              return Padding(
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
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.violetSoft,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.videocam_outlined, size: 18, color: AppColors.violet),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(session.unit, style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('MMM d, h:mm a').format(session.joinedAt),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Text('$minutes min',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.violet,
                              )),
                    ],
                  ),
                ),
              );
            }),

          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              'Synced from classroom biometric scanners · ${DateFormat('MMM d, h:mm a').format(record.lastSynced)}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
