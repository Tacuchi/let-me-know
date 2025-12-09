import '../entities/reminder.dart';
import '../entities/reminder_status.dart';

/// Interfaz del repositorio de recordatorios
/// Define el contrato que debe implementar cualquier fuente de datos
abstract class ReminderRepository {
  /// Obtiene todos los recordatorios
  Future<List<Reminder>> getAll();

  /// Obtiene un recordatorio por su ID
  Future<Reminder?> getById(String id);

  /// Obtiene los recordatorios de hoy
  Future<List<Reminder>> getForToday();

  /// Obtiene los recordatorios por estado
  Future<List<Reminder>> getByStatus(ReminderStatus status);

  /// Guarda un nuevo recordatorio o actualiza uno existente
  Future<void> save(Reminder reminder);

  /// Elimina un recordatorio por su ID
  Future<void> delete(String id);

  /// Marca un recordatorio como completado
  Future<void> markAsCompleted(String id);

  /// Observa cambios en los recordatorios (stream reactivo)
  Stream<List<Reminder>> watchAll();

  /// Observa cambios en los recordatorios de hoy
  Stream<List<Reminder>> watchForToday();
}

