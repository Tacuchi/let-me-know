import 'models/assistant_response.dart';
import 'models/preview_response.dart';

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

  /// Obtiene preview(s) de batch sin crear items individuales.
  ///
  /// El backend analiza si la transcripción describe batch(es) y retorna:
  /// - Lista de PREVIEW_BATCH: puede ser múltiples si hay diferentes frecuencias
  /// - NO_ACTION: si es un item individual
  /// - CLARIFICATION_NEEDED: si falta información
  Future<PreviewResponse> preview(String transcription);

  /// Verifica si el backend está disponible.
  Future<bool> isAvailable();
}
