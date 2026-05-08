import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ────────────────────────────────────────────────────────────
  /// Page background — deepest layer
  static const Color background  = Color(0xFF0D0D14);
  /// Card / surface — one step up
  static const Color surface     = Color(0xFF16161F);
  /// Elevated surface — modals, sheets, popovers
  static const Color surfaceHigh = Color(0xFF1E1E2A);
  /// Subtle divider / border
  static const Color border      = Color(0xFF2A2A38);

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color accentPurple  = Color(0xFFA78BFA);
  static const Color pink          = Color(0xFFD946EF);
  static const Color cyan          = Color(0xFF06B6D4);
  static const Color blue          = Color(0xFF5B5BD6);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color gold    = Color(0xFFFFD700);
  static const Color green   = Color(0xFF22C55E);
  static const Color red     = Color(0xFFEF4444);
  static const Color amber   = Color(0xFFF59E0B);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF1F1F5);
  static const Color textSecondary = Color(0xFF9898A8);
  static const Color textHint      = Color(0xFF5A5A6E);

  // ── Legacy aliases (keep existing code compiling) ─────────────────────────
  static const Color glassWhite = Color(0x1AFFFFFF);
}
