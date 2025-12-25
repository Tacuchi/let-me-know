import '../../features/reminders/domain/entities/reminder_importance.dart';
import '../../features/reminders/domain/entities/reminder_type.dart';

/// Resultado del parsing de una transcripción de voz
class ParsedReminder {
  final String title;
  final ReminderType type;
  final DateTime? scheduledAt;
  final ReminderImportance importance;

  /// Para tipo location: el objeto mencionado (ej: "llaves")
  final String? object;

  /// Para tipo location: dónde se guardó (ej: "cómoda de la habitación")
  final String? location;

  const ParsedReminder({
    required this.title,
    required this.type,
    this.scheduledAt,
    required this.importance,
    this.object,
    this.location,
  });
}

/// Servicio para extraer información estructurada de texto de voz
abstract class TextParserService {
  /// Extrae información del texto transcrito
  ParsedReminder parse(String transcription);

  /// Determina si el texto es una consulta (pregunta) o un comando de creación
  bool isQuery(String transcription);

  /// Extrae el objeto buscado de una consulta de ubicación
  /// Ej: "¿Dónde dejé mis llaves?" -> "llaves"
  String? extractSearchObject(String query);
}
