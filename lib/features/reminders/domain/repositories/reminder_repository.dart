import '../entities/reminder.dart';
import '../entities/reminder_status.dart';

abstract class ReminderRepository {
  Future<List<Reminder>> getAll();

  Future<Reminder?> getById(String id);

  Future<Reminder?> getByNotificationId(int notificationId);

  Future<List<Reminder>> getForToday();

  Future<List<Reminder>> getForTomorrow();

  Future<List<Reminder>> getForWeek();

  Future<List<Reminder>> getByStatus(ReminderStatus status);

  /// Obtiene los próximos recordatorios pendientes (para HomePage)
  Future<List<Reminder>> getUpcoming({int limit = 5});

  /// Busca recordatorios por texto en título o descripción
  Future<List<Reminder>> search(String query);

  /// Busca notas de ubicación por objeto (ej: "llaves", "control")
  Future<List<Reminder>> searchNotes(String objectQuery);

  /// Obtiene recordatorios que se activarán pronto
  Future<List<Reminder>> getUpcomingAlerts({Duration within = const Duration(hours: 2)});

  Future<void> save(Reminder reminder);

  Future<void> delete(String id);

  Future<void> markAsCompleted(String id);

  /// Pospone un recordatorio por una duración específica
  Future<void> snooze(String id, Duration duration);

  Stream<List<Reminder>> watchAll();

  Stream<List<Reminder>> watchForToday();

  /// Observa los próximos recordatorios pendientes
  Stream<List<Reminder>> watchUpcoming({int limit = 5});
}
