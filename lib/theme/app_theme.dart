import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ---------------------------------------------------------------------
/// DESIGN TOKENS
/// Signature system: a "sentiment gradient" (coral -> amber -> mint) is
/// used everywhere a rating / score is shown, so the whole app reads as
/// one connected visual language rather than disconnected screens.
/// ---------------------------------------------------------------------
class AppColors {
  AppColors._();

  // Base
  static const Color ink = Color(0xFF12122B); // deep navy background
  static const Color inkElevated = Color(0xFF1B1B3D); // cards on dark
  static const Color surface = Color(0xFFF7F7FC); // light background
  static const Color surfaceCard = Color(0xFFFFFFFF);

  // Brand
  static const Color violet = Color(0xFF7C5CFC); // primary accent
  static const Color violetDeep = Color(0xFF5B3DE0);
  static const Color skyGlow = Color(0xFF4FD1FF);

  // Sentiment gradient (low -> high rating)
  static const Color sentimentLow = Color(0xFFFF6B6B); // coral
  static const Color sentimentMid = Color(0xFFFFB84D); // amber
  static const Color sentimentHigh = Color(0xFF2DD4A7); // mint

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B85);
  static const Color textOnDark = Color(0xFFF3F3FA);
  static const Color textOnDarkMuted = Color(0xFFA6A6C4);

  static const Color border = Color(0xFFE7E7F3);

  /// Returns a color along the sentiment gradient for a 0..1 value
  /// (e.g. rating/5).
  static Color sentimentColor(double t) {
    t = t.clamp(0.0, 1.0);
    if (t < 0.5) {
      return Color.lerp(sentimentLow, sentimentMid, t / 0.5)!;
    }
    return Color.lerp(sentimentMid, sentimentHigh, (t - 0.5) / 0.5)!;
  }

  static LinearGradient get heroGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [violetDeep, violet, skyGlow],
      );

  static LinearGradient sentimentGradient() => const LinearGradient(
        colors: [sentimentLow, sentimentMid, sentimentHigh],
      );

  // -------------------------------------------------------------------
  // Context-aware helpers - pick the right shade for light vs dark mode.
  // Widgets should use these instead of the raw constants above for any
  // surface/text that needs to flip with the theme.
  // -------------------------------------------------------------------
  static bool _isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color cardColor(BuildContext context) => _isDark(context) ? inkElevated : surfaceCard;

  static Color scaffoldBg(BuildContext context) => _isDark(context) ? ink : surface;

  static Color borderColor(BuildContext context) =>
      _isDark(context) ? Colors.white.withOpacity(0.08) : border;

  static Color textPrimaryC(BuildContext context) => _isDark(context) ? textOnDark : textPrimary;

  static Color textSecondaryC(BuildContext context) =>
      _isDark(context) ? textOnDarkMuted : textSecondary;
}

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color base) {
    return TextTheme(
      displayLarge: GoogleFonts.sora(
          fontSize: 32, fontWeight: FontWeight.w700, color: base, height: 1.2),
      displayMedium: GoogleFonts.sora(
          fontSize: 26, fontWeight: FontWeight.w700, color: base, height: 1.25),
      headlineMedium: GoogleFonts.sora(
          fontSize: 22, fontWeight: FontWeight.w600, color: base),
      titleLarge: GoogleFonts.sora(
          fontSize: 18, fontWeight: FontWeight.w600, color: base),
      titleMedium: GoogleFonts.sora(
          fontSize: 15, fontWeight: FontWeight.w600, color: base),
      bodyLarge: GoogleFonts.inter(fontSize: 15, color: base, height: 1.5),
      bodyMedium: GoogleFonts.inter(fontSize: 13.5, color: base, height: 1.5),
      labelLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: base),
      labelSmall: GoogleFonts.inter(fontSize: 11.5, color: base),
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.violet,
        brightness: Brightness.light,
        primary: AppColors.violet,
        surface: AppColors.surface,
      ),
      textTheme: _textTheme(AppColors.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.sora(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.violet, width: 1.6),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.violet,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerColor: AppColors.border,
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.ink,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.violet,
        brightness: Brightness.dark,
        primary: AppColors.violet,
        surface: AppColors.inkElevated,
      ),
      textTheme: _textTheme(AppColors.textOnDark),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textOnDark),
        titleTextStyle: GoogleFonts.sora(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textOnDark,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inkElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.violet, width: 1.6),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.textOnDarkMuted, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.violet,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.inkElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerColor: Colors.white.withOpacity(0.08),
    );
  }
}
