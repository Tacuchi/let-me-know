/// Servicio de Text-to-Speech para respuestas por voz.
abstract interface class TtsService {
  /// Inicializa el motor TTS.
  Future<void> initialize();

  /// Habla el texto proporcionado.
  Future<void> speak(String text);

  /// Detiene la reproducción actual.
  Future<void> stop();

  /// Pausa la reproducción actual.
  Future<void> pause();

  /// Verifica si está hablando actualmente.
  bool get isSpeaking;

  /// Libera los recursos del servicio.
  Future<void> dispose();
}
