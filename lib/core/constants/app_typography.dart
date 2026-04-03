import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tipografía de la aplicación — "Resonant Horizon"
/// Sistema editorial: Inter con intencionalidad tipográfica
abstract final class AppTypography {
  // ==========================================================================
  // DISPLAY / TÍTULOS DE PANTALLA
  // ==========================================================================

  static const TextStyle appTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    height: 1.33,
    letterSpacing: -0.6,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ==========================================================================
  // CUERPO
  // ==========================================================================

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.625, // 26px line-height / 16px font-size
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    color: AppColors.textSecondary,
  );

  // ==========================================================================
  // BOTONES
  // ==========================================================================

  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 1.4,
  );

  // ==========================================================================
  // LABELS / CHIPS
  // ==========================================================================

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.textSecondary,
  );

  static const TextStyle chipLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
  );

  // ==========================================================================
  // SECTION HEADERS — uppercase editorial
  // ==========================================================================

  /// Headers de sección tipo "SALUD", "SOCIAL"
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.33,
    letterSpacing: 1.2,
    color: AppColors.categoryLabel,
  );

  /// Labels pequeños uppercase tipo "ASISTENTE", "TÚ"
  static const TextStyle microLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: 1.1,
    color: AppColors.textSecondary,
  );

  // ==========================================================================
  // BADGES
  // ==========================================================================

  static const TextStyle badgeText = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w900,
    height: 1.5,
    letterSpacing: 0.5,
    color: AppColors.infoBadgeText,
  );

  // ==========================================================================
  // CAPTION / HELPER
  // ==========================================================================

  static const TextStyle helper = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textHelper,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    color: AppColors.textSecondary,
  );

  // ==========================================================================
  // NÚMEROS
  // ==========================================================================

  static const TextStyle number = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );
}
