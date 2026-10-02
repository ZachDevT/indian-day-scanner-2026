import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === BRAND / INDIAN PALETTE ===
  static const Color saffron = Color(0xFFFF6B35);
  static const Color saffronDeep = Color(0xFFE85D04);
  static const Color saffronLight = Color(0xFFFF8C5A);

  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFEDD56A);
  static const Color goldDark = Color(0xFFB8941C);

  static const Color lotusPink = Color(0xFFFF4E6A);
  static const Color lotusPinkLight = Color(0xFFFF7A91);

  static const Color jade = Color(0xFF2EC4B6);
  static const Color jadeDark = Color(0xFF1A9B91);

  static const Color peacockBlue = Color(0xFF0A2342);
  static const Color peacockBlueMid = Color(0xFF103766);
  static const Color peacockBlueLight = Color(0xFF1A4D8C);

  // === DARK THEME ===
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF222222);
  static const Color darkBorder = Color(0xFF2E2E2E);
  static const Color darkDivider = Color(0xFF282828);

  // === LIGHT THEME ===
  static const Color lightBg = Color(0xFFF7F5F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFAF8F5);
  static const Color lightBorder = Color(0xFFE8E4DF);

  // === TEXT ===
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9A9A9A);
  static const Color textTertiary = Color(0xFF5A5A5A);
  static const Color textPrimaryLight = Color(0xFF0D0D0D);
  static const Color textSecondaryLight = Color(0xFF6B6B6B);

  // === SCAN RESULT STATES ===
  static const Color valid = Color(0xFF30D158);   // iOS green
  static const Color validBg = Color(0xFF0D2F1A);
  static const Color error = Color(0xFFFF453A);   // iOS red
  static const Color errorBg = Color(0xFF2F0D0D);
  static const Color warning = Color(0xFFFFD60A); // iOS yellow
  static const Color warningBg = Color(0xFF2F2800);
  static const Color info = Color(0xFF0A84FF);    // iOS blue
  static const Color infoBg = Color(0xFF0D1F2F);

  // === SCANNER CARD GRADIENTS ===
  static const List<Color> ticketGradient = [
    Color(0xFFFF6B35),
    Color(0xFFE85D04),
    Color(0xFFC94B00),
  ];

  static const List<Color> genZGradient = [
    Color(0xFFAD3AFF),
    Color(0xFF7B2FBE),
    Color(0xFF5B1F8E),
  ];

  static const List<Color> dinnerGradient = [
    Color(0xFFD4AF37),
    Color(0xFFB8941C),
    Color(0xFF8A6D12),
  ];

  // === OVERLAY / GLASS ===
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBlack = Color(0x80000000);
  static const Color glassBorder = Color(0x26FFFFFF);
}
