import '../entities/reminder.dart';
import '../entities/reminder_status.dart';

abstract class ReminderRepository {
  Future<List<Reminder>> getAll();

  Future<Reminder?> getById(String id);

  Future<List<Reminder>> getForToday();

  Future<List<Reminder>> getByStatus(ReminderStatus status);

  /// Obtiene los próximos recordatorios pendientes (para HomePage)
  Future<List<Reminder>> getUpcoming({int limit = 5});

  /// Busca recordatorios por texto en título o descripción
  Future<List<Reminder>> search(String query);

  Future<void> save(Reminder reminder);

  Future<void> delete(String id);

  Future<void> markAsCompleted(String id);

  Stream<List<Reminder>> watchAll();

  Stream<List<Reminder>> watchForToday();

  /// Observa los próximos recordatorios pendientes
  Stream<List<Reminder>> watchUpcoming({int limit = 5});
}
