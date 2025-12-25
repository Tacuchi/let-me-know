import '../../features/reminders/domain/entities/reminder.dart';

/// Tipos de consulta detectados
enum QueryType {
  /// Consulta de ubicación: "¿Dónde dejé mis llaves?"
  locationQuery,

  /// Consulta de recordatorios: "¿Qué tengo pendiente?"
  reminderQuery,

  /// Consulta de horario: "¿A qué hora me tocan mis pastillas?"
  scheduleQuery,

  /// No es una consulta, es un comando de creación
  notAQuery,

  /// No se pudo entender la consulta
  notUnderstood,
}

/// Resultado de procesar una consulta de voz
class QueryResult {
  final QueryType type;
  final String response;
  final List<Reminder>? relatedItems;
  final List<Reminder>? upcomingAlerts;

  const QueryResult({
    required this.type,
    required this.response,
    this.relatedItems,
    this.upcomingAlerts,
  });

  bool get hasRelatedItems => relatedItems != null && relatedItems!.isNotEmpty;
  bool get hasUpcomingAlerts => upcomingAlerts != null && upcomingAlerts!.isNotEmpty;
}

/// Servicio para procesar consultas de voz
abstract class QueryService {
  /// Procesa una transcripción y determina si es consulta o comando
  Future<QueryResult> processQuery(String transcription);

  /// Verifica si hay recordatorios próximos (dentro de las siguientes horas)
  Future<List<Reminder>> getUpcomingAlerts({Duration within = const Duration(hours: 2)});
}
