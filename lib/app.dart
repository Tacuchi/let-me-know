import 'dart:async';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'di/injection_container.dart';
import 'features/reminders/application/cubit/reminder_list_cubit.dart';
import 'features/reminders/domain/repositories/reminder_repository.dart';
import 'router/app_router.dart';
import 'router/app_routes.dart';
import 'services/alarm/alarm_service.dart';
import 'services/notifications/notification_service.dart';

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
  static const _appChannel = MethodChannel('dev.tacuchi.let_me_know/app');

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

    // Cold start: si la app fue lanzada por tap en notificación, navegar a alarma
    _checkColdStartNotification();

    // Red de seguridad: detectar alarmas sonando via canal nativo
    _checkColdStartRingingAlarms();

    // Verificar permiso full-screen intent en Android 14+
    _checkFullScreenIntentPermission();

    // Guía de permisos para OEMs restrictivos (Xiaomi, Huawei, etc.)
    _checkOemPermissions();

    // Permiso "Mostrar sobre otras apps" — necesario en OEMs restrictivos
    _checkOverlayPermission();
  }

  Future<void> _checkColdStartNotification() async {
    final notificationService = getIt<NotificationService>();
    final launchDetails = await notificationService.getAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp == true) {
      final reminderId =
          launchDetails!.notificationResponse?.payload;
      if (reminderId != null && reminderId.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          appRouter.pushNamed(
            AppRoutes.alarmName,
            pathParameters: {'id': reminderId},
          );
        });
      }
    }
  }

  Future<void> _checkColdStartRingingAlarms() async {
    if (!Platform.isAndroid) return;

    try {
      final List<dynamic>? ids =
          await _appChannel.invokeMethod('getRingingAlarmIds');
      if (ids == null || ids.isEmpty) return;

      final repo = getIt<ReminderRepository>();
      for (final id in ids) {
        final alarmId = id as int;
        final reminder = await repo.getByNotificationId(alarmId);
        if (reminder != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            appRouter.pushNamed(
              AppRoutes.alarmName,
              pathParameters: {'id': reminder.id},
            );
          });
          break; // Navegar solo a la primera alarma sonando
        }
      }
    } catch (_) {
      // Ignorar si el canal nativo falla
    }
  }

  Future<void> _checkFullScreenIntentPermission() async {
    if (!Platform.isAndroid) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final bool canUse =
            await _appChannel.invokeMethod('canUseFullScreenIntent') ?? true;
        if (canUse) return;

        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Permiso necesario'),
            content: const Text(
              'Para que las alarmas se muestren en pantalla completa, '
              'activa el permiso "Mostrar en pantalla completa".\n\n'
              'Sin este permiso, las alarmas sonarán pero la pantalla '
              'de completar no se abrirá automáticamente.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Después'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _appChannel.invokeMethod('openFullScreenIntentSettings');
                },
                child: const Text('Abrir ajustes'),
              ),
            ],
          ),
        );
      } catch (_) {}
    });
  }

  static const _restrictiveOems = [
    'xiaomi', 'redmi', 'poco', 'huawei', 'honor', 'oppo', 'realme',
  ];

  Future<void> _checkOemPermissions() async {
    if (!Platform.isAndroid) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('oem_permission_guide_shown') == true) return;

    try {
      final String manufacturer =
          await _appChannel.invokeMethod('getManufacturer') ?? '';
      final lower = manufacturer.toLowerCase();

      final isRestrictive = _restrictiveOems.any(lower.contains);
      if (!isRestrictive) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showOemPermissionGuide(manufacturer);
      });
    } catch (_) {}
  }

  void _showOemPermissionGuide(String manufacturer) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Configuración importante'),
        content: Text(
          'Tu dispositivo $manufacturer requiere permisos adicionales '
          'para que las alarmas puedan abrir la app automáticamente.\n\n'
          'Por favor habilita:\n'
          '• Inicio automático (AutoStart)\n'
          '• Mostrar ventanas emergentes en segundo plano\n\n'
          'Sin estos permisos, las alarmas sonarán pero la pantalla '
          'de completar no se abrirá automáticamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Después'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _appChannel.invokeMethod('openOemPermissionSettings');
            },
            child: const Text('Abrir ajustes'),
          ),
        ],
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('oem_permission_guide_shown', true);
  }

  Future<void> _checkOverlayPermission() async {
    if (!Platform.isAndroid) return;

    try {
      final String manufacturer =
          await _appChannel.invokeMethod('getManufacturer') ?? '';
      final lower = manufacturer.toLowerCase();
      final isRestrictive = _restrictiveOems.any(lower.contains);
      if (!isRestrictive) return;

      final bool canDraw =
          await _appChannel.invokeMethod('canDrawOverlays') ?? true;
      if (canDraw) return;

      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('overlay_permission_shown') == true) return;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Permiso adicional'),
            content: const Text(
              'Para garantizar que las alarmas abran la app '
              'automáticamente, habilita "Mostrar sobre otras apps".\n\n'
              'Este permiso es necesario en dispositivos con '
              'restricciones de fondo agresivas.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Después'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _appChannel.invokeMethod('openOverlaySettings');
                },
                child: const Text('Abrir ajustes'),
              ),
            ],
          ),
        );
        await prefs.setBool('overlay_permission_shown', true);
      });
    } catch (_) {}
  }

  void _onAlarmRing(AlarmSettings alarm) async {
    // Traer la app al frente (solo Android)
    if (Platform.isAndroid) {
      try {
        await _appChannel.invokeMethod('bringToForeground');
      } catch (_) {
        // Ignorar si falla (ej. permisos)
      }
    }

    // Obtener reminderId del payload o buscar por notificationId
    String? reminderId = alarm.payload;

    if (reminderId == null || reminderId.isEmpty) {
      final repo = getIt<ReminderRepository>();
      final reminder = await repo.getByNotificationId(alarm.id);
      reminderId = reminder?.id;
    }

    if (reminderId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appRouter.pushNamed(
          AppRoutes.alarmName,
          pathParameters: {'id': reminderId!},
        );
      });
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

    if (!getIt.isRegistered<ReminderListCubit>()) return app;

    return BlocProvider(
      create: (_) => getIt<ReminderListCubit>()..start(),
      child: app,
    );
  }
}
