import 'package:flutter/material.dart';

abstract final class AppColors {
  // Tema Claro - Fondos
  static const Color bgPrimary = Color(0xFFFDF8F3);
  static const Color bgSecondary = Color(0xFFFFFFFF);
  static const Color bgTertiary = Color(0xFFF5F0EB);

  // Tema Claro - Acentos
  static const Color accentPrimary = Color(0xFFE88B5A);
  static const Color accentSecondary = Color(0xFF7DCFB6);
  static const Color accentTertiary = Color(0xFF81D4FA);

  // Tema Claro - Texto
  static const Color textPrimary = Color(0xFF3D3D3D);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHelper = Color(0xFF8B8B8B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Estados
  static const Color error = Color(0xFFE57373);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color recording = Color(0xFFFF7043);
  static const Color completed = Color(0xFFA8D5BA);
  static const Color pending = Color(0xFFFFE0B2);
  static const Color overdue = Color(0xFFFFCDD2);
  static const Color success = Color(0xFF4CAF50);

  // Tema Claro - Divisores
  static const Color divider = Color(0xFFE8E8E8);
  static const Color outline = Color(0xFFD0D0D0);
  static const Color shadow = Color(0x1A000000);
  static const Color scrim = Color(0x52000000);

  // Tema Oscuro - Fondos
  static const Color bgPrimaryDark = Color(0xFF1A1A1A);
  static const Color bgSecondaryDark = Color(0xFF2D2D2D);
  static const Color bgTertiaryDark = Color(0xFF3D3D3D);

  // Tema Oscuro - Acentos
  static const Color accentPrimaryDark = Color(0xFFFFAB7A);
  static const Color accentSecondaryDark = Color(0xFF9EECD6);

  // Tema Oscuro - Texto
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textHelperDark = Color(0xFF808080);

  // Tema Oscuro - Divisores
  static const Color dividerDark = Color(0xFF404040);
  static const Color outlineDark = Color(0xFF505050);

  // Tipos de Recordatorio
  static const Color reminderMedication = Color(0xFF7DCFB6);
  static const Color reminderAppointment = Color(0xFF81D4FA);
  static const Color reminderCall = Color(0xFFCE93D8);
  static const Color reminderShopping = Color(0xFFFFE082);
  static const Color reminderTask = Color(0xFFFFAB91);
  static const Color reminderEvent = Color(0xFF90CAF9);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPrimary, Color(0xFFD4784A)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentSecondary, Color(0xFF5AB89A)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF3E0), Color(0xFFE8F5E9)],
  );

  // Colores Adaptivos
  static Color bgPrimaryAdaptive(Brightness brightness) =>
      brightness == Brightness.dark ? bgPrimaryDark : bgPrimary;

  static Color bgSecondaryAdaptive(Brightness brightness) =>
      brightness == Brightness.dark ? bgSecondaryDark : bgSecondary;

  static Color textPrimaryAdaptive(Brightness brightness) =>
      brightness == Brightness.dark ? textPrimaryDark : textPrimary;

  static Color textSecondaryAdaptive(Brightness brightness) =>
      brightness == Brightness.dark ? textSecondaryDark : textSecondary;

  static Color accentPrimaryAdaptive(Brightness brightness) =>
      brightness == Brightness.dark ? accentPrimaryDark : accentPrimary;

  static Color dividerAdaptive(Brightness brightness) =>
      brightness == Brightness.dark ? dividerDark : divider;
}
