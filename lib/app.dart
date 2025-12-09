import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

/// Widget raíz de la aplicación
/// Configura el tema, navegación y proveedores globales
/// Soporta tema claro y oscuro (tendencia 2025)
class LetMeKnowApp extends StatefulWidget {
  const LetMeKnowApp({super.key});

  /// Permite acceder al state desde cualquier lugar de la app
  static LetMeKnowAppState of(BuildContext context) {
    return context.findAncestorStateOfType<LetMeKnowAppState>()!;
  }

  @override
  State<LetMeKnowApp> createState() => LetMeKnowAppState();
}

/// State público de la aplicación para acceder al cambio de tema
class LetMeKnowAppState extends State<LetMeKnowApp> {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Cambia el modo de tema de la aplicación
  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    // Actualizar el estilo de la barra de estado
    _updateSystemUI(mode);
  }

  /// Alterna entre tema claro y oscuro
  void toggleTheme() {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark =
        _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system && brightness == Brightness.dark);

    setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  void _updateSystemUI(ThemeMode mode) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark =
        mode == ThemeMode.dark ||
        (mode == ThemeMode.system && brightness == Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(
      isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: const Color(0xFF2D2D2D),
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.white,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Let Me Know',
      debugShowCheckedModeBanner: false,

      // Temas con soporte para modo oscuro
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,

      // Animación de transición de tema suave
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeInOut,

      // Navegación
      routerConfig: appRouter,

      // Localization (para formatos de fecha en español)
      locale: const Locale('es', 'ES'),

      // Builder para configuraciones globales
      builder: (context, child) {
        // Escalar texto para accesibilidad
        final mediaQuery = MediaQuery.of(context);
        final textScaleFactor = mediaQuery.textScaler.clamp(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.5, // Limitar para mantener diseño
        );

        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: textScaleFactor),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
