import 'package:equatable/equatable.dart';

import '../../domain/models/chat_message.dart';
import '../../domain/models/pending_creation.dart';
import '../../domain/models/pending_preview.dart';

/// Fase del mic/procesamiento dentro de VoiceChatReady.
enum VoiceChatPhase {
  /// Esperando que el usuario toque el mic.
  idle,

  /// Grabando, transcripcion en tiempo real.
  recording,

  /// El LLM esta procesando la transcripcion.
  processing,
}

/// Estado del flujo de chat de voz.
sealed class VoiceChatState extends Equatable {
  const VoiceChatState();
}

/// Estado principal que persiste durante toda la sesion multi-turno.
final class VoiceChatReady extends VoiceChatState {
  /// Historial completo de la conversacion.
  final List<ChatMessage> messages;

  /// Items pendientes de guardar en DB (items individuales).
  final List<PendingCreation> pendingItems;

  /// Previews de batch pendientes de confirmar.
  /// Al "Finalizar", se enviará [originalRequest] a /process.
  final List<PendingPreview> pendingPreviews;

  /// Fase actual del mic/procesamiento.
  final VoiceChatPhase phase;

  /// Texto de transcripcion en tiempo real (mientras se graba).
  final String? liveTranscription;

  /// Error de la ultima operacion (no bloquea, se muestra inline).
  final String? lastError;

  const VoiceChatReady({
    this.messages = const [],
    this.pendingItems = const [],
    this.pendingPreviews = const [],
    this.phase = VoiceChatPhase.idle,
    this.liveTranscription,
    this.lastError,
  });

  bool get hasMessages => messages.isNotEmpty;
  bool get hasPendingItems => pendingItems.isNotEmpty || pendingPreviews.isNotEmpty;
  int get pendingCount => pendingItems.length + pendingPreviews.length;
  bool get isRecording => phase == VoiceChatPhase.recording;
  bool get isProcessing => phase == VoiceChatPhase.processing;

  /// Cantidad estimada total de recordatorios (items + previews).
  int get estimatedTotalCount {
    final itemsCount = pendingItems.length;
    final previewsCount = pendingPreviews.fold(0, (sum, p) => sum + p.estimatedCount);
    return itemsCount + previewsCount;
  }

  VoiceChatReady copyWith({
    List<ChatMessage>? messages,
    List<PendingCreation>? pendingItems,
    List<PendingPreview>? pendingPreviews,
    VoiceChatPhase? phase,
    String? Function()? liveTranscription,
    String? Function()? lastError,
  }) {
    return VoiceChatReady(
      messages: messages ?? this.messages,
      pendingItems: pendingItems ?? this.pendingItems,
      pendingPreviews: pendingPreviews ?? this.pendingPreviews,
      phase: phase ?? this.phase,
      liveTranscription:
          liveTranscription != null ? liveTranscription() : this.liveTranscription,
      lastError: lastError != null ? lastError() : this.lastError,
    );
  }

  @override
  List<Object?> get props =>
      [messages, pendingItems, pendingPreviews, phase, liveTranscription, lastError];
}

/// Guardando los items pendientes en la base de datos.
final class VoiceChatSaving extends VoiceChatState {
  final int savedCount;
  final int totalCount;

  const VoiceChatSaving({
    required this.savedCount,
    required this.totalCount,
  });

  double get progress => totalCount > 0 ? savedCount / totalCount : 0;

  @override
  List<Object?> get props => [savedCount, totalCount];
}

/// Todos los items fueron guardados exitosamente.
final class VoiceChatCompleted extends VoiceChatState {
  final int totalSaved;
  final String summaryMessage;

  const VoiceChatCompleted({
    required this.totalSaved,
    required this.summaryMessage,
  });

  @override
  List<Object?> get props => [totalSaved, summaryMessage];
}
