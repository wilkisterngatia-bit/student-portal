import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum InsightTone { info, warning, positive }

/// A small callout that surfaces a rule-based "AI insight" derived
/// from data already on screen — e.g. an attendance or fees warning.
/// Clearly labeled as AI-generated so it's honest about being a
/// simulated assistant rather than presenting itself as fact from the
/// school's own systems.
class AiInsightCard extends StatelessWidget {
  final String message;
  final InsightTone tone;

  const AiInsightCard({super.key, required this.message, this.tone = InsightTone.info});

  _ToneColors get _colors {
    switch (tone) {
      case InsightTone.warning:
        return _ToneColors(AppColors.amberSoft, AppColors.amber);
      case InsightTone.positive:
        return _ToneColors(AppColors.sageSoft, AppColors.sage);
      case InsightTone.info:
        return _ToneColors(AppColors.violetSoft, AppColors.violet);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, size: 16, color: colors.foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI insight',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: colors.foreground)),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(fontSize: 12.5, color: colors.foreground, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToneColors {
  final Color background;
  final Color foreground;
  _ToneColors(this.background, this.foreground);
}
