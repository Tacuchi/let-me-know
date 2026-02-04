/// Request para el endpoint /api/v1/preview del backend LLM.
class PreviewRequest {
  final String transcription;
  final String currentTime;
  final String locale;

  const PreviewRequest({
    required this.transcription,
    required this.currentTime,
    this.locale = 'es',
  });

  Map<String, dynamic> toJson() {
    return {
      'transcription': transcription,
      'currentTime': currentTime,
      'locale': locale,
    };
  }
}
