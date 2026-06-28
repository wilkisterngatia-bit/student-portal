import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum StatusKind { positive, pending, negative, neutral }

class StatusPill extends StatelessWidget {
  final String label;
  final StatusKind kind;

  const StatusPill({super.key, required this.label, required this.kind});

  _PillColors get _colors {
    switch (kind) {
      case StatusKind.positive:
        return _PillColors(AppColors.sageSoft, AppColors.sage);
      case StatusKind.pending:
        return _PillColors(AppColors.amberSoft, AppColors.amber);
      case StatusKind.negative:
        return _PillColors(AppColors.coralSoft, AppColors.coral);
      case StatusKind.neutral:
        return _PillColors(AppColors.violetSoft, AppColors.violet);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PillColors {
  final Color background;
  final Color foreground;
  _PillColors(this.background, this.foreground);
}
