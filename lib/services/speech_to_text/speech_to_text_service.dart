abstract class SpeechToTextService {
  bool get isAvailable;
  bool get isListening;

  Future<bool> initialize();

  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    void Function(String error)? onError,
    String localeId = 'es_ES',
  });

  Future<void> stopListening();
  Future<void> cancel();
}
