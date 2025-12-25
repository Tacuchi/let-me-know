import 'package:flutter/material.dart';

abstract final class AppColors {
  // ==========================================================================
  // PALETA PRINCIPAL - VERDE
  // ==========================================================================
  
  // Verde primario (usado en acciones principales, botones success)
  static const Color primary = Color(0xFF2E7D32);        // Verde bosque
  static const Color primaryLight = Color(0xFF4CAF50);   // Verde medio
  static const Color primaryDark = Color(0xFF1B5E20);    // Verde muy oscuro
  static const Color primarySurface = Color(0xFFE8F5E9); // Verde muy claro (bg)
  
  // Verde para tema oscuro
  static const Color primaryDarkMode = Color(0xFF66BB6A);     // Verde vibrante
  static const Color primarySurfaceDark = Color(0xFF1A2E1A);  // Verde oscuro (bg)

  // ==========================================================================
  // TEMA CLARO
  // ==========================================================================
  
  // Fondos
  static const Color bgPrimary = Color(0xFFF5F9F5);      // Verde muy sutil
  static const Color bgSecondary = Color(0xFFFFFFFF);    // Blanco
  static const Color bgTertiary = Color(0xFFEDF5ED);     // Verde pálido

  // Acentos (verde lima para acciones)
  static const Color accentPrimary = Color(0xFF8BC34A);   // Verde lima (FAB, botones)
  static const Color accentSecondary = Color(0xFFAED581); // Verde lima claro
  static const Color accentTertiary = Color(0xFF689F38); // Verde lima oscuro

  // Texto
  static const Color textPrimary = Color(0xFF1B2E1B);    // Verde muy oscuro
  static const Color textSecondary = Color(0xFF4A5D4A);  // Verde grisáceo
  static const Color textHelper = Color(0xFF6B7B6B);     // Verde claro
  static const Color textOnPrimary = Color(0xFFFFFFFF);  // Blanco

  // Divisores
  static const Color divider = Color(0xFFD0DCD0);        // Verde gris claro
  static const Color outline = Color(0xFFB8C8B8);
  static const Color shadow = Color(0x1A1B5E20);         // Sombra verde
  static const Color scrim = Color(0x521B5E20);

  // ==========================================================================
  // TEMA OSCURO
  // ==========================================================================
  
  // Fondos oscuros - gris neutro con tinte verde muy sutil
  static const Color bgPrimaryDark = Color(0xFF121212);    // Gris casi negro
  static const Color bgSecondaryDark = Color(0xFF1E1E1E);  // Gris oscuro para cards
  static const Color bgTertiaryDark = Color(0xFF2D2D2D);   // Gris medio para elevados

  // Acentos en modo oscuro
  static const Color accentPrimaryDark = Color(0xFFAED581);   // Verde lima claro
  static const Color accentSecondaryDark = Color(0xFFC5E1A5); // Verde lima muy claro

  // Texto en modo oscuro - colores claros para buen contraste
  static const Color textPrimaryDark = Color(0xFFF5F5F5);   // Casi blanco
  static const Color textSecondaryDark = Color(0xFFB8D4B8); // Verde claro
  static const Color textHelperDark = Color(0xFF8CA88C);    // Verde medio

  // Divisores en modo oscuro - grises neutros
  static const Color dividerDark = Color(0xFF333333);      // Gris oscuro
  static const Color outlineDark = Color(0xFF444444);      // Gris medio

  // ==========================================================================
  // ESTADOS
  // ==========================================================================
  
  static const Color success = Color(0xFF4CAF50);      // Verde éxito
  static const Color error = Color(0xFFE57373);        // Rojo error
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color warning = Color(0xFFFFB74D);      // Ámbar advertencia
  static const Color recording = Color(0xFF689F38);    // Verde lima oscuro grabando
  
  // Estados de recordatorios
  static const Color completed = Color(0xFF81C784);    // Verde completado
  static const Color pending = Color(0xFFFFF3E0);      // Crema pendiente
  static const Color overdue = Color(0xFFEF9A9A);      // Rojo suave vencido

  // ==========================================================================
  // COLORES POR TIPO DE RECORDATORIO
  // ==========================================================================
  
  static const Color reminderMedication = Color(0xFF26A69A);  // Teal - salud
  static const Color reminderAppointment = Color(0xFF5C6BC0); // Indigo - citas
  static const Color reminderCall = Color(0xFF7E57C2);        // Púrpura - llamadas
  static const Color reminderShopping = Color(0xFFFFB74D);    // Ámbar - compras
  static const Color reminderTask = Color(0xFF66BB6A);        // Verde - tareas
  static const Color reminderEvent = Color(0xFF42A5F5);       // Azul - eventos
  static const Color reminderLocation = Color(0xFF78909C);    // Gris azul - notas

  // ==========================================================================
  // GRADIENTES
  // ==========================================================================
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPrimary, Color(0xFF689F38)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primarySurface, Color(0xFFC8E6C9)],
  );

  // ==========================================================================
  // FUNCIONES ADAPTATIVAS
  // ==========================================================================
  
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

  static Color primaryAdaptive(Brightness brightness) =>
      brightness == Brightness.dark ? primaryDarkMode : primary;
}
