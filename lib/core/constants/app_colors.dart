import 'package:flutter/material.dart';

abstract final class AppColors {
  // ==========================================================================
  // PALETA PRINCIPAL - PÚRPURA / INDIGO ("Resonant Horizon")
  // ==========================================================================

  // Primario: deep indigo → light purple
  static const Color primary = Color(0xFF504DCD);
  static const Color primaryLight = Color(0xFF7D7CFE);
  static const Color primaryDark = Color(0xFF3A38A0);
  static const Color primarySurface = Color(0xFFF2F3FA);

  // Modo oscuro
  static const Color primaryDarkMode = Color(0xFF7D7CFE);
  static const Color primarySurfaceDark = Color(0xFF1A1A2E);

  // ==========================================================================
  // TEMA CLARO
  // ==========================================================================

  // Fondos (surface tiers)
  static const Color bgPrimary = Color(0xFFF9F9FE); // surface base
  static const Color bgSecondary = Color(
    0xFFFFFFFF,
  ); // surface_container_lowest
  static const Color bgTertiary = Color(0xFFF2F3FA); // surface_container_low

  // Acentos (primary / primary_container / tertiary)
  static const Color accentPrimary = Color(0xFF504DCD); // primary
  static const Color accentSecondary = Color(0xFF7D7CFE); // primary_container
  static const Color accentTertiary = Color(0xFF007AFF); // tertiary / info

  // Texto
  static const Color textPrimary = Color(0xFF2E333A); // on_surface
  static const Color textSecondary = Color(0xFF5D5F63); // secondary
  static const Color textHelper = Color(0xFF6B7280); // hint / placeholder
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Separadores y contornos
  static const Color divider = Color(0xFFE2E2E7);
  static const Color outline = Color(0xFFAEB2BB);
  static const Color shadow = Color(0x0D000000); // 5% negro
  static const Color scrim = Color(0x52000000);

  // ==========================================================================
  // TEMA OSCURO
  // ==========================================================================

  static const Color bgPrimaryDark = Color(0xFF0C0E12);
  static const Color bgSecondaryDark = Color(0xFF1A1A2E);
  static const Color bgTertiaryDark = Color(0xFF252538);

  static const Color accentPrimaryDark = Color(0xFF7D7CFE);
  static const Color accentSecondaryDark = Color(0xFFA5A4FF);

  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB8B8D4);
  static const Color textHelperDark = Color(0xFF8A8AAA);

  static const Color dividerDark = Color(0xFF333350);
  static const Color outlineDark = Color(0xFF444465);

  // ==========================================================================
  // TOKENS ESPECÍFICOS DEL NUEVO SISTEMA
  // ==========================================================================

  // Chips / filtros
  static const Color chipInactive = Color(0xFFE2E2E7);
  static const Color chipInactiveDark = Color(0xFF333350);
  static const Color chipActiveText = Color(0xFFFFFFFF);

  // Badges informativos
  static const Color infoBadgeBg = Color(0x1A007AFF); // 10% blue
  static const Color infoBadgeText = Color(0xFF005BC2);

  // Botón secondary (Imagen / Escribir)
  static const Color buttonSecondaryBg = Color(0xFFE5E8F0);
  static const Color buttonSecondaryBgDark = Color(0xFF252538);

  // Section headers
  static const Color categoryLabel = Color(0xFF777B83);

  // Estados de error con gradiente
  static const Color errorAccent = Color(0xFFFA746F);
  static const Color errorDeep = Color(0xFFA83836);

  // ==========================================================================
  // ESTADOS
  // ==========================================================================

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE57373);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color warning = Color(0xFFFFB74D);
  static const Color recording = Color(0xFF504DCD);

  static const Color completed = Color(0xFF81C784);
  static const Color pending = Color(0xFFFFF3E0);
  static const Color overdue = Color(0xFFEF9A9A);

  // ==========================================================================
  // COLORES POR TIPO DE RECORDATORIO
  // ==========================================================================

  static const Color reminderMedication = Color(0xFFA83836); // error/health
  static const Color reminderAppointment = Color(0xFF007AFF); // tertiary/blue
  static const Color reminderCall = Color(0xFF7D7CFE); // primary_container
  static const Color reminderShopping = Color(0xFFFFB74D); // ámbar
  static const Color reminderTask = Color(0xFF66BB6A); // verde
  static const Color reminderEvent = Color(0xFF42A5F5); // azul claro
  static const Color reminderLocation = Color(0xFF78909C); // gris azul

  // ==========================================================================
  // GRADIENTES
  // ==========================================================================

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryLight],
  );

  // ==========================================================================
  // HELPERS ADAPTATIVOS
  // ==========================================================================

  static Color bgPrimaryAdaptive(Brightness brightness) =>
      brightness == Brightness.dark ? bgPrimaryDark : bgPrimary;

  static Color bgSecondaryAdaptive(Brightness brightness) =>
      brightness == Brightness.dark ? bgSecondaryDark : bgSecondary;

  static Color bgTertiaryAdaptive(Brightness brightness) =>
      brightness == Brightness.dark ? bgTertiaryDark : bgTertiary;

  static Color textPrimaryAdaptive(Brightness brightness) =>
      brightness == Brightness.dark ? textPrimaryDark : textPrimary;

  static Color textSecondaryAdaptive(Brightness brightness) =>
      brightness == Brightness.dark ? textSecondaryDark : textSecondary;

  static Color accentPrimaryAdaptive(Brightness brightness) =>
      brightness == Brightness.dark ? accentPrimaryDark : accentPrimary;

  static Color dividerAdaptive(Brightness brightness) =>
      brightness == Brightness.dark ? dividerDark : divider;

  static Color primaryAdaptive(Brightness brightness) =>
      brightness == Brightness.dark ? primaryDarkMode : primary;

  static Color chipInactiveAdaptive(Brightness brightness) =>
      brightness == Brightness.dark ? chipInactiveDark : chipInactive;

  static Color buttonSecondaryBgAdaptive(Brightness brightness) =>
      brightness == Brightness.dark ? buttonSecondaryBgDark : buttonSecondaryBg;
}
