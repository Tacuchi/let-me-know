import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/reminders/domain/entities/reminder.dart';

abstract class NotificationService {
  Future<bool> initialize();
  Future<void> scheduleNotification(Reminder reminder);
  Future<void> cancelNotification(int notificationId);
  Future<void> cancelAllNotifications();
  Future<bool> requestPermissions();
  Future<bool> hasPermissions();
  
  /// Obtiene detalles si la app fue lanzada desde una notificación
  Future<NotificationAppLaunchDetails?> getAppLaunchDetails();
}
