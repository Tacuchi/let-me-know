import '../../features/reminders/domain/entities/reminder_importance.dart';
import '../../features/reminders/domain/entities/reminder_type.dart';

/// Resultado del análisis de una transcripción de comando (crear recordatorio/nota)
class CommandAnalysis {
  final String title;
  final ReminderType type;
  final DateTime? scheduledAt;
  final ReminderImportance importance;

  /// Para notas de ubicación: el objeto mencionado (ej: "llaves")
  final String? object;

  /// Para notas de ubicación: dónde se guardó (ej: "bajo la cama")
  final String? location;

  const CommandAnalysis({
    required this.title,
    required this.type,
    this.scheduledAt,
    required this.importance,
    this.object,
    this.location,
  });

  /// Es una nota de ubicación (sin alarma)
  bool get isLocationNote => type == ReminderType.location;

  /// Tiene fecha/hora programada
  bool get hasSchedule => scheduledAt != null;
}

/// Tipo de intención detectada en la transcripción
enum TranscriptionIntent {
  /// Comando para crear recordatorio/nota
  createReminder,

  /// Consulta de ubicación: "¿Dónde dejé mis llaves?"
  queryLocation,

  /// Consulta de pendientes: "¿Qué tengo para hoy?"
  queryReminders,

  /// Consulta de horario: "¿A qué hora me tocan mis pastillas?"
  querySchedule,

  /// No se pudo determinar la intención
  unknown,
}

/// Resultado del análisis de una consulta
class QueryAnalysis {
  final TranscriptionIntent intent;

  /// Para consultas de ubicación: el objeto buscado
  final String? searchObject;

  /// Para consultas de recordatorios: filtro de tiempo (hoy, mañana, etc.)
  final String? timeFilter;

  /// Para consultas de horario: tipo de recordatorio buscado (medication, event, etc.)
  final String? reminderTypeFilter;

  /// Para consultas de horario: palabra clave del recordatorio buscado
  final String? subjectKeyword;

  /// Texto original normalizado
  final String normalizedText;

  const QueryAnalysis({
    required this.intent,
    this.searchObject,
    this.timeFilter,
    this.reminderTypeFilter,
    this.subjectKeyword,
    required this.normalizedText,
  });

  bool get isLocationQuery => intent == TranscriptionIntent.queryLocation;
  bool get isReminderQuery => intent == TranscriptionIntent.queryReminders;
  bool get isScheduleQuery => intent == TranscriptionIntent.querySchedule;
  bool get isCommand => intent == TranscriptionIntent.createReminder;
}

/// Servicio para analizar transcripciones de voz.
///
/// Esta interfaz abstrae el análisis de texto hablado, permitiendo
/// intercambiar la implementación (local con regex vs LLM en el futuro).
///
/// ## Uso futuro con LLM
/// ```dart
/// // Implementación futura con Gemini/GPT
/// class LlmTranscriptionAnalyzer implements TranscriptionAnalyzer {
///   final GeminiClient _client;
///
///   @override
///   Future<QueryAnalysis> analyzeQuery(String transcription) async {
///     final response = await _client.analyze(transcription, prompt: _queryPrompt);
///     return QueryAnalysis.fromJson(response);
///   }
/// }
/// ```
abstract class TranscriptionAnalyzer {
  /// Determina la intención del usuario a partir de la transcripción.
  ///
  /// Retorna si es un comando de creación o una consulta.
  Future<TranscriptionIntent> detectIntent(String transcription);

  /// Analiza una transcripción como comando de creación.
  ///
  /// Extrae: tipo, fecha/hora, importancia, objeto, ubicación.
  Future<CommandAnalysis> analyzeCommand(String transcription);

  /// Analiza una transcripción como consulta.
  ///
  /// Extrae: intención específica, objeto buscado, filtros.
  Future<QueryAnalysis> analyzeQuery(String transcription);
}
