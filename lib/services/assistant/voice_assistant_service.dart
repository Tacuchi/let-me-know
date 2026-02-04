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
  /// - Envía la transcripción + memoria + items de sesión al backend LLM
  /// - Retorna la respuesta con la acción y datos necesarios
  ///
  /// [sessionItems] son los items pendientes en la sesión de chat actual,
  /// enviados como contexto para que el LLM decida agrupación.
  Future<AssistantResponse> process(
    String transcription, {
    List<Map<String, dynamic>> sessionItems = const [],
  });

  /// Obtiene un preview de batch sin crear items individuales.
  ///
  /// El backend analiza si la transcripción describe un batch y retorna:
  /// - PREVIEW_BATCH: resumen con estimatedCount, frequency, dateRange
  /// - NO_ACTION: si es un item individual
  /// - CLARIFICATION_NEEDED: si falta información
  Future<AssistantResponse> preview(String transcription);

  /// Verifica si el backend está disponible.
  Future<bool> isAvailable();
}
