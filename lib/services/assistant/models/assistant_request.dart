import 'memory_item.dart';

/// Request para el endpoint /api/v1/process del backend LLM.
class AssistantRequest {
  final String transcription;
  final String currentTime;
  final String locale;
  final List<MemoryItem> memory;

  const AssistantRequest({
    required this.transcription,
    required this.currentTime,
    this.locale = 'es',
    this.memory = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'transcription': transcription,
      'currentTime': currentTime,
      'locale': locale,
      'memory': memory.map((m) => m.toJson()).toList(),
    };
  }
}
