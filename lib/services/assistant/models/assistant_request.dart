import 'memory_item.dart';

/// Request para el endpoint /api/v1/process del backend LLM.
class AssistantRequest {
  final String transcription;
  final String currentTime;
  final String locale;
  final List<MemoryItem> memory;

  /// Items pendientes en la sesion actual (para que el LLM decida agrupacion).
  final List<Map<String, dynamic>> sessionItems;

  const AssistantRequest({
    required this.transcription,
    required this.currentTime,
    this.locale = 'es',
    this.memory = const [],
    this.sessionItems = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'transcription': transcription,
      'currentTime': currentTime,
      'locale': locale,
      'memory': memory.map((m) => m.toJson()).toList(),
      if (sessionItems.isNotEmpty) 'sessionItems': sessionItems,
    };
  }
}
