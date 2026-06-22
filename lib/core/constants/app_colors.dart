import 'package:flutter/material.dart';

/// Centralized color palette for PrepAI.
///
/// All colors used throughout the app should be referenced from here
/// to maintain consistency and make theming changes easy.
class AppColors {
  AppColors._();

  // ─── Primary ───────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52D5);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primarySurface = Color(0xFFEEEDFF);

  // ─── Background & Surface ─────────────────────────────────
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  // ─── Text ─────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Category Colors ──────────────────────────────────────
  static const Color flutter = Color(0xFF02569B);
  static const Color hr = Color(0xFF059669);
  static const Color dsa = Color(0xFFDC2626);
  static const Color firebase = Color(0xFFF59E0B);

  // ─── Difficulty Colors ────────────────────────────────────
  static const Color easy = Color(0xFF10B981);
  static const Color medium = Color(0xFFF59E0B);
  static const Color hard = Color(0xFFEF4444);

  // ─── Status Colors ────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ─── Misc ─────────────────────────────────────────────────
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shimmer = Color(0xFFE5E7EB);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);
}
