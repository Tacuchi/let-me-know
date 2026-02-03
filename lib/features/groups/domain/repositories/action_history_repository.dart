import '../entities/action_history_entry.dart';

abstract class ActionHistoryRepository {
  /// Obtiene las últimas N entradas del historial.
  Future<List<ActionHistoryEntry>> getRecent({int limit = 50});

  /// Registra una acción en el historial.
  Future<void> record(ActionHistoryEntry entry);

  /// Limpia entradas antiguas (más de N días).
  Future<void> cleanup({int olderThanDays = 30});
}
