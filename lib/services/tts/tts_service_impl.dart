import 'package:flutter_tts/flutter_tts.dart';

import 'tts_service.dart';

/// Implementación de TtsService usando flutter_tts.
/// Configurado para voz amigable, clara y en español.
class TtsServiceImpl implements TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _isInitialized = false;

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Configurar idioma español
    await _tts.setLanguage('es-ES');

    // Velocidad de habla: 0.5 = más lento, 1.0 = normal
    // Usamos velocidad ligeramente más lenta para mayor claridad
    await _tts.setSpeechRate(0.45);

    // Volumen máximo para claridad
    await _tts.setVolume(1.0);

    // Tono: 1.0 = normal, >1 = más agudo, <1 = más grave
    // Un tono ligeramente más alto suena más amigable
    await _tts.setPitch(1.1);

    // Handlers de estado
    _tts.setStartHandler(() {
      _isSpeaking = true;
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _tts.setCancelHandler(() {
      _isSpeaking = false;
    });

    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
    });

    _tts.setPauseHandler(() {
      _isSpeaking = false;
    });

    _tts.setContinueHandler(() {
      _isSpeaking = true;
    });

    _isInitialized = true;
  }

  @override
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Detener cualquier reproducción anterior
    if (_isSpeaking) {
      await stop();
    }

    // Limpiar el texto para mejor pronunciación
    final cleanText = _cleanTextForSpeech(text);

    await _tts.speak(cleanText);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  @override
  Future<void> pause() async {
    await _tts.pause();
  }

  @override
  Future<void> dispose() async {
    await stop();
  }

  /// Limpia el texto para mejor pronunciación.
  String _cleanTextForSpeech(String text) {
    return text
        // Reemplazar viñetas por pausas naturales
        .replaceAll('•', ',')
        .replaceAll('- ', ', ')
        // Reemplazar saltos de línea por pausas
        .replaceAll('\n', '. ')
        // Limpiar espacios múltiples
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
