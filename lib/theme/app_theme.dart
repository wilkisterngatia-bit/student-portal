import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the Student Portal.
///
/// Palette rationale:
/// - Ink Plum (primary): a deep, confident purple-black that reads as
///   institutional without being cold. Used for headers and primary text.
/// - Violet (accent): the action color — buttons, links, active states.
/// - Linen (surface): a warm off-white background instead of clinical
///   white, so screens feel calmer to read for long sessions (checking
///   grades, fees, timetables).
/// - Sage (success) / Amber (pending) / Coral (overdue): status colors
///   for fees and results so state is readable at a glance.
class AppColors {
  AppColors._();

  static const Color inkPlum = Color(0xFF3D2657);
  static const Color inkPlumDark = Color(0xFF241537);
  static const Color violet = Color(0xFF8B5FBF);
  static const Color violetLight = Color(0xFFB58CE0);
  static const Color violetSoft = Color(0xFFF1E9FA);

  static const Color linen = Color(0xFFFAF7F2);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F1A29);
  static const Color textSecondary = Color(0xFF6F6680);
  static const Color textMuted = Color(0xFFA39DB0);
  static const Color divider = Color(0xFFE6E0EE);

  static const Color sage = Color(0xFF2D8C5F);
  static const Color sageSoft = Color(0xFFE3F3EA);
  static const Color amber = Color(0xFFC98A1B);
  static const Color amberSoft = Color(0xFFFBF0DC);
  static const Color coral = Color(0xFFD15B4C);
  static const Color coralSoft = Color(0xFFFCE8E4);

  static const Color teal = Color(0xFF2D7F8C);
  static const Color tealSoft = Color(0xFFE1F0F2);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [inkPlum, Color(0xFF5B3A82)],
  );
}

class AppText {
  AppText._();

  static TextTheme get textTheme => TextTheme(
        displaySmall: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.card,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 0.6,
        ),
      );
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  AppRadius._();
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 22;
  static const double pill = 100;
}

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.linen,
    primaryColor: AppColors.inkPlum,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.inkPlum,
      secondary: AppColors.violet,
      surface: AppColors.card,
      error: AppColors.coral,
    ),
    textTheme: AppText.textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.violet,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.violet.withOpacity(0.4),
        elevation: 0,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: GoogleFonts.inter(
        color: AppColors.textMuted,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.violet, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.coral),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.inkPlumDark,
      contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 13),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    ),
  );
}
