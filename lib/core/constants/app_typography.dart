import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tipografía de la aplicación
/// Tamaños accesibles para adultos y adultos mayores
abstract final class AppTypography {
  // Títulos
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

  // Cuerpo
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // Botones
  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  // Labels
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.textSecondary,
  );

  // Helper/Caption
  static const TextStyle helper = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textHelper,
  );

  // Números grandes (contadores)
  static const TextStyle number = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );
}

