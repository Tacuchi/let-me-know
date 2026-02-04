import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../../di/injection_container.dart';
import '../../../../router/app_routes.dart';
import '../../../../services/assistant/models/assistant_response.dart';
import '../../../../services/speech_to_text/speech_to_text_service.dart';
import '../../../../services/tts/tts_service.dart';
import '../../application/cubit/voice_chat_cubit.dart';
import '../../application/cubit/voice_chat_state.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/pending_creation.dart';
import 'chat_message_bubble.dart';
import 'pending_batch_card.dart';
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
      if (_scrollController.hasClients) {
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
      final router = GoRouter.of(context);

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

      // Navegar a Home
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        router.pop();
        router.goNamed(AppRoutes.homeName);
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

    // Construir la lista de widgets: mensajes + cards pendientes intercalados
    final items = <Widget>[];

    // Indice para rastrear que pending items mostrar despues de cada mensaje
    int pendingIndex = 0;

    for (final message in state.messages) {
      // Para mensajes del sistema, agregar callback de TTS
      if (message.type == ChatMessageType.systemResponse &&
          message.text != null &&
          message.text!.isNotEmpty) {
        items.add(ChatMessageBubble(
          message: message,
          onTapSystemMessage: () => _speakMessage(message.text!),
        ));
      } else {
        items.add(ChatMessageBubble(message: message));
      }

      // Despues de un systemResponse de creacion, mostrar los pending cards
      // que fueron agregados con ese mensaje
      if (message.type == ChatMessageType.systemResponse &&
          message.response != null) {
        final action = message.response!.action;
        final isCreation = _isCreationAction(action);
        final isPreview = action == AssistantAction.previewBatch;

        if (isCreation) {
          // Contar cuantos items agregar
          final count = _getPendingCountForAction(message.response!);
          final end = (pendingIndex + count).clamp(0, state.pendingItems.length);
          final itemsToShow = state.pendingItems.sublist(pendingIndex, end);

          // Agrupar por batchGroupId para mostrar cards compactas
          items.addAll(_buildPendingCards(context, itemsToShow));
          pendingIndex = end;
        } else if (isPreview) {
          // Mostrar preview card para el batch
          items.addAll(_buildPreviewCards(context, state));
        }
      }
    }

    // Mostrar pending items que no se hayan mostrado (por si hay desync)
    if (pendingIndex < state.pendingItems.length) {
      final remaining = state.pendingItems.sublist(pendingIndex);
      items.addAll(_buildPendingCards(context, remaining));
    }

    // Indicador de grabacion/procesamiento al final
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

  /// Construye widgets para los items pendientes, agrupando batches.
  List<Widget> _buildPendingCards(BuildContext context, List<PendingCreation> items) {
    if (items.isEmpty) return [];

    final widgets = <Widget>[];
    final processedGroupIds = <String>{};

    for (final item in items) {
      // Si es parte de un batch, mostrar card agrupada
      if (item.batchGroupId != null) {
        if (processedGroupIds.contains(item.batchGroupId)) continue;
        processedGroupIds.add(item.batchGroupId!);

        // Obtener todos los items del mismo grupo
        final groupItems = items
            .where((i) => i.batchGroupId == item.batchGroupId)
            .toList();

        widgets.add(PendingBatchCard(
          key: ValueKey('batch_${item.batchGroupId}'),
          items: groupItems,
          groupLabel: item.batchGroupLabel ?? 'Tratamiento',
          onRemove: () => _removeAllInGroup(context, item.batchGroupId!),
        ));
      } else {
        // Item individual
        widgets.add(PendingCreationCard(
          key: ValueKey(item.id),
          item: item,
          onRemove: () =>
              context.read<VoiceChatCubit>().removePendingItem(item.id),
        ));
      }
    }

    return widgets;
  }

  void _removeAllInGroup(BuildContext context, String groupId) {
    final cubit = context.read<VoiceChatCubit>();
    final state = cubit.state;
    if (state is! VoiceChatReady) return;

    // Eliminar todos los items del grupo
    final idsToRemove = state.pendingItems
        .where((i) => i.batchGroupId == groupId)
        .map((i) => i.id)
        .toList();

    for (final id in idsToRemove) {
      cubit.removePendingItem(id);
    }
  }

  /// Construye widgets para los previews de batch.
  List<Widget> _buildPreviewCards(BuildContext context, VoiceChatReady state) {
    return state.pendingPreviews.map((preview) {
      return PendingPreviewCard(
        key: ValueKey('preview_${preview.id}'),
        preview: preview,
        onRemove: () => context.read<VoiceChatCubit>().removePendingPreview(preview.id),
      );
    }).toList();
  }

  bool _isCreationAction(AssistantAction action) {
    return switch (action) {
      AssistantAction.createReminder ||
      AssistantAction.createNote ||
      AssistantAction.createBatch => true,
      _ => false,
    };
  }

  int _getPendingCountForAction(AssistantResponse response) {
    if (response.action == AssistantAction.createBatch) {
      return response.batchCreateData?.items.length ?? 1;
    }
    return 1;
  }

  Widget _buildRecordingIndicator(bool isDark, VoiceChatReady state) {
    final primaryColor =
        isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;
    final liveText = state.liveTranscription;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(
          left: AppSpacing.xl,
          bottom: AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
          border: Border.all(
            color: AppColors.recording.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulsingDot(),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                liveText != null && liveText.isNotEmpty
                    ? liveText
                    : 'Escuchando...',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontStyle: liveText == null || liveText.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator(bool isDark) {
    final primaryColor =
        isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(primaryColor),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Procesando...',
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
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
    final primaryColor =
        isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          const Spacer(flex: 2),
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
          _buildExampleChips(isDark),
          const Spacer(flex: 1),
          AnimatedMicButton(
            isRecording: state.isRecording,
            onTap: () => _toggleRecording(context),
            size: 88,
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              key: ValueKey(state.isRecording ? 'stop' : 'start'),
              state.isRecording ? 'Toca para finalizar' : 'Toca para hablar',
              style: AppTypography.helper.copyWith(
                color: state.isRecording ? primaryColor : secondaryColor,
                fontWeight:
                    state.isRecording ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildExampleChips(bool isDark) {
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
                context.pop();
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

/// Punto rojo pulsante para indicar grabacion.
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.recording
                .withValues(alpha: 0.5 + _controller.value * 0.5),
          ),
        );
      },
    );
  }
}
