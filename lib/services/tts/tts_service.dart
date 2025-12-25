/// Modelo de voz disponible para TTS.
class TtsVoice {
  final String name;
  final String locale;
  final String displayName;

  const TtsVoice({
    required this.name,
    required this.locale,
    required this.displayName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TtsVoice && name == other.name && locale == other.locale;

  @override
  int get hashCode => name.hashCode ^ locale.hashCode;
}

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

  /// Obtiene las voces disponibles (filtradas por español).
  Future<List<TtsVoice>> getAvailableVoices();

  /// Establece la voz a usar.
  Future<void> setVoice(TtsVoice voice);

  /// Establece la velocidad de habla (0.0 - 1.0).
  Future<void> setSpeechRate(double rate);

  /// Obtiene la velocidad actual.
  double get currentSpeechRate;

  /// Obtiene la voz actual.
  TtsVoice? get currentVoice;

  /// Libera los recursos del servicio.
  Future<void> dispose();
}
