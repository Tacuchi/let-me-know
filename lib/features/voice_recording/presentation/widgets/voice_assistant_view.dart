import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../../router/app_routes.dart';
import '../../../groups/domain/entities/reminder_group.dart';
import '../../../groups/domain/repositories/group_repository.dart';
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

/// Vista unificada del asistente de voz.
/// Maneja todos los comandos: crear, consultar, completar, eliminar.
class VoiceAssistantView extends StatefulWidget {
  const VoiceAssistantView({super.key});

  @override
  State<VoiceAssistantView> createState() => _VoiceAssistantViewState();
}

class _VoiceAssistantViewState extends State<VoiceAssistantView> {
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
  late final ReminderRepository _reminderRepository;
  late final GroupRepository _groupRepository;

  @override
  void initState() {
    super.initState();
    _speechService = getIt<SpeechToTextService>();
    _feedbackService = getIt<FeedbackService>();
    _assistantService = getIt<VoiceAssistantService>();
    _ttsService = getIt<TtsService>();
    _reminderRepository = getIt<ReminderRepository>();
    _groupRepository = getIt<GroupRepository>();
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
    // NO detenemos el TTS aquí para que termine de hablar al navegar a Home
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

  // ─────────────────────────────────────────────────────────────────────────
  // Vista: Procesando
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildProcessingView(bool isDark) {
    final primaryColor =
        isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              _transcription ?? '',
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Vista: Respuesta (solo para consultas y clarificaciones)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildResponseView(bool isDark) {
    final response = _response!;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final primaryColor =
        isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;

    final isQuery = response.action == AssistantAction.queryResponse;
    final needsClarification =
        response.action == AssistantAction.clarificationNeeded;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          // Icono
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.15),
            ),
            child: Icon(
              isQuery
                  ? Icons.chat_bubble_outline_rounded
                  : (needsClarification
                      ? Icons.help_outline_rounded
                      : Icons.info_outline_rounded),
              size: 36,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            needsClarification ? 'Necesito más información' : 'Respuesta',
            style: AppTypography.titleMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Contenedor de respuesta
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
                      Icons.record_voice_over_rounded,
                      size: 20,
                      color: secondaryColor,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'El asistente dice:',
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
          // Botones de acción
          _buildResponseButtons(isDark, needsClarification),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildResponseButtons(bool isDark, bool needsClarification) {
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
            icon: Icon(
              needsClarification ? Icons.mic_rounded : Icons.refresh_rounded,
              size: 22,
            ),
            label: Text(
              needsClarification ? 'Intentar de nuevo' : 'Nueva consulta',
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

  // ─────────────────────────────────────────────────────────────────────────
  // Vista: Grabación (estado inicial)
  // ─────────────────────────────────────────────────────────────────────────

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
            onTap: _toggleRecording,
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
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildStateHeader(bool isDark) {
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final recordingColor = AppColors.recording;
    final primaryColor =
        isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;

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
      iconColor =
          isDark ? AppColors.accentSecondaryDark : AppColors.accentSecondary;
    } else {
      title = 'Habla conmigo';
      icon = Icons.record_voice_over_rounded;
      iconColor = primaryColor;
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
            Icons.mic_none_rounded,
            size: 64,
            color: secondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Dime lo que necesitas',
            style: AppTypography.bodyLarge.copyWith(color: secondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildExamplesChips(isDark),
        ],
      ),
    );
  }

  Widget _buildExamplesChips(bool isDark) {
    final helperColor =
        isDark ? AppColors.textHelperDark : AppColors.textHelper;
    final bgColor = isDark ? AppColors.bgTertiaryDark : AppColors.bgTertiary;

    final examples = [
      '"Recordarme tomar pastillas a las 3pm"',
      '"Dejé las llaves en la cocina"',
      '"¿Qué tengo pendiente hoy?"',
    ];

    return Column(
      children: examples.map((example) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              example,
              style: AppTypography.bodySmall.copyWith(
                color: helperColor,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLiveTranscriptionArea(bool isDark) {
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
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
                  'Tu mensaje',
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

  // ─────────────────────────────────────────────────────────────────────────
  // Lógica de grabación y procesamiento
  // ─────────────────────────────────────────────────────────────────────────

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

      // Determinar si es una acción exitosa que debe cerrar la pantalla
      final isSuccessAction = _isSuccessAction(response.action);

      if (isSuccessAction) {
        // Primero mostrar toast y reproducir TTS (antes de programar alarma)
        if (mounted) {
          // Iniciar TTS primero
          _ttsService.speak(response.spokenResponse);
          
          // Mostrar toast
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      response.spokenResponse,
                      style: const TextStyle(fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.accentSecondary,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              margin: const EdgeInsets.all(AppSpacing.md),
            ),
          );
          
          // Esperar un momento para que el TTS inicie
          await Future.delayed(const Duration(milliseconds: 500));
        }

        // Luego ejecutar acción (programar alarma)
        await _executeAction(response);

        // Cerrar pantalla y navegar a Home
        if (mounted) {
          context.pop();
          context.goNamed(AppRoutes.homeName);
        }
      } else {
        // Para consultas y clarificaciones, mostrar en la misma pantalla
        setState(() {
          _response = response;
          _isProcessing = false;
        });

        // Reproducir respuesta con TTS
        if (response.spokenResponse.isNotEmpty) {
          await _ttsService.speak(response.spokenResponse);
        }
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

  /// Determina si la acción es exitosa y debe cerrar la pantalla.
  bool _isSuccessAction(AssistantAction action) {
    return switch (action) {
      AssistantAction.createReminder => true,
      AssistantAction.createNote => true,
      AssistantAction.createBatch => true,
      AssistantAction.completeReminder => true,
      AssistantAction.deleteReminder => true,
      AssistantAction.deleteGroup => true,
      AssistantAction.updateReminder => true,
      _ => false,
    };
  }

  /// Muestra un toast temporal con TTS.
  void _showSuccessToast(String message) {
    // Reproducir TTS
    _ttsService.speak(message);

    // Mostrar SnackBar como toast (4 segundos)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.accentSecondary,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  Future<void> _executeAction(AssistantResponse response) async {
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
        await _reminderRepository.save(reminder);
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
        await _reminderRepository.save(note);
        await _feedbackService.success();

      case AssistantAction.createBatch:
        final data = response.batchCreateData!;
        // Crear el grupo primero
        final group = ReminderGroup(
          id: data.groupId,
          label: data.groupLabel,
          type: 'medication',
          itemCount: data.items.length,
          createdAt: DateTime.now(),
        );
        await _groupRepository.save(group);
        // Crear cada recordatorio del batch
        for (final item in data.items) {
          final reminder = Reminder(
            id: const Uuid().v4(),
            title: item.title,
            description: _transcription ?? '',
            scheduledAt: item.scheduledAt,
            type: item.type,
            status: ReminderStatus.pending,
            importance: item.importance,
            source: ReminderSource.voice,
            object: item.object,
            location: item.location,
            hasNotification: item.scheduledAt != null,
            recurrenceGroupId: data.groupId,
            createdAt: DateTime.now(),
          );
          await _reminderRepository.save(reminder);
        }
        await _feedbackService.success();

      case AssistantAction.completeReminder:
        final data = response.completeReminderData;
        if (data != null) {
          await _reminderRepository.markAsCompleted(data.reminderId);
          HapticFeedback.mediumImpact();
        }

      case AssistantAction.deleteReminder:
        final data = response.deleteReminderData;
        if (data != null) {
          await _reminderRepository.delete(data.reminderId);
          HapticFeedback.mediumImpact();
        }

      case AssistantAction.deleteGroup:
        final data = response.deleteGroupData;
        if (data != null) {
          // Obtener y eliminar todos los recordatorios del grupo
          final reminders = await _reminderRepository.getAll();
          final groupReminders = reminders
              .where((r) => r.recurrenceGroupId == data.groupId)
              .toList();
          for (final reminder in groupReminders) {
            await _reminderRepository.delete(reminder.id);
          }
          // Eliminar el grupo
          await _groupRepository.delete(data.groupId);
          HapticFeedback.mediumImpact();
        }

      case AssistantAction.updateReminder:
        // TODO: Implementar actualización
        _feedbackService.light();

      default:
        break;
    }
  }
}
