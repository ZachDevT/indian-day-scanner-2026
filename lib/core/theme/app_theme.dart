import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => _buildDark();
  static ThemeData get light => _buildLight();

  static ThemeData _buildDark() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.saffron,
        secondary: AppColors.gold,
        tertiary: AppColors.jade,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),

      // Typography
      fontFamily: AppFonts.gilroy,
      textTheme: _buildTextTheme(isDark: true),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.gilroy,
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.saffron, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(
          fontFamily: AppFonts.gilroy,
          fontWeight: FontWeight.w300,
          color: AppColors.textSecondary,
          fontSize: 15,
        ),
        labelStyle: const TextStyle(
          fontFamily: AppFonts.gilroy,
          fontWeight: FontWeight.w300,
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.saffron,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: AppFonts.gilroy,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCard,
        contentTextStyle: const TextStyle(
          fontFamily: AppFonts.gilroy,
          fontWeight: FontWeight.w300,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
    );
  }

  static ThemeData _buildLight() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.saffron,
        secondary: AppColors.gold,
        tertiary: AppColors.jade,
        surface: AppColors.lightSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        onError: Colors.white,
      ),

      fontFamily: AppFonts.gilroy,
      textTheme: _buildTextTheme(isDark: false),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.gilroy,
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: AppColors.textPrimaryLight,
          letterSpacing: -0.3,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.saffron, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(
          fontFamily: AppFonts.gilroy,
          fontWeight: FontWeight.w300,
          color: AppColors.textSecondaryLight,
          fontSize: 15,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.saffron,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: AppFonts.gilroy,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 0.2,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimaryLight,
        contentTextStyle: const TextStyle(
          fontFamily: AppFonts.gilroy,
          fontWeight: FontWeight.w300,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
    );
  }

  static TextTheme _buildTextTheme({required bool isDark}) {
    final primary = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final secondary = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return TextTheme(
      // Display — Enzyme font
      displayLarge: TextStyle(
        fontFamily: AppFonts.enzyme,
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: primary,
        letterSpacing: -1.5,
      ),
      displayMedium: TextStyle(
        fontFamily: AppFonts.enzyme,
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: primary,
        letterSpacing: -1.0,
      ),
      displaySmall: TextStyle(
        fontFamily: AppFonts.enzyme,
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: primary,
        letterSpacing: -0.5,
      ),

      // Headline — Gilroy ExtraBold
      headlineLarge: TextStyle(
        fontFamily: AppFonts.gilroy,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontFamily: AppFonts.gilroy,
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -0.3,
      ),
      headlineSmall: TextStyle(
        fontFamily: AppFonts.gilroy,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -0.2,
      ),

      // Title — Gilroy ExtraBold
      titleLarge: TextStyle(
        fontFamily: AppFonts.gilroy,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontFamily: AppFonts.gilroy,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -0.1,
      ),
      titleSmall: TextStyle(
        fontFamily: AppFonts.gilroy,
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: primary,
      ),

      // Body — Gilroy Light
      bodyLarge: TextStyle(
        fontFamily: AppFonts.gilroy,
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: primary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppFonts.gilroy,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: primary,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: AppFonts.gilroy,
        fontSize: 12,
        fontWeight: FontWeight.w300,
        color: secondary,
        height: 1.4,
      ),

      // Label
      labelLarge: TextStyle(
        fontFamily: AppFonts.gilroy,
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        fontFamily: AppFonts.gilroy,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: secondary,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontFamily: AppFonts.gilroy,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: secondary,
        letterSpacing: 0.8,
        height: 1.4,
      ),
    );
  }
}
