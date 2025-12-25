import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../../features/reminders/domain/entities/reminder.dart';
import '../../features/reminders/domain/entities/reminder_importance.dart';
import '../../features/reminders/domain/entities/reminder_type.dart';
import '../../router/app_router.dart';
import '../../router/app_routes.dart';
import 'notification_service.dart';

// Canales Android
const String channelHighImportance = 'high_importance_reminders';
const String channelDefault = 'default_reminders';

/// Handler para notificaciones en background (corre en isolate separado)
@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse response) async {
  // Sin acciones - el usuario interactúa en la app
}

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  @override
  Future<bool> initialize() async {
    if (_initialized) return true;

    tz_data.initializeTimeZones();

    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      final location = tz.getLocation(timeZoneName);
      tz.setLocalLocation(location);
    } catch (e) {
      try {
        tz.setLocalLocation(tz.getLocation('America/Lima'));
      } catch (e) {
        tz.setLocalLocation(tz.UTC);
      }
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings (sin acciones - interacción en la app)
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final result = await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
    );

    // Crear canales Android
    await _createAndroidChannels();

    _initialized = result ?? false;
    return _initialized;
  }

  Future<void> _createAndroidChannels() async {
    if (!Platform.isAndroid) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Canal de alta importancia (medicamentos, citas)
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelHighImportance,
        'Recordatorios Importantes',
        description: 'Medicamentos y citas médicas',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),
    );

    // Canal por defecto
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelDefault,
        'Recordatorios',
        description: 'Recordatorios generales',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  void _onNotificationResponse(NotificationResponse response) {
    final reminderId = response.payload;

    // Si es tap en la notificación, abrir pantalla de alarma
    if (reminderId != null && reminderId.isNotEmpty) {
      _navigateToAlarm(reminderId);
    }
  }

  void _navigateToAlarm(String reminderId) {
    appRouter.pushNamed(
      AppRoutes.alarmName,
      pathParameters: {'id': reminderId},
    );
  }

  @override
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }

    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  @override
  Future<bool> hasPermissions() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? false;
    }

    return _initialized;
  }

  @override
  Future<void> scheduleNotification(Reminder reminder) async {
    if (!_initialized) await initialize();
    if (reminder.scheduledAt == null) return;
    if (reminder.scheduledAt!.isBefore(DateTime.now())) return;

    final notificationId = reminder.notificationId ??
        reminder.id.hashCode.abs() % 2147483647;

    // Seleccionar canal según importancia
    final channelId = _isHighImportance(reminder)
        ? channelHighImportance
        : channelDefault;

    final isHighPriority = _isHighImportance(reminder);

    // Android: notificación simple, interacción en la app
    final androidDetails = AndroidNotificationDetails(
      channelId,
      isHighPriority ? 'Recordatorios Importantes' : 'Recordatorios',
      channelDescription: 'Notificaciones de recordatorios',
      importance: _getImportance(reminder),
      priority: _getPriority(reminder),
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      fullScreenIntent: isHighPriority,
      category: isHighPriority ? AndroidNotificationCategory.alarm : null,
      visibility: NotificationVisibility.public,
    );

    // iOS: notificación simple
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: isHighPriority 
          ? InterruptionLevel.timeSensitive 
          : InterruptionLevel.active,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = tz.TZDateTime.from(
      reminder.scheduledAt!,
      tz.local,
    );

    await _plugin.zonedSchedule(
      notificationId,
      '${reminder.type.emoji} ${reminder.title}',
      reminder.description.isNotEmpty
          ? reminder.description
          : 'Tienes un recordatorio programado',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: reminder.id,
    );
  }

  @override
  Future<void> cancelNotification(int notificationId) async {
    await _plugin.cancel(notificationId);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  @override
  Future<NotificationAppLaunchDetails?> getAppLaunchDetails() async {
    return await _plugin.getNotificationAppLaunchDetails();
  }

  bool _isHighImportance(Reminder reminder) {
    return reminder.importance == ReminderImportance.high ||
        reminder.type == ReminderType.medication ||
        reminder.type == ReminderType.appointment;
  }

  Importance _getImportance(Reminder reminder) {
    if (_isHighImportance(reminder)) return Importance.max;
    
    switch (reminder.importance) {
      case ReminderImportance.high:
        return Importance.max;
      case ReminderImportance.medium:
        return Importance.high;
      case ReminderImportance.low:
        return Importance.defaultImportance;
      case ReminderImportance.info:
        return Importance.low;
    }
  }

  Priority _getPriority(Reminder reminder) {
    if (_isHighImportance(reminder)) return Priority.max;
    
    switch (reminder.importance) {
      case ReminderImportance.high:
        return Priority.max;
      case ReminderImportance.medium:
        return Priority.high;
      case ReminderImportance.low:
        return Priority.defaultPriority;
      case ReminderImportance.info:
        return Priority.low;
    }
  }
}
