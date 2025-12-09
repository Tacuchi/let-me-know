import 'package:flutter/material.dart';

/// Colores de la aplicación basados en el sistema de diseño Material 3
/// Paleta cálida y accesible para adultos y adultos mayores
/// Soporta tema claro y oscuro (tendencia 2025)
abstract final class AppColors {
  // ============ TEMA CLARO ============
  // Fondos
  static const Color bgPrimary = Color(0xFFFDF8F3); // Beige cálido
  static const Color bgSecondary = Color(0xFFFFFFFF); // Blanco
  static const Color bgTertiary = Color(0xFFF5F0EB); // Beige suave

  // Acentos
  static const Color accentPrimary = Color(0xFFE88B5A); // Naranja suave
  static const Color accentSecondary = Color(0xFF7DCFB6); // Verde menta
  static const Color accentTertiary = Color(0xFF81D4FA); // Azul claro

  // Texto
  static const Color textPrimary = Color(0xFF3D3D3D); // Gris oscuro
  static const Color textSecondary = Color(0xFF6B6B6B); // Gris medio
  static const Color textHelper = Color(0xFF8B8B8B); // Gris claro
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Blanco sobre acentos

  // Estados
  static const Color error = Color(0xFFE57373); // Rojo suave
  static const Color errorContainer = Color(0xFFFFDAD6); // Contenedor error
  static const Color recording = Color(0xFFFF7043); // Naranja intenso
  static const Color completed = Color(0xFFA8D5BA); // Verde completado
  static const Color pending = Color(0xFFFFE0B2); // Naranja pendiente
  static const Color overdue = Color(0xFFFFCDD2); // Rojo vencido
  static const Color success = Color(0xFF4CAF50); // Verde éxito

  // Divisores y bordes
  static const Color divider = Color(0xFFE8E8E8);
  static const Color outline = Color(0xFFD0D0D0);

  // Elevación/Sombras
  static const Color shadow = Color(0x1A000000); // Negro 10%
  static const Color scrim = Color(0x52000000); // Negro 32%

  // ============ TEMA OSCURO ============
  static const Color bgPrimaryDark = Color(
    0xFF1A1A1A,
  ); // Fondo principal oscuro
  static const Color bgSecondaryDark = Color(0xFF2D2D2D); // Tarjetas oscuras
  static const Color bgTertiaryDark = Color(
    0xFF3D3D3D,
  ); // Fondo terciario oscuro

  static const Color accentPrimaryDark = Color(
    0xFFFFAB7A,
  ); // Naranja más brillante para dark
  static const Color accentSecondaryDark = Color(
    0xFF9EECD6,
  ); // Verde menta brillante

  static const Color textPrimaryDark = Color(0xFFF5F5F5); // Casi blanco
  static const Color textSecondaryDark = Color(0xFFB0B0B0); // Gris claro
  static const Color textHelperDark = Color(0xFF808080); // Gris medio

  static const Color dividerDark = Color(0xFF404040);
  static const Color outlineDark = Color(0xFF505050);

  // ============ TIPOS DE RECORDATORIO ============
  static const Color reminderMedication = Color(0xFF7DCFB6); // Verde menta
  static const Color reminderAppointment = Color(0xFF81D4FA); // Azul claro
  static const Color reminderCall = Color(0xFFCE93D8); // Púrpura
  static const Color reminderShopping = Color(0xFFFFE082); // Amarillo
  static const Color reminderTask = Color(0xFFFFAB91); // Naranja
  static const Color reminderEvent = Color(0xFF90CAF9); // Azul

  // ============ GRADIENTES ============
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

  // ============ COLORES ADAPTIVOS ============
  /// Retorna el color de fondo primario según el brillo
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
