import 'models/assistant_response.dart';

/// Servicio para procesar transcripciones de voz usando el backend LLM.
///
/// Este servicio unifica el flujo de comandos y consultas, delegando
/// todo el análisis al LLM que actúa como "cerebro" de la aplicación.
abstract class VoiceAssistantService {
  /// Procesa una transcripción de voz y retorna la acción a ejecutar.
  ///
  /// El servicio automáticamente:
  /// - Obtiene la memoria actual (recordatorios) del repositorio
  /// - Envía la transcripción + memoria al backend LLM
  /// - Retorna la respuesta con la acción y datos necesarios
  Future<AssistantResponse> process(String transcription);

  /// Verifica si el backend está disponible.
  Future<bool> isAvailable();
}
