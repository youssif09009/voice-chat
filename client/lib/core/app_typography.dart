import 'package:flutter/material.dart';
import 'app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// App Typography — dark theme, consistent hierarchy
// ─────────────────────────────────────────────────────────────────────────────

class AppTypography {
  AppTypography._();

  // ── Display ──────────────────────────────────────────────────────────────
  static const TextStyle display = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
  );

  // ── Headings ─────────────────────────────────────────────────────────────
  static const TextStyle h1 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ── Body ─────────────────────────────────────────────────────────────────
  static const TextStyle body = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ── Labels ────────────────────────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.1,
  );

  static const TextStyle labelMedium = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // ── Captions ─────────────────────────────────────────────────────────────
  static const TextStyle caption = TextStyle(
    color: AppColors.textHint,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle micro = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    height: 1.3,
  );

  // ── Buttons ───────────────────────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.2,
  );
}
