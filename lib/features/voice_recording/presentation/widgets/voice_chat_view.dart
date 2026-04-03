import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../../di/injection_container.dart';
import '../../../../services/speech_to_text/speech_to_text_service.dart';
import '../../../../services/tts/tts_service.dart';
import '../../application/cubit/voice_chat_cubit.dart';
import '../../application/cubit/voice_chat_state.dart';
import '../../domain/models/chat_message.dart';
import 'chat_message_bubble.dart';
import 'pending_creation_card.dart';
import 'pending_preview_card.dart';
import 'voice_chat_bottom_bar.dart';

/// Vista principal del chat de voz multi-turno.
///
/// Reemplaza al VoiceAssistantView con un flujo conversacional
/// donde los recordatorios se acumulan antes de ser guardados.
class VoiceChatView extends StatefulWidget {
  const VoiceChatView({super.key});

  @override
  State<VoiceChatView> createState() => _VoiceChatViewState();
}

class _VoiceChatViewState extends State<VoiceChatView> {
  late final SpeechToTextService _speechService;
  late final FeedbackService _feedbackService;
  late final TtsService _ttsService;
  final ScrollController _scrollController = ScrollController();

  bool _isInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _speechService = getIt<SpeechToTextService>();
    _feedbackService = getIt<FeedbackService>();
    _ttsService = getIt<TtsService>();
    _initializeSpeech();
    _initializeTts();
  }

  Future<void> _initializeSpeech() async {
    try {
      final available = await _speechService.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = available;
          if (!available) {
            _initError =
                'Reconocimiento de voz no disponible en este dispositivo';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _initError = 'Error al inicializar: $e';
        });
      }
    }
  }

  Future<void> _initializeTts() async {
    await _ttsService.initialize();
  }

  /// Reproduce texto con TTS.
  void _speakMessage(String text) {
    _ttsService.stop();
    _ttsService.speak(text);
  }

  @override
  void dispose() {
    _speechService.stopListening();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients && _scrollController.position.hasContentDimensions) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VoiceChatCubit, VoiceChatState>(
      listener: _handleStateChange,
      builder: (context, state) {
        return switch (state) {
          VoiceChatReady() => _buildChatLayout(context, state),
          VoiceChatSaving() => _buildSavingView(context, state),
          VoiceChatCompleted() => const SizedBox.shrink(),
        };
      },
    );
  }

  void _handleStateChange(BuildContext context, VoiceChatState state) {
    if (state is VoiceChatReady && state.hasMessages) {
      _scrollToBottom();
    }

    if (state is VoiceChatCompleted) {
      final messenger = ScaffoldMessenger.of(context);

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  state.summaryMessage,
                  style: const TextStyle(fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.accentSecondary,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          margin: const EdgeInsets.all(AppSpacing.md),
        ),
      );

      // Reset del chat para volver al estado idle
      final cubit = context.read<VoiceChatCubit>();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        cubit.reset();
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Layout principal del chat
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildChatLayout(BuildContext context, VoiceChatReady state) {
    final hasMessages = state.hasMessages;

    return PopScope(
      canPop: !state.hasPendingItems,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && state.hasPendingItems) {
          _showDiscardDialog(context);
        }
      },
      child: Column(
        children: [
          Expanded(
            child: hasMessages
                ? _buildMessageList(context, state)
                : _buildIdlePrompt(context, state),
          ),
          // Bottom bar siempre visible (permite escribir desde el inicio)
          VoiceChatBottomBar(
            phase: state.phase,
            pendingCount: state.pendingCount,
            onMicTap: () => _toggleRecording(context),
            onSendText: (text) => context.read<VoiceChatCubit>().sendTextMessage(text),
            onFinalize: () => context.read<VoiceChatCubit>().finalize(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Lista de mensajes (chat)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMessageList(BuildContext context, VoiceChatReady state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<VoiceChatCubit>();

    // Construir lista intercalando mensajes con sus previews/items adjuntos
    final items = _buildInterleavedList(state, cubit);

    // Agregar indicador de grabación/procesamiento al final
    if (state.isRecording) {
      items.add(_buildRecordingIndicator(isDark, state));
    } else if (state.isProcessing) {
      items.add(_buildProcessingIndicator(isDark));
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      children: items,
    );
  }

  /// Construye lista intercalada: mensaje -> previews/items vinculados -> mensaje -> ...
  List<Widget> _buildInterleavedList(VoiceChatReady state, VoiceChatCubit cubit) {
    final widgets = <Widget>[];
    final usedPreviewIds = <String>{};
    final usedItemIds = <String>{};

    for (final message in state.messages) {
      // Agregar el mensaje
      final hasText = message.text != null && message.text!.isNotEmpty;
      final isSystemMessage = message.type == ChatMessageType.systemResponse ||
                              message.type == ChatMessageType.systemAction;
      
      if (isSystemMessage && hasText) {
        widgets.add(ChatMessageBubble(
          key: ValueKey('msg_${message.id}'),
          message: message,
          onTapSystemMessage: () => _speakMessage(message.text!),
        ));
      } else if (message.type == ChatMessageType.systemError) {
        widgets.add(ChatMessageBubble(
          key: ValueKey('msg_${message.id}'),
          message: message,
          onRetry: message.originalTranscription != null
              ? () => cubit.retryMessage(message.id)
              : null,
        ));
      } else {
        widgets.add(ChatMessageBubble(
          key: ValueKey('msg_${message.id}'),
          message: message,
        ));
      }

      // Buscar y agregar TODOS los previews vinculados a este mensaje
      final linkedPreviews = state.pendingPreviews
          .where((p) => p.messageId == message.id && !usedPreviewIds.contains(p.id))
          .toList();
      
      for (final preview in linkedPreviews) {
        widgets.add(PendingPreviewCard(
          key: ValueKey('preview_${preview.id}'),
          preview: preview,
          onRemove: () => cubit.removePendingPreview(preview.id),
        ));
        usedPreviewIds.add(preview.id);
      }

      // Agregar items de creación si el mensaje tiene response con acción de creación
      if (message.type == ChatMessageType.systemResponse &&
          message.response != null) {
        final action = message.response!.action;

        if (action.name == 'createReminder' || action.name == 'createNote') {
          // Buscar el próximo item no usado (mantiene compatibilidad con items sin messageId)
          final nextItem = state.pendingItems
              .where((i) => !usedItemIds.contains(i.id))
              .firstOrNull;
          
          if (nextItem != null) {
            widgets.add(PendingCreationCard(
              key: ValueKey('item_${nextItem.id}'),
              item: nextItem,
              onRemove: () => cubit.removePendingItem(nextItem.id),
            ));
            usedItemIds.add(nextItem.id);
          }
        }
      }
    }

    // Agregar previews huérfanos (sin messageId válido)
    for (final preview in state.pendingPreviews) {
      if (!usedPreviewIds.contains(preview.id)) {
        widgets.add(PendingPreviewCard(
          key: ValueKey('preview_${preview.id}'),
          preview: preview,
          onRemove: () => cubit.removePendingPreview(preview.id),
        ));
      }
    }

    // Agregar items huérfanos
    for (final item in state.pendingItems) {
      if (!usedItemIds.contains(item.id)) {
        widgets.add(PendingCreationCard(
          key: ValueKey('item_${item.id}'),
          item: item,
          onRemove: () => cubit.removePendingItem(item.id),
        ));
      }
    }

    return widgets;
  }

  Widget _buildRecordingIndicator(bool isDark, VoiceChatReady state) {
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final liveText = state.liveTranscription;
    final hasLiveText = liveText != null && liveText.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Escuchando...',
              style: AppTypography.bodySmall.copyWith(
                color: secondaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SoundWaveIndicator(
              width: MediaQuery.of(context).size.width * 0.55,
              height: 56,
              barCount: 28,
            ),
            if (hasLiveText) ...[
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  liveText,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator(bool isDark) {
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.md,
          top: AppSpacing.sm,
          bottom: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const ThinkingIndicator(size: 48),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Pensando...',
              style: AppTypography.bodySmall.copyWith(
                color: secondaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Prompt idle (estado inicial, sin mensajes)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildIdlePrompt(BuildContext context, VoiceChatReady state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final helperColor =
        isDark ? AppColors.textHelperDark : AppColors.textHelper;

    if (state.isRecording) {
      return _buildIdleRecording(context, state, isDark, secondaryColor);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: secondaryColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Dime lo que necesitas',
            style: AppTypography.bodyLarge.copyWith(color: secondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Escribe o usa el micrófono',
            style: AppTypography.helper.copyWith(color: helperColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildExampleChips(isDark),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildIdleRecording(
    BuildContext context,
    VoiceChatReady state,
    bool isDark,
    Color secondaryColor,
  ) {
    final liveText = state.liveTranscription;
    final hasLiveText = liveText != null && liveText.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          const Spacer(flex: 3),
          Text(
            'Escuchando...',
            style: AppTypography.bodyLarge.copyWith(
              color: secondaryColor,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          SoundWaveIndicator(
            width: MediaQuery.of(context).size.width * 0.65,
            height: 72,
            barCount: 32,
          ),
          if (hasLiveText) ...[
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                liveText,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildExampleChips(bool isDark) {
    final helperColor =
        isDark ? AppColors.textHelperDark : AppColors.textHelper;
    final bgColor = isDark ? AppColors.bgTertiaryDark : AppColors.bgTertiary;
    final cubit = context.read<VoiceChatCubit>();

    final examples = [
      'Recordarme tomar pastillas a las 3pm',
      'Dejé las llaves en la cocina',
      '¿Qué tengo pendiente hoy?',
    ];

    return Column(
      children: examples.map((example) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: GestureDetector(
            onTap: () => cubit.sendTextMessage(example),
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
                '"$example"',
                style: AppTypography.bodySmall.copyWith(
                  color: helperColor,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Vista de guardado
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSavingView(BuildContext context, VoiceChatSaving state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              value: state.progress > 0 ? state.progress : null,
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(primaryColor),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Guardando recordatorios...',
            style: AppTypography.titleSmall.copyWith(color: textColor),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${state.savedCount} de ${state.totalCount}',
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Logica de grabacion
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _toggleRecording(BuildContext context) async {
    _feedbackService.medium();
    final cubit = context.read<VoiceChatCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final currentState = cubit.state;

    if (currentState is! VoiceChatReady) return;

    if (!_isInitialized) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(_initError ?? 'Reconocimiento de voz no disponible'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (currentState.isRecording) {
      // Detener grabacion
      await _speechService.stopListening();
      final transcription = currentState.liveTranscription ?? '';
      await cubit.stopAndProcess(transcription);
    } else {
      // Iniciar grabacion
      cubit.startRecording();
      try {
        await _speechService.startListening(
          onResult: (text, isFinal) {
            if (mounted) {
              cubit.updateTranscription(text);
              if (isFinal && text.isNotEmpty) {
                cubit.stopAndProcess(text);
              }
            }
          },
          onError: (error) {
            if (mounted) {
              messenger.showSnackBar(
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
          messenger.showSnackBar(
            SnackBar(
              content: Text('Error al iniciar: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dialogo de confirmacion
  // ─────────────────────────────────────────────────────────────────────────

  void _showDiscardDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: bgColor,
          title: Text(
            'Descartar recordatorios',
            style: AppTypography.titleSmall.copyWith(color: textColor),
          ),
          content: Text(
            'Tienes recordatorios pendientes que no se han guardado. ¿Deseas descartarlos?',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<VoiceChatCubit>().reset();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Descartar'),
            ),
          ],
        );
      },
    );
  }
}

