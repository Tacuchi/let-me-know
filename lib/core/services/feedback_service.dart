import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackService {
  final SharedPreferences _prefs;

  static const String _kVibrationEnabledKey = 'settings_vibration_enabled';
  static const String _kSoundEnabledKey = 'settings_sound_enabled';

  FeedbackService(this._prefs);

  bool get isVibrationEnabled => _prefs.getBool(_kVibrationEnabledKey) ?? true;
  bool get isSoundEnabled => _prefs.getBool(_kSoundEnabledKey) ?? true;

  Future<void> setVibrationEnabled(bool enabled) async {
    await _prefs.setBool(_kVibrationEnabledKey, enabled);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_kSoundEnabledKey, enabled);
  }

  // --- Haptics ---

  Future<void> light() async {
    if (isSoundEnabled) await SystemSound.play(SystemSoundType.click);
    if (!isVibrationEnabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> medium() async {
    if (isSoundEnabled) await SystemSound.play(SystemSoundType.click);
    if (!isVibrationEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  Future<void> heavy() async {
    if (isSoundEnabled) await SystemSound.play(SystemSoundType.click);
    if (!isVibrationEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  Future<void> selection() async {
    if (isSoundEnabled) await SystemSound.play(SystemSoundType.click);
    if (!isVibrationEnabled) return;
    await HapticFeedback.selectionClick();
  }

  Future<void> error() async {
    if (isSoundEnabled) await SystemSound.play(SystemSoundType.alert);
    if (!isVibrationEnabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  Future<void> success() async {
    if (isSoundEnabled) await SystemSound.play(SystemSoundType.click);
    if (!isVibrationEnabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  // --- Sounds ---

  Future<void> click() async {
    if (!isSoundEnabled) return;
    await SystemSound.play(SystemSoundType.click);
  }
}
