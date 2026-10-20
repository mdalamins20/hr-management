import 'package:flutter/material.dart';

/// Design tokens taken directly from the reference UI.
class AppColors {
  static const Color primary = Color(0xFF2563F5);
  static const Color primaryDark = Color(0xFF0A2E7A);
  static const Color navy = Color(0xFF0B2B63);
  static const Color splashTop = Color(0xFF0E56D8);
  static const Color splashBottom = Color(0xFF051E57);
  static const Color background = Color(0xFFF3F6FF);
  static const Color card = Colors.white;
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF8A94A6);
  static const Color green = Color(0xFF22C07A);
  static const Color greenBg = Color(0xFFE5F7EE);
  static const Color orange = Color(0xFFF5A623);
  static const Color orangeBg = Color(0xFFFDF1DC);
  static const Color red = Color(0xFFF05252);
  static const Color redBg = Color(0xFFFDE8E8);
  static const Color pinkBg = Color(0xFFFDEBF5);
  static const Color mintBg = Color(0xFFE4F7F0);
  static const Color peachBg = Color(0xFFFDF0E1);
  static const Color lavenderBg = Color(0xFFEAF0FE);
  static const Color border = Color(0xFFE8EDF7);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: Colors.white,
      ),
      fontFamily: 'Roboto',
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textDark,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Soft shadow used by every card in the reference design.
List<BoxShadow> get cardShadow => [
      BoxShadow(
        color: const Color(0xFF1D3FAE).withOpacity(0.06),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ];

BoxDecoration cardDecoration({double radius = 18}) => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: cardShadow,
    );
