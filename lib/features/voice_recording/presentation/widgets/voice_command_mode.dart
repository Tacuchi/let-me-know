import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../../reminders/domain/entities/reminder_source.dart';
import '../../../reminders/domain/entities/reminder_status.dart';
import '../../../reminders/domain/entities/reminder_type.dart';
import '../../../reminders/domain/repositories/reminder_repository.dart';
import '../../../../services/assistant/assistant_api_client.dart';
import '../../../../services/assistant/models/assistant_response.dart';
import '../../../../services/assistant/voice_assistant_service.dart';
import '../../../../services/speech_to_text/speech_to_text_service.dart';
import '../../../../services/tts/tts_service.dart';

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
  bool _isProcessing = false;
  AssistantResponse? _response;

  late final SpeechToTextService _speechService;
  late final FeedbackService _feedbackService;
  late final VoiceAssistantService _assistantService;
  late final TtsService _ttsService;

  @override
  void initState() {
    super.initState();
    _speechService = getIt<SpeechToTextService>();
    _feedbackService = getIt<FeedbackService>();
    _assistantService = getIt<VoiceAssistantService>();
    _ttsService = getIt<TtsService>();
    _initializeSpeech();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _ttsService.initialize();
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
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isProcessing) {
      return _buildProcessingView(isDark);
    }
    if (_response != null) {
      return _buildResponseView(isDark);
    }
    return _buildRecordingView(isDark);
  }

  Widget _buildProcessingView(bool isDark) {
    final primaryColor =
        isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(primaryColor),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Procesando...',
            style: AppTypography.titleSmall.copyWith(color: textColor),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _transcription ?? '',
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResponseView(bool isDark) {
    final response = _response!;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final successColor =
        isDark ? AppColors.accentSecondaryDark : AppColors.accentSecondary;

    final isSuccess = response.action == AssistantAction.createReminder ||
        response.action == AssistantAction.createNote;
    final needsClarification =
        response.action == AssistantAction.clarificationNeeded;

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
              color: (isSuccess ? successColor : secondaryColor)
                  .withValues(alpha: 0.15),
            ),
            child: Icon(
              isSuccess
                  ? Icons.check_rounded
                  : (needsClarification
                      ? Icons.help_outline_rounded
                      : Icons.chat_bubble_outline_rounded),
              size: 36,
              color: isSuccess ? successColor : secondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isSuccess
                ? '¡Listo!'
                : (needsClarification ? 'Necesito más información' : 'Entendido'),
            style: AppTypography.titleMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
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
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                      color: secondaryColor,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Respuesta',
                      style: AppTypography.label.copyWith(color: secondaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  response.spokenResponse,
                  style: AppTypography.bodyLarge.copyWith(
                    color: textColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildResponseButtons(isDark, isSuccess),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildResponseButtons(bool isDark, bool isSuccess) {
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
            onPressed: _resetAndTryAgain,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              elevation: 0,
            ),
            icon: Icon(isSuccess ? Icons.add_rounded : Icons.mic_rounded, size: 22),
            label: Text(
              isSuccess ? 'Crear otro' : 'Intentar de nuevo',
              style: const TextStyle(
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
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: secondaryColor,
              side: BorderSide(color: secondaryColor.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: const Text(
              'Cerrar',
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  void _resetAndTryAgain() {
    _feedbackService.light();
    _ttsService.stop();
    setState(() {
      _transcription = null;
      _response = null;
      _error = null;
      _isProcessing = false;
    });
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
      _processTranscription();
    } else {
      setState(() {
        _isRecording = true;
        _transcription = '';
        _response = null;
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
                _processTranscription();
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

  Future<void> _processTranscription() async {
    if (_transcription == null || _transcription!.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final response = await _assistantService.process(_transcription!);

      if (!mounted) return;

      setState(() {
        _response = response;
        _isProcessing = false;
      });

      // Ejecutar acción según respuesta
      await _executeAction(response);

      // Reproducir respuesta con TTS
      if (response.spokenResponse.isNotEmpty) {
        await _ttsService.speak(response.spokenResponse);
      }
    } on ApiConnectionException {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo conectar al servidor'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _executeAction(AssistantResponse response) async {
    final repository = getIt<ReminderRepository>();

    switch (response.action) {
      case AssistantAction.createReminder:
        final data = response.createReminderData!;
        final reminder = Reminder(
          id: const Uuid().v4(),
          title: data.title,
          description: _transcription ?? '',
          scheduledAt: data.scheduledAt,
          type: data.type,
          status: ReminderStatus.pending,
          importance: data.importance,
          source: ReminderSource.voice,
          object: data.object,
          location: data.location,
          hasNotification: data.scheduledAt != null,
          createdAt: DateTime.now(),
        );
        await repository.save(reminder);
        await _feedbackService.success();

      case AssistantAction.createNote:
        final data = response.createNoteData!;
        final note = Reminder(
          id: const Uuid().v4(),
          title: data.title,
          description: _transcription ?? '',
          scheduledAt: null,
          type: ReminderType.location,
          status: ReminderStatus.pending,
          importance: data.importance,
          source: ReminderSource.voice,
          object: data.object,
          location: data.location,
          hasNotification: false,
          createdAt: DateTime.now(),
        );
        await repository.save(note);
        await _feedbackService.success();

      case AssistantAction.clarificationNeeded:
      case AssistantAction.noAction:
        _feedbackService.light();

      default:
        break;
    }
  }

}
