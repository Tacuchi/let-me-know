import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../../features/reminders/domain/entities/reminder.dart';
import '../../features/reminders/domain/entities/reminder_importance.dart';
import '../../features/reminders/domain/entities/reminder_type.dart';
import 'notification_service.dart';

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  @override
  Future<bool> initialize() async {
    if (_initialized) return true;

    tz.initializeTimeZones();

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
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final result = await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = result ?? false;
    return _initialized;
  }

  void _onNotificationTap(NotificationResponse response) {
    // TODO: Navigate to reminder detail page
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
      final granted =
          await android?.areNotificationsEnabled() ?? false;
      return granted;
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

    final androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Recordatorios',
      channelDescription: 'Notificaciones de recordatorios',
      importance: _getImportance(reminder),
      priority: _getPriority(reminder),
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
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
      '${_getIcon(reminder.type)} ${reminder.title}',
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

  Importance _getImportance(Reminder reminder) {
    switch (reminder.importance) {
      case ReminderImportance.high:
        return Importance.high;
      case ReminderImportance.medium:
        return Importance.defaultImportance;
      case ReminderImportance.low:
        return Importance.low;
      case ReminderImportance.info:
        return Importance.low;
    }
  }

  Priority _getPriority(Reminder reminder) {
    switch (reminder.importance) {
      case ReminderImportance.high:
        return Priority.high;
      case ReminderImportance.medium:
        return Priority.defaultPriority;
      case ReminderImportance.low:
        return Priority.low;
      case ReminderImportance.info:
        return Priority.low;
    }
  }

  String _getIcon(ReminderType type) {
    return type.emoji;
  }
}
