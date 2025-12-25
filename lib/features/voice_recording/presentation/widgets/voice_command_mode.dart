import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../../reminders/domain/entities/reminder_source.dart';
import '../../../reminders/domain/entities/reminder_status.dart';
import '../../../reminders/domain/repositories/reminder_repository.dart';
import '../../../../services/speech_to_text/speech_to_text_service.dart';
import '../../../../services/transcription/transcription_analyzer.dart';

class VoiceCommandMode extends StatefulWidget {
  final bool isActive;
  final VoidCallback? onSwipeHint;

  const VoiceCommandMode({
    super.key,
    required this.isActive,
    this.onSwipeHint,
  });

  @override
  State<VoiceCommandMode> createState() => _VoiceCommandModeState();
}

class _VoiceCommandModeState extends State<VoiceCommandMode> {
  bool _isRecording = false;
  String? _transcription;
  String? _error;
  bool _isInitialized = false;

  late final SpeechToTextService _speechService;
  late final FeedbackService _feedbackService;

  @override
  void initState() {
    super.initState();
    _speechService = getIt<SpeechToTextService>();
    _feedbackService = getIt<FeedbackService>();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      final available = await _speechService.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = available;
          if (!available) {
            _error = 'Reconocimiento de voz no disponible en este dispositivo';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _error = 'Error al inicializar: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _speechService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasTranscription =
        _transcription != null && _transcription!.isNotEmpty;

    if (hasTranscription && !_isRecording) {
      return _buildConfirmationView(isDark);
    }
    return _buildRecordingView(isDark);
  }

  Widget _buildRecordingView(bool isDark) {
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final primaryColor =
        isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;
    final showTranscription =
        _isRecording || (_transcription != null && _transcription!.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          _buildStateHeader(isDark),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: showTranscription
                  ? _buildLiveTranscriptionArea(isDark)
                  : _buildIdlePrompt(isDark),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedMicButton(
            isRecording: _isRecording,
            onTap: widget.isActive ? _toggleRecording : null,
            size: 88,
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              key: ValueKey(_isRecording ? 'stop' : 'start'),
              _isRecording ? 'Toca para finalizar' : 'Toca para hablar',
              style: AppTypography.helper.copyWith(
                color: _isRecording ? primaryColor : secondaryColor,
                fontWeight: _isRecording ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSwipeHint(isDark, isUp: true),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildSwipeHint(bool isDark, {required bool isUp}) {
    final hintColor =
        (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
            .withValues(alpha: 0.6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isUp ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
          color: hintColor,
          size: 20,
        ),
        Text(
          isUp ? 'Desliza para consultar' : 'Desliza para crear',
          style: AppTypography.helper.copyWith(
            color: hintColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStateHeader(bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final recordingColor = AppColors.recording;

    String title;
    IconData icon;
    Color iconColor;

    if (_isRecording) {
      title = 'Escuchando...';
      icon = Icons.graphic_eq_rounded;
      iconColor = recordingColor;
    } else if (_transcription != null && _transcription!.isNotEmpty) {
      title = 'Revisando texto';
      icon = Icons.edit_note_rounded;
      iconColor = isDark ? AppColors.accentSecondaryDark : AppColors.accentSecondary;
    } else {
      title = 'Crear recordatorio';
      icon = Icons.add_circle_outline_rounded;
      iconColor = isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.2),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Row(
        key: ValueKey(title),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.titleSmall.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildIdlePrompt(bool isDark) {
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.record_voice_over_rounded,
            size: 64,
            color: secondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Di tu recordatorio en voz alta',
            style: AppTypography.bodyLarge.copyWith(color: secondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Por ejemplo: "Recordarme tomar mis pastillas a las 3 PM"',
            style: AppTypography.bodySmall.copyWith(
              color: secondaryColor.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTranscriptionArea(bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final borderColor = _isRecording
        ? AppColors.recording.withValues(alpha: 0.5)
        : (isDark ? AppColors.outlineDark : AppColors.divider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: borderColor,
          width: _isRecording ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_isRecording) ...[
                _buildPulsingDot(),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Transcribiendo...',
                  style: AppTypography.label.copyWith(
                    color: AppColors.recording,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.format_quote_rounded,
                  size: 18,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Tu recordatorio',
                  style: AppTypography.label.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: SingleChildScrollView(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: AppTypography.bodyLarge.copyWith(
                  color: textColor,
                  height: 1.6,
                ),
                child: Text(
                  _transcription?.isNotEmpty == true
                      ? _transcription!
                      : (_isRecording ? 'Esperando tu voz...' : ''),
                  style: TextStyle(
                    fontStyle: _transcription?.isEmpty ?? true
                        ? FontStyle.italic
                        : FontStyle.normal,
                    color: _transcription?.isEmpty ?? true
                        ? (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary)
                        : textColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.recording.withValues(alpha: value),
          ),
        );
      },
      onEnd: () {
        if (_isRecording && mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildConfirmationView(bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final successColor =
        isDark ? AppColors.accentSecondaryDark : AppColors.accentSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: successColor.withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.check_rounded,
              size: 36,
              color: successColor,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '¡Listo!',
            style: AppTypography.titleMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Revisa tu recordatorio',
            style: AppTypography.bodyMedium.copyWith(color: secondaryColor),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isDark ? AppColors.outlineDark : AppColors.divider,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 20,
                      color: secondaryColor,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Tu recordatorio',
                      style: AppTypography.label.copyWith(color: secondaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _transcription ?? '',
                  style: AppTypography.bodyLarge.copyWith(
                    color: textColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildConfirmationButtons(isDark),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildConfirmationButtons(bool isDark) {
    final primaryColor =
        isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _saveReminder,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.check_rounded, size: 22),
            label: const Text(
              'Guardar recordatorio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              _feedbackService.light();
              setState(() {
                _transcription = null;
                _error = null;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: secondaryColor,
              side: BorderSide(color: secondaryColor.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            icon: const Icon(Icons.mic_rounded, size: 20),
            label: const Text(
              'Volver a grabar',
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleRecording() async {
    _feedbackService.medium();

    if (!_isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error ?? 'Reconocimiento de voz no disponible'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    if (_isRecording) {
      await _speechService.stopListening();
      setState(() => _isRecording = false);
    } else {
      setState(() {
        _isRecording = true;
        _transcription = '';
        _error = null;
      });

      try {
        await _speechService.startListening(
          onResult: (text, isFinal) {
            if (mounted) {
              setState(() {
                _transcription = text;
              });
              if (isFinal && text.isNotEmpty) {
                setState(() => _isRecording = false);
              }
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _isRecording = false;
                _error = error;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $error'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          localeId: 'es_MX',
        );
      } catch (e) {
        if (mounted) {
          setState(() {
            _isRecording = false;
            _error = e.toString();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al iniciar: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _saveReminder() async {
    final repository = getIt<ReminderRepository>();
    final analyzer = getIt<TranscriptionAnalyzer>();

    // Usar el analizador de transcripciones (local o LLM en el futuro)
    final analysis = await analyzer.analyzeCommand(_transcription ?? '');

    final reminder = Reminder(
      id: const Uuid().v4(),
      title: analysis.title,
      description: _transcription ?? '',
      scheduledAt: analysis.scheduledAt,
      type: analysis.type,
      status: ReminderStatus.pending,
      importance: analysis.importance,
      source: ReminderSource.voice,
      object: analysis.object,
      location: analysis.location,
      hasNotification: analysis.hasSchedule,
      createdAt: DateTime.now(),
    );

    await repository.save(reminder);
    await _feedbackService.success();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: AppSpacing.sm),
            Text('¡Recordatorio creado!'),
          ],
        ),
        backgroundColor: AppColors.accentSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) context.pop();
    });
  }
}
