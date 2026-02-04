import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/feedback_service.dart';
import '../../../../services/assistant/models/assistant_response.dart';
import '../../../../services/assistant/models/preview_response.dart';
import '../../../../services/assistant/voice_assistant_service.dart';
import '../../../../services/tts/tts_service.dart';
import '../../../groups/domain/entities/reminder_group.dart';
import '../../../groups/domain/repositories/group_repository.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../../reminders/domain/entities/reminder_source.dart';
import '../../../reminders/domain/entities/reminder_status.dart';
import '../../../reminders/domain/repositories/reminder_repository.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/pending_creation.dart';
import '../../domain/models/pending_preview.dart';
import 'voice_chat_state.dart';

/// Cubit que gestiona la sesion multi-turno de chat de voz.
///
/// Acumula items de creacion (recordatorios, notas, batch) en una lista
/// pendiente y los guarda todos al finalizar la sesion.
class VoiceChatCubit extends Cubit<VoiceChatState> {
  final VoiceAssistantService _assistantService;
  final ReminderRepository _reminderRepository;
  final GroupRepository _groupRepository;
  final TtsService _ttsService;
  final FeedbackService _feedbackService;

  static const _uuid = Uuid();

  VoiceChatCubit({
    required VoiceAssistantService assistantService,
    required ReminderRepository reminderRepository,
    required GroupRepository groupRepository,
    required TtsService ttsService,
    required FeedbackService feedbackService,
  })  : _assistantService = assistantService,
        _reminderRepository = reminderRepository,
        _groupRepository = groupRepository,
        _ttsService = ttsService,
        _feedbackService = feedbackService,
        super(const VoiceChatReady());

  // ─────────────────────────────────────────────────────────────────────────
  // Grabacion
  // ─────────────────────────────────────────────────────────────────────────

  /// Inicia la fase de grabacion.
  void startRecording() {
    final current = state;
    if (current is! VoiceChatReady) return;

    _ttsService.stop();
    emit(current.copyWith(
      phase: VoiceChatPhase.recording,
      liveTranscription: () => '',
      lastError: () => null,
    ));
  }

  /// Actualiza la transcripcion en tiempo real mientras se graba.
  void updateTranscription(String text) {
    final current = state;
    if (current is! VoiceChatReady) return;

    emit(current.copyWith(liveTranscription: () => text));
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Procesamiento
  // ─────────────────────────────────────────────────────────────────────────────

  /// Envía un mensaje de texto (escrito) para procesar.
  /// Primero intenta obtener un preview si parece un batch.
  Future<void> sendTextMessage(String text) async {
    final current = state;
    if (current is! VoiceChatReady) return;
    if (text.trim().isEmpty) return;

    _ttsService.stop();

    // Agregar mensaje del usuario (tipo texto)
    final userMessage = ChatMessage.userText(
      id: _uuid.v4(),
      text: text,
    );

    final updatedMessages = [...current.messages, userMessage];

    emit(current.copyWith(
      messages: updatedMessages,
      phase: VoiceChatPhase.processing,
    ));

    try {
      // Primero intentar obtener preview (para batches)
      final previewResponse = await _assistantService.preview(text);

      if (isClosed) return;

      if (previewResponse.hasPreviewBatches) {
        // Es un batch - mostrar preview(s)
        _handlePreviewResponse(previewResponse);
        return;
      }

      // No es batch o necesita aclaración - usar /process normal
      final sessionItems = current.pendingItems
          .map((item) => item.toSessionItemJson())
          .toList();

      final response = await _assistantService.process(
        text,
        sessionItems: sessionItems,
      );

      if (isClosed) return;
      _handleResponse(response, text);
    } catch (e) {
      if (isClosed) return;
      _handleError(e, text);
    }
  }

  /// Detiene la grabacion y procesa la transcripcion con el LLM.
  /// Primero intenta obtener un preview si parece un batch.
  Future<void> stopAndProcess(String transcription) async {
    final current = state;
    if (current is! VoiceChatReady) return;
    if (transcription.trim().isEmpty) {
      emit(current.copyWith(
        phase: VoiceChatPhase.idle,
        liveTranscription: () => null,
      ));
      return;
    }

    // Agregar mensaje del usuario
    final userMessage = ChatMessage.userVoice(
      id: _uuid.v4(),
      text: transcription,
    );

    final updatedMessages = [...current.messages, userMessage];

    emit(current.copyWith(
      messages: updatedMessages,
      phase: VoiceChatPhase.processing,
      liveTranscription: () => null,
    ));

    try {
      // Primero intentar obtener preview (para batches)
      final previewResponse = await _assistantService.preview(transcription);

      if (isClosed) return;

      if (previewResponse.hasPreviewBatches) {
        // Es un batch - mostrar preview(s)
        _handlePreviewResponse(previewResponse);
        return;
      }

      // No es batch - usar /process normal
      final sessionItems = current.pendingItems
          .map((item) => item.toSessionItemJson())
          .toList();

      final response = await _assistantService.process(
        transcription,
        sessionItems: sessionItems,
      );

      if (isClosed) return;

      _handleResponse(response, transcription);
    } catch (e) {
      if (isClosed) return;
      _handleError(e, transcription);
    }
  }

  void _handleResponse(AssistantResponse response, String transcription) {
    final current = state;
    if (current is! VoiceChatReady) return;

    final isCreation = _isCreationAction(response.action);

    if (isCreation) {
      _handleCreationResponse(response, transcription);
    } else if (_isImmediateAction(response.action)) {
      _handleImmediateAction(response);
    } else {
      // Consultas, clarificaciones, no-action
      _handleInfoResponse(response);
    }
  }

  void _handlePreviewResponse(PreviewResponse response) {
    final current = state;
    if (current is! VoiceChatReady) return;

    // Crear mensaje primero para obtener su ID
    final messageId = _uuid.v4();
    final systemMessage = ChatMessage.systemAction(
      id: messageId,
      text: response.spokenResponse,
    );

    // Crear previews vinculados al mensaje
    final newPreviews = <PendingPreview>[];
    for (final item in response.batchPreviews) {
      final previewData = item.previewData;
      if (previewData == null) continue;

      newPreviews.add(PendingPreview.fromPreviewData(
        id: _uuid.v4(),
        messageId: messageId,
        data: previewData,
        spokenResponse: '', // El spoken combinado viene en el mensaje
      ));
    }

    if (newPreviews.isEmpty) return;

    emit(current.copyWith(
      messages: [...current.messages, systemMessage],
      pendingPreviews: [...current.pendingPreviews, ...newPreviews],
      phase: VoiceChatPhase.idle,
    ));

    _feedbackService.success();

    if (response.spokenResponse.isNotEmpty) {
      _ttsService.speak(response.spokenResponse);
    }
  }

  void _handleCreationResponse(
    AssistantResponse response,
    String transcription,
  ) {
    final current = state;
    if (current is! VoiceChatReady) return;

    final newPending = <PendingCreation>[];

    switch (response.action) {
      case AssistantAction.createReminder:
        final data = response.createReminderData!;
        newPending.add(PendingCreation.fromCreateReminder(
          id: _uuid.v4(),
          data: data,
          sourceTranscription: transcription,
        ));

      case AssistantAction.createNote:
        final data = response.createNoteData!;
        newPending.add(PendingCreation.fromCreateNote(
          id: _uuid.v4(),
          data: data,
          sourceTranscription: transcription,
        ));

      case AssistantAction.createBatch:
        final data = response.batchCreateData!;
        for (final item in data.items) {
          newPending.add(PendingCreation.fromCreateReminder(
            id: _uuid.v4(),
            data: item,
            sourceTranscription: transcription,
            batchGroupId: data.groupId,
            batchGroupLabel: data.groupLabel,
          ));
        }

      default:
        break;
    }

    final systemMessage = ChatMessage.systemResponse(
      id: _uuid.v4(),
      response: response,
    );

    emit(current.copyWith(
      messages: [...current.messages, systemMessage],
      pendingItems: [...current.pendingItems, ...newPending],
      phase: VoiceChatPhase.idle,
    ));

    _feedbackService.success();

    if (response.spokenResponse.isNotEmpty) {
      _ttsService.speak(response.spokenResponse);
    }
  }

  Future<void> _handleImmediateAction(AssistantResponse response) async {
    final current = state;
    if (current is! VoiceChatReady) return;

    // Ejecutar accion inmediata contra la DB
    await _executeImmediateAction(response);

    final systemMessage = ChatMessage.systemAction(
      id: _uuid.v4(),
      text: response.spokenResponse,
    );

    emit(current.copyWith(
      messages: [...current.messages, systemMessage],
      phase: VoiceChatPhase.idle,
    ));

    _feedbackService.medium();

    if (response.spokenResponse.isNotEmpty) {
      _ttsService.speak(response.spokenResponse);
    }
  }

  void _handleInfoResponse(AssistantResponse response) {
    final current = state;
    if (current is! VoiceChatReady) return;

    final systemMessage = ChatMessage.systemResponse(
      id: _uuid.v4(),
      response: response,
    );

    emit(current.copyWith(
      messages: [...current.messages, systemMessage],
      phase: VoiceChatPhase.idle,
    ));

    if (response.spokenResponse.isNotEmpty) {
      _ttsService.speak(response.spokenResponse);
    }
  }

  void _handleError(Object error, String originalTranscription) {
    final current = state;
    if (current is! VoiceChatReady) return;

    String errorText;
    if (error.toString().contains('ApiConnectionException') ||
        error.toString().contains('SocketException')) {
      errorText = 'No se pudo conectar al servidor';
    } else if (error.toString().contains('ApiException')) {
      errorText = 'Error del servidor: $error';
    } else {
      errorText = 'Error inesperado: $error';
    }

    final errorMessage = ChatMessage.systemError(
      id: _uuid.v4(),
      errorText: errorText,
      originalTranscription: originalTranscription,
    );

    emit(current.copyWith(
      messages: [...current.messages, errorMessage],
      phase: VoiceChatPhase.idle,
      lastError: () => errorText,
    ));
  }

  /// Reintenta procesar un mensaje que falló.
  Future<void> retryMessage(String messageId) async {
    final current = state;
    if (current is! VoiceChatReady) return;

    // Buscar el mensaje de error
    final errorMessage = current.messages
        .where((m) => m.id == messageId && m.type == ChatMessageType.systemError)
        .firstOrNull;
    
    if (errorMessage?.originalTranscription == null) return;

    // Eliminar el mensaje de error
    final updatedMessages = current.messages
        .where((m) => m.id != messageId)
        .toList();
    
    emit(current.copyWith(
      messages: updatedMessages,
      phase: VoiceChatPhase.processing,
    ));

    // Reintentar el procesamiento
    final transcription = errorMessage!.originalTranscription!;
    
    try {
      final previewResponse = await _assistantService.preview(transcription);

      if (isClosed) return;

      if (previewResponse.hasPreviewBatches) {
        _handlePreviewResponse(previewResponse);
        return;
      }

      final sessionItems = current.pendingItems
          .map((item) => item.toSessionItemJson())
          .toList();

      final response = await _assistantService.process(
        transcription,
        sessionItems: sessionItems,
      );

      if (isClosed) return;
      _handleResponse(response, transcription);
    } catch (e) {
      if (isClosed) return;
      _handleError(e, transcription);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Items pendientes
  // ─────────────────────────────────────────────────────────────────────────

  /// Elimina un item pendiente de la lista.
  void removePendingItem(String id) {
    final current = state;
    if (current is! VoiceChatReady) return;

    final updated = current.pendingItems.where((item) => item.id != id).toList();

    emit(current.copyWith(pendingItems: updated));
    _feedbackService.light();
  }

  /// Elimina un preview pendiente de la lista.
  void removePendingPreview(String id) {
    final current = state;
    if (current is! VoiceChatReady) return;

    final updated = current.pendingPreviews.where((p) => p.id != id).toList();

    emit(current.copyWith(pendingPreviews: updated));
    _feedbackService.light();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Finalizacion
  // ─────────────────────────────────────────────────────────────────────────

  /// Guarda todos los items pendientes en la base de datos.
  /// Para previews, primero llama a /process para generar los items reales.
  Future<void> finalize() async {
    final current = state;
    if (current is! VoiceChatReady || !current.hasPendingItems) return;

    // Estimar total de items
    final estimatedTotal = current.estimatedTotalCount;
    emit(VoiceChatSaving(savedCount: 0, totalCount: estimatedTotal));

    final allItems = <PendingCreation>[...current.pendingItems];

    // Procesar cada preview: llamar /process para obtener los items reales
    for (final preview in current.pendingPreviews) {
      try {
        final response = await _assistantService.process(
          preview.originalRequest,
          sessionItems: [], // Sin contexto de sesión para el batch
        );

        if (response.action == AssistantAction.createBatch) {
          final batchData = response.batchCreateData!;
          for (final item in batchData.items) {
            allItems.add(PendingCreation.fromCreateReminder(
              id: _uuid.v4(),
              data: item,
              sourceTranscription: preview.originalRequest,
              batchGroupId: batchData.groupId,
              batchGroupLabel: batchData.groupLabel,
            ));
          }
        }
      } catch (e) {
        // Si falla un preview, continuar con los demás
        continue;
      }
    }

    if (allItems.isEmpty) {
      emit(const VoiceChatReady());
      return;
    }

    // Actualizar total real
    final totalCount = allItems.length;
    if (!isClosed) {
      emit(VoiceChatSaving(savedCount: 0, totalCount: totalCount));
    }

    // Crear grupos necesarios primero
    final groupsCreated = <String>{};
    for (final item in allItems) {
      if (item.batchGroupId != null && !groupsCreated.contains(item.batchGroupId)) {
        final groupItems =
            allItems.where((i) => i.batchGroupId == item.batchGroupId).toList();
        final group = ReminderGroup(
          id: item.batchGroupId!,
          label: item.batchGroupLabel ?? 'Grupo',
          type: 'medication',
          itemCount: groupItems.length,
          createdAt: DateTime.now(),
        );
        await _groupRepository.save(group);
        groupsCreated.add(item.batchGroupId!);
      }
    }

    // Guardar cada recordatorio
    for (var i = 0; i < allItems.length; i++) {
      final item = allItems[i];
      final reminder = Reminder(
        id: _uuid.v4(),
        title: item.title,
        description: item.sourceTranscription,
        scheduledAt: item.scheduledAt,
        type: item.reminderType,
        status: ReminderStatus.pending,
        importance: item.importance,
        source: ReminderSource.voice,
        object: item.object,
        location: item.location,
        hasNotification: item.scheduledAt != null,
        recurrenceGroupId: item.batchGroupId,
        createdAt: DateTime.now(),
      );
      await _reminderRepository.save(reminder);

      if (!isClosed) {
        emit(VoiceChatSaving(savedCount: i + 1, totalCount: totalCount));
      }
    }

    await _feedbackService.success();

    if (!isClosed) {
      final message = allItems.length == 1
          ? 'Se creo 1 recordatorio'
          : 'Se crearon ${allItems.length} recordatorios';

      _ttsService.speak(message);

      emit(VoiceChatCompleted(
        totalSaved: allItems.length,
        summaryMessage: message,
      ));
    }
  }

  /// Resetea la sesion al estado inicial.
  void reset() {
    _ttsService.stop();
    emit(const VoiceChatReady());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  bool _isCreationAction(AssistantAction action) {
    return switch (action) {
      AssistantAction.createReminder => true,
      AssistantAction.createNote => true,
      AssistantAction.createBatch => true,
      _ => false,
    };
  }

  bool _isImmediateAction(AssistantAction action) {
    return switch (action) {
      AssistantAction.completeReminder => true,
      AssistantAction.deleteReminder => true,
      AssistantAction.deleteGroup => true,
      AssistantAction.updateReminder => true,
      _ => false,
    };
  }

  Future<void> _executeImmediateAction(AssistantResponse response) async {
    switch (response.action) {
      case AssistantAction.completeReminder:
        final data = response.completeReminderData;
        if (data != null) {
          await _reminderRepository.markAsCompleted(data.reminderId);
        }

      case AssistantAction.deleteReminder:
        final data = response.deleteReminderData;
        if (data != null) {
          await _reminderRepository.delete(data.reminderId);
        }

      case AssistantAction.deleteGroup:
        final data = response.deleteGroupData;
        if (data != null) {
          final reminders = await _reminderRepository.getAll();
          final groupReminders = reminders
              .where((r) => r.recurrenceGroupId == data.groupId)
              .toList();
          for (final reminder in groupReminders) {
            await _reminderRepository.delete(reminder.id);
          }
          await _groupRepository.delete(data.groupId);
        }

      default:
        break;
    }
  }
}
