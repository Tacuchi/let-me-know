/// Interfaz del servicio de reconocimiento de voz
/// Define el contrato para transcribir audio a texto
abstract class SpeechToTextService {
  /// Indica si el servicio está disponible en el dispositivo
  bool get isAvailable;

  /// Indica si actualmente está escuchando
  bool get isListening;

  /// Inicializa el servicio de reconocimiento de voz
  /// Retorna true si está disponible, false si no
  Future<bool> initialize();

  /// Inicia la escucha y transcripción
  /// [onResult] se llama cada vez que hay texto reconocido
  /// [onError] se llama cuando ocurre un error
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    void Function(String error)? onError,
    String localeId = 'es_ES',
  });

  /// Detiene la escucha
  Future<void> stopListening();

  /// Cancela la escucha sin procesar resultado
  Future<void> cancel();
}
