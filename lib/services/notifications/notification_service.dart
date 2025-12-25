import '../../features/reminders/domain/entities/reminder.dart';

abstract class NotificationService {
  Future<bool> initialize();
  Future<void> scheduleNotification(Reminder reminder);
  Future<void> cancelNotification(int notificationId);
  Future<void> cancelAllNotifications();
  Future<bool> requestPermissions();
  Future<bool> hasPermissions();
}
