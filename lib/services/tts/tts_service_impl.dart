import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tts_service.dart';

/// Implementación de TtsService usando flutter_tts.
/// Configurado para voz amigable, clara y en español.
class TtsServiceImpl implements TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _isInitialized = false;
  double _speechRate = 0.45;
  TtsVoice? _currentVoice;
  List<TtsVoice> _availableVoices = [];

  static const _prefKeyVoiceName = 'tts_voice_name';
  static const _prefKeyVoiceLocale = 'tts_voice_locale';
  static const _prefKeySpeechRate = 'tts_speech_rate';

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  double get currentSpeechRate => _speechRate;

  @override
  TtsVoice? get currentVoice => _currentVoice;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Cargar preferencias guardadas
    final prefs = await SharedPreferences.getInstance();
    _speechRate = prefs.getDouble(_prefKeySpeechRate) ?? 0.45;

    // Configurar idioma español por defecto
    await _tts.setLanguage('es-ES');

    // Aplicar velocidad guardada
    await _tts.setSpeechRate(_speechRate);

    // Volumen máximo para claridad
    await _tts.setVolume(1.0);

    // Tono: 1.0 = normal, >1 = más agudo, <1 = más grave
    await _tts.setPitch(1.05);

    // Cargar voces disponibles
    await _loadAvailableVoices();

    // Restaurar voz guardada si existe
    final savedVoiceName = prefs.getString(_prefKeyVoiceName);
    final savedVoiceLocale = prefs.getString(_prefKeyVoiceLocale);
    if (savedVoiceName != null && savedVoiceLocale != null) {
      final savedVoice = _availableVoices.where(
        (v) => v.name == savedVoiceName && v.locale == savedVoiceLocale,
      ).firstOrNull;
      if (savedVoice != null) {
        await setVoice(savedVoice);
      }
    }

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

  Future<void> _loadAvailableVoices() async {
    try {
      final voices = await _tts.getVoices;
      if (voices is List) {
        _availableVoices = voices
            .where((v) {
              final locale = (v['locale'] ?? v['name'] ?? '').toString().toLowerCase();
              // Filtrar solo voces en español
              return locale.startsWith('es') || locale.contains('spanish');
            })
            .map((v) {
              final name = v['name']?.toString() ?? '';
              final locale = v['locale']?.toString() ?? '';
              return TtsVoice(
                name: name,
                locale: locale,
                displayName: _formatVoiceName(name, locale),
              );
            })
            .toList();

        // Ordenar por locale y nombre
        _availableVoices.sort((a, b) {
          final localeCompare = a.locale.compareTo(b.locale);
          if (localeCompare != 0) return localeCompare;
          return a.displayName.compareTo(b.displayName);
        });
      }
    } catch (_) {
      _availableVoices = [];
    }
  }

  String _formatVoiceName(String name, String locale) {
    // Extraer nombre legible de la voz
    // Ejemplo: "es-ES-language" -> "España"
    // Ejemplo: "es-MX-language" -> "México"
    final localeParts = locale.split('-');
    String region = '';
    if (localeParts.length >= 2) {
      region = switch (localeParts[1].toUpperCase()) {
        'ES' => 'España',
        'MX' => 'México',
        'AR' => 'Argentina',
        'CO' => 'Colombia',
        'CL' => 'Chile',
        'PE' => 'Perú',
        'VE' => 'Venezuela',
        'US' => 'EE.UU.',
        _ => localeParts[1],
      };
    }

    // Extraer género si está en el nombre
    final nameLower = name.toLowerCase();
    String gender = '';
    if (nameLower.contains('female') || nameLower.contains('mujer')) {
      gender = ' (Mujer)';
    } else if (nameLower.contains('male') || nameLower.contains('hombre')) {
      gender = ' (Hombre)';
    }

    // Extraer nombre propio si existe
    final parts = name.split(RegExp(r'[-_.]'));
    for (final part in parts) {
      if (part.length > 2 && 
          !['es', 'mx', 'ar', 'co', 'language', 'female', 'male', 'x'].contains(part.toLowerCase())) {
        final properName = part[0].toUpperCase() + part.substring(1).toLowerCase();
        if (region.isNotEmpty) {
          return '$properName - $region$gender';
        }
        return '$properName$gender';
      }
    }

    return region.isNotEmpty ? '$region$gender' : name;
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
  Future<List<TtsVoice>> getAvailableVoices() async {
    if (!_isInitialized) {
      await initialize();
    }
    return List.unmodifiable(_availableVoices);
  }

  @override
  Future<void> setVoice(TtsVoice voice) async {
    await _tts.setVoice({'name': voice.name, 'locale': voice.locale});
    _currentVoice = voice;

    // Guardar preferencia
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyVoiceName, voice.name);
    await prefs.setString(_prefKeyVoiceLocale, voice.locale);
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    // Limitar entre 0.1 y 1.0
    _speechRate = rate.clamp(0.1, 1.0);
    await _tts.setSpeechRate(_speechRate);

    // Guardar preferencia
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefKeySpeechRate, _speechRate);
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
