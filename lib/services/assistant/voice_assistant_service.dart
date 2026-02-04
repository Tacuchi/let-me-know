import 'models/assistant_response.dart';
import 'models/preview_response.dart';

/// Servicio para procesar transcripciones de voz usando el backend LLM.
abstract class VoiceAssistantService {
  /// Procesa una transcripción de voz y retorna la acción a ejecutar.
  Future<AssistantResponse> process(
    String transcription, {
    List<Map<String, dynamic>> sessionItems = const [],
    List<Map<String, String>> conversationHistory = const [],
  });

  /// Obtiene preview(s) de batch sin crear items individuales.
  Future<PreviewResponse> preview(
    String transcription, {
    List<Map<String, String>> conversationHistory = const [],
  });

  /// Verifica si el backend está disponible.
  Future<bool> isAvailable();
}
