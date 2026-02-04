import 'package:equatable/equatable.dart';

import '../../../reminders/domain/entities/reminder_importance.dart';
import '../../../reminders/domain/entities/reminder_type.dart';
import '../../../../services/assistant/models/assistant_response.dart';

/// Un recordatorio/nota pendiente de crear, parseado por el LLM
/// pero NO guardado aun en la base de datos.
class PendingCreation extends Equatable {
  /// ID local para tracking y eliminacion.
  final String id;

  final String title;
  final ReminderType reminderType;
  final ReminderImportance importance;
  final DateTime? scheduledAt;
  final String? object;
  final String? location;
  final String? person;

  /// Si pertenece a un batch (grupo).
  final String? batchGroupId;
  final String? batchGroupLabel;

  /// Transcripcion original del usuario.
  final String sourceTranscription;

  final DateTime addedAt;

  const PendingCreation({
    required this.id,
    required this.title,
    required this.reminderType,
    required this.importance,
    this.scheduledAt,
    this.object,
    this.location,
    this.person,
    this.batchGroupId,
    this.batchGroupLabel,
    required this.sourceTranscription,
    required this.addedAt,
  });

  bool get isNote => reminderType == ReminderType.location;
  bool get hasBatchGroup => batchGroupId != null;

  /// Crea un PendingCreation desde un CreateReminderData del LLM.
  factory PendingCreation.fromCreateReminder({
    required String id,
    required CreateReminderData data,
    required String sourceTranscription,
    String? batchGroupId,
    String? batchGroupLabel,
  }) {
    return PendingCreation(
      id: id,
      title: data.title,
      reminderType: data.type,
      importance: data.importance,
      scheduledAt: data.scheduledAt,
      object: data.object,
      location: data.location,
      person: data.person,
      batchGroupId: batchGroupId,
      batchGroupLabel: batchGroupLabel,
      sourceTranscription: sourceTranscription,
      addedAt: DateTime.now(),
    );
  }

  /// Crea un PendingCreation desde un CreateNoteData del LLM.
  factory PendingCreation.fromCreateNote({
    required String id,
    required CreateNoteData data,
    required String sourceTranscription,
  }) {
    return PendingCreation(
      id: id,
      title: data.title,
      reminderType: ReminderType.location,
      importance: data.importance,
      scheduledAt: null,
      object: data.object,
      location: data.location,
      sourceTranscription: sourceTranscription,
      addedAt: DateTime.now(),
    );
  }

  /// Convierte a un Map para enviar como sessionItem al LLM.
  Map<String, dynamic> toSessionItemJson() {
    return {
      'title': title,
      'type': reminderType.name.toUpperCase(),
      'importance': importance.name.toUpperCase(),
      if (scheduledAt != null)
        'scheduledAt': scheduledAt!.toIso8601String().split('.').first,
      if (batchGroupId != null) 'groupId': batchGroupId,
      if (batchGroupLabel != null) 'groupLabel': batchGroupLabel,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        reminderType,
        importance,
        scheduledAt,
        object,
        location,
        person,
        batchGroupId,
        batchGroupLabel,
        sourceTranscription,
        addedAt,
      ];
}
