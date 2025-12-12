import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'di/injection_container.dart';
import 'features/reminders/application/cubit/reminder_list_cubit.dart';
import 'features/reminders/application/cubit/reminder_summary_cubit.dart';
import 'router/app_router.dart';

class LetMeKnowApp extends StatefulWidget {
  const LetMeKnowApp({super.key});

  static LetMeKnowAppState of(BuildContext context) {
    return context.findAncestorStateOfType<LetMeKnowAppState>()!;
  }

  @override
  State<LetMeKnowApp> createState() => LetMeKnowAppState();
}

class LetMeKnowAppState extends State<LetMeKnowApp> {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    _updateSystemUI(mode);
  }

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
    final app = MaterialApp.router(
      title: 'Let Me Know',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeInOut,
      routerConfig: appRouter,
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        // Limitar escala de texto para mantener diseño accesible
        final textScaleFactor = mediaQuery.textScaler.clamp(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.5,
        );
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: textScaleFactor),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    // Proveedores globales fuera de MaterialApp.builder para evitar recreación de cubits
    final cubitsRegistered = getIt.isRegistered<ReminderListCubit>() &&
        getIt.isRegistered<ReminderSummaryCubit>();

    if (!cubitsRegistered) return app;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ReminderListCubit>()..start()),
        BlocProvider(create: (_) => getIt<ReminderSummaryCubit>()..start()),
      ],
      child: app,
    );
  }
}
