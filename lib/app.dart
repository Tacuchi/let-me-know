import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'di/injection_container.dart';
import 'features/reminders/application/cubit/reminder_list_cubit.dart';
import 'features/reminders/application/cubit/reminder_summary_cubit.dart';
import 'features/reminders/domain/repositories/reminder_repository.dart';
import 'router/app_router.dart';
import 'router/app_routes.dart';
import 'services/alarm/alarm_service.dart';

enum TextSizeOption { normal, large, extraLarge }

extension TextSizeOptionX on TextSizeOption {
  String get label => switch (this) {
    TextSizeOption.normal => 'Normal',
    TextSizeOption.large => 'Grande',
    TextSizeOption.extraLarge => 'Muy grande',
  };

  double get scaleFactor => switch (this) {
    TextSizeOption.normal => 1.0,
    TextSizeOption.large => 1.15,
    TextSizeOption.extraLarge => 1.3,
  };
}

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
  TextSizeOption _textSize = TextSizeOption.normal;
  StreamSubscription<AlarmSettings>? _alarmSubscription;

  ThemeMode get themeMode => _themeMode;
  TextSizeOption get textSize => _textSize;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _setupAlarmListener();
  }

  void _setupAlarmListener() {
    final alarmService = getIt<AlarmService>();
    _alarmSubscription = alarmService.ringingStream.listen(_onAlarmRing);
  }

  void _onAlarmRing(AlarmSettings alarm) async {
    // Buscar el reminder por su notificationId (que es el alarm.id)
    final repo = getIt<ReminderRepository>();
    final reminder = await repo.getByNotificationId(alarm.id);
    
    if (reminder != null) {
      appRouter.pushNamed(
        AppRoutes.alarmName,
        pathParameters: {'id': reminder.id},
      );
    }
  }

  @override
  void dispose() {
    _alarmSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    final textSizeIndex = prefs.getInt('textSize') ?? 0;

    setState(() {
      _themeMode = ThemeMode
          .values[themeModeIndex.clamp(0, ThemeMode.values.length - 1)];
      _textSize = TextSizeOption
          .values[textSizeIndex.clamp(0, TextSizeOption.values.length - 1)];
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
    await prefs.setInt('textSize', _textSize.index);
  }

  void setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    _updateSystemUI(mode);
    _savePreferences();
  }

  void setTextSize(TextSizeOption size) {
    setState(() => _textSize = size);
    _savePreferences();
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
        final customScaler = TextScaler.linear(_textSize.scaleFactor);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: customScaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    final cubitsRegistered =
        getIt.isRegistered<ReminderListCubit>() &&
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
