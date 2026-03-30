import 'package:flutter/material.dart';

/// Official Fast Printing & Packaging Color Palette
/// NEVER deviate from these values — they are brand-mandated
class AppColors {
  AppColors._();

  // ─── PRIMARY BRAND COLORS ────────────────────────────────────────────
  static const Color primaryRed = Color(0xFFC91A20);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ─── RED SHADES ──────────────────────────────────────────────────────
  static const Color redDark = Color(0xFF9E141A);
  static const Color redLight = Color(0xFFE8353B);
  static const Color redSurface = Color(0xFFFFF0F0);
  static const Color redBorder = Color(0xFFFFCDD2);

  // ─── GREY SCALE ──────────────────────────────────────────────────────
  static const Color darkGrey = Color(0xFF1A1A1A);
  static const Color charcoal = Color(0xFF2D2D2D);
  static const Color mediumGrey = Color(0xFF666666);
  static const Color softGrey = Color(0xFF999999);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color borderGrey = Color(0xFFE0E0E0);
  static const Color dividerGrey = Color(0xFFF0F0F0);

  // ─── SEMANTIC COLORS ─────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFE65100);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFFE3F2FD);
  static const Color error = Color(0xFFC91A20);
  static const Color errorLight = Color(0xFFFFF0F0);

  // ─── GRADIENT ────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFC91A20), Color(0xFF9E141A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xCC000000), Color(0x66000000), Colors.transparent],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  // ─── SHADOWS ─────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get redShadow => [
        BoxShadow(
          color: AppColors.primaryRed.withOpacity(0.25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}
