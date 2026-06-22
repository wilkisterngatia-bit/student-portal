import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Consistent header used across every sub-screen: back arrow, an eyebrow
/// label, and a title. Keeping this in one place means every screen's
/// header lines up identically instead of each one reinventing padding.
class ScreenHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final VoidCallback? onBack;

  const ScreenHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onBack ?? () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.divider),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(eyebrow, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(title, style: Theme.of(context).textTheme.displaySmall),
      ],
    );
  }
}
