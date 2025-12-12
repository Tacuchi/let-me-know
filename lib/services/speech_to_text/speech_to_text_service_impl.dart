import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'speech_to_text_service.dart';

/// Implementación del servicio de reconocimiento de voz
/// usando el paquete speech_to_text (reconocimiento nativo del dispositivo)
class SpeechToTextServiceImpl implements SpeechToTextService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;

  @override
  bool get isAvailable => _isAvailable;

  @override
  bool get isListening => _isListening;

  @override
  Future<bool> initialize() async {
    _isAvailable = await _speech.initialize(
      onError: (error) {
        _isListening = false;
      },
      onStatus: (status) {
        _isListening = status == 'listening';
      },
    );
    return _isAvailable;
  }

  @override
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    void Function(String error)? onError,
    String localeId = 'es_ES',
  }) async {
    if (!_isAvailable) {
      onError?.call('Reconocimiento de voz no disponible');
      return;
    }

    _isListening = true;

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      localeId: localeId,
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
  }

  @override
  Future<void> cancel() async {
    _isListening = false;
    await _speech.cancel();
  }
}
