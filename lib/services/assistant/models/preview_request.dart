/// Request para el endpoint /api/v1/preview del backend LLM.
class PreviewRequest {
  final String transcription;
  final String currentTime;
  final String locale;

  /// Historial de conversación previo para contexto multi-turno.
  final List<Map<String, String>> conversationHistory;

  const PreviewRequest({
    required this.transcription,
    required this.currentTime,
    this.locale = 'es',
    this.conversationHistory = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'transcription': transcription,
      'currentTime': currentTime,
      'locale': locale,
      if (conversationHistory.isNotEmpty)
        'conversationHistory': conversationHistory,
    };
  }
}
