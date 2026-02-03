import '../../../features/reminders/domain/entities/reminder_importance.dart';
import '../../../features/reminders/domain/entities/reminder_type.dart';

/// Acciones que el LLM puede solicitar.
enum AssistantAction {
  createReminder,
  createNote,
  createBatch,
  updateReminder,
  completeReminder,
  deleteReminder,
  deleteGroup,
  queryResponse,
  clarificationNeeded,
  noAction,
}

/// Respuesta del backend LLM.
class AssistantResponse {
  final AssistantAction action;
  final dynamic data;
  final String spokenResponse;

  const AssistantResponse({
    required this.action,
    this.data,
    required this.spokenResponse,
  });

  factory AssistantResponse.fromJson(Map<String, dynamic> json) {
    final actionStr = json['action'] as String;
    final action = _parseAction(actionStr);
    final data = _parseData(action, json['data']);
    final spokenResponse = json['spokenResponse'] as String? ?? '';

    return AssistantResponse(
      action: action,
      data: data,
      spokenResponse: spokenResponse,
    );
  }

  /// Datos tipados para CREATE_REMINDER.
  CreateReminderData? get createReminderData =>
      action == AssistantAction.createReminder ? data as CreateReminderData : null;

  /// Datos tipados para CREATE_NOTE.
  CreateNoteData? get createNoteData =>
      action == AssistantAction.createNote ? data as CreateNoteData : null;

  /// Datos tipados para COMPLETE_REMINDER.
  CompleteReminderData? get completeReminderData =>
      action == AssistantAction.completeReminder ? data as CompleteReminderData : null;

  /// Datos tipados para DELETE_REMINDER.
  DeleteReminderData? get deleteReminderData =>
      action == AssistantAction.deleteReminder ? data as DeleteReminderData : null;

  /// Datos tipados para CREATE_BATCH.
  BatchCreateData? get batchCreateData =>
      action == AssistantAction.createBatch ? data as BatchCreateData : null;

  /// Datos tipados para DELETE_GROUP.
  DeleteGroupData? get deleteGroupData =>
      action == AssistantAction.deleteGroup ? data as DeleteGroupData : null;

  /// Datos tipados para QUERY_RESPONSE.
  QueryResponseData? get queryResponseData =>
      action == AssistantAction.queryResponse ? data as QueryResponseData : null;

  /// Datos tipados para CLARIFICATION_NEEDED.
  ClarificationData? get clarificationData =>
      action == AssistantAction.clarificationNeeded ? data as ClarificationData : null;

  /// Datos tipados para NO_ACTION.
  NoActionData? get noActionData =>
      action == AssistantAction.noAction ? data as NoActionData : null;

  static AssistantAction _parseAction(String action) {
    return switch (action) {
      'CREATE_REMINDER' => AssistantAction.createReminder,
      'CREATE_NOTE' => AssistantAction.createNote,
      'CREATE_BATCH' => AssistantAction.createBatch,
      'UPDATE_REMINDER' => AssistantAction.updateReminder,
      'COMPLETE_REMINDER' => AssistantAction.completeReminder,
      'DELETE_REMINDER' => AssistantAction.deleteReminder,
      'DELETE_GROUP' => AssistantAction.deleteGroup,
      'QUERY_RESPONSE' => AssistantAction.queryResponse,
      'CLARIFICATION_NEEDED' => AssistantAction.clarificationNeeded,
      'NO_ACTION' => AssistantAction.noAction,
      _ => AssistantAction.noAction,
    };
  }

  static dynamic _parseData(AssistantAction action, dynamic json) {
    if (json == null) return null;
    final map = json as Map<String, dynamic>;

    return switch (action) {
      AssistantAction.createReminder => CreateReminderData.fromJson(map),
      AssistantAction.createNote => CreateNoteData.fromJson(map),
      AssistantAction.createBatch => BatchCreateData.fromJson(map),
      AssistantAction.updateReminder => UpdateReminderData.fromJson(map),
      AssistantAction.completeReminder => CompleteReminderData.fromJson(map),
      AssistantAction.deleteReminder => DeleteReminderData.fromJson(map),
      AssistantAction.deleteGroup => DeleteGroupData.fromJson(map),
      AssistantAction.queryResponse => QueryResponseData.fromJson(map),
      AssistantAction.clarificationNeeded => ClarificationData.fromJson(map),
      AssistantAction.noAction => NoActionData.fromJson(map),
    };
  }
}

/// Datos para crear un recordatorio.
class CreateReminderData {
  final String title;
  final ReminderType type;
  final ReminderImportance importance;
  final DateTime? scheduledAt;
  final String? object;
  final String? location;
  final String? person;

  const CreateReminderData({
    required this.title,
    required this.type,
    required this.importance,
    this.scheduledAt,
    this.object,
    this.location,
    this.person,
  });

  factory CreateReminderData.fromJson(Map<String, dynamic> json) {
    return CreateReminderData(
      title: json['title'] as String? ?? 'Recordatorio',
      type: _parseType(json['type'] as String?),
      importance: _parseImportance(json['importance'] as String?),
      scheduledAt: _parseDateTime(json['scheduledAt'] as String?),
      object: json['object'] as String?,
      location: json['location'] as String?,
      person: json['person'] as String?,
    );
  }
}

/// Datos para crear una nota (tipo ubicación).
class CreateNoteData {
  final String title;
  final ReminderImportance importance;
  final String? object;
  final String? location;

  const CreateNoteData({
    required this.title,
    required this.importance,
    this.object,
    this.location,
  });

  factory CreateNoteData.fromJson(Map<String, dynamic> json) {
    return CreateNoteData(
      title: json['title'] as String? ?? 'Nota',
      importance: _parseImportance(json['importance'] as String?),
      object: json['object'] as String?,
      location: json['location'] as String?,
    );
  }
}

/// Datos para actualizar un recordatorio.
class UpdateReminderData {
  final String reminderId;
  final Map<String, dynamic> updates;

  const UpdateReminderData({
    required this.reminderId,
    required this.updates,
  });

  factory UpdateReminderData.fromJson(Map<String, dynamic> json) {
    return UpdateReminderData(
      reminderId: json['reminderId'] as String,
      updates: Map<String, dynamic>.from(json['updates'] ?? {}),
    );
  }
}

/// Datos para completar un recordatorio.
class CompleteReminderData {
  final String reminderId;

  const CompleteReminderData({required this.reminderId});

  factory CompleteReminderData.fromJson(Map<String, dynamic> json) {
    return CompleteReminderData(
      reminderId: json['reminderId'] as String,
    );
  }
}

/// Datos para eliminar un recordatorio.
class DeleteReminderData {
  final String reminderId;

  const DeleteReminderData({required this.reminderId});

  factory DeleteReminderData.fromJson(Map<String, dynamic> json) {
    return DeleteReminderData(
      reminderId: json['reminderId'] as String,
    );
  }
}

/// Datos para crear múltiples recordatorios (batch/receta).
class BatchCreateData {
  final String groupId;
  final String groupLabel;
  final List<CreateReminderData> items;

  const BatchCreateData({
    required this.groupId,
    required this.groupLabel,
    required this.items,
  });

  factory BatchCreateData.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?) ?? [];
    return BatchCreateData(
      groupId: json['groupId'] as String? ?? '',
      groupLabel: json['groupLabel'] as String? ?? 'Tratamiento',
      items: itemsList
          .map((e) => CreateReminderData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Datos para eliminar un grupo completo.
class DeleteGroupData {
  final String groupId;

  const DeleteGroupData({required this.groupId});

  factory DeleteGroupData.fromJson(Map<String, dynamic> json) {
    return DeleteGroupData(
      groupId: json['groupId'] as String,
    );
  }
}

/// Datos para respuestas a consultas.
class QueryResponseData {
  final String answer;
  final List<String>? reminderIds;

  const QueryResponseData({
    required this.answer,
    this.reminderIds,
  });

  factory QueryResponseData.fromJson(Map<String, dynamic> json) {
    return QueryResponseData(
      answer: json['answer'] as String? ?? '',
      reminderIds: (json['reminderIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

/// Datos cuando se necesita clarificación.
class ClarificationData {
  final String question;
  final List<String>? options;

  const ClarificationData({
    required this.question,
    this.options,
  });

  factory ClarificationData.fromJson(Map<String, dynamic> json) {
    return ClarificationData(
      question: json['question'] as String? ?? '¿Podrías ser más específico?',
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

/// Datos cuando no se requiere acción.
class NoActionData {
  final String? reason;

  const NoActionData({this.reason});

  factory NoActionData.fromJson(Map<String, dynamic> json) {
    return NoActionData(
      reason: json['reason'] as String?,
    );
  }
}

ReminderType _parseType(String? type) {
  return switch (type?.toUpperCase()) {
    'MEDICATION' => ReminderType.medication,
    'APPOINTMENT' => ReminderType.appointment,
    'CALL' => ReminderType.call,
    'SHOPPING' => ReminderType.shopping,
    'TASK' => ReminderType.task,
    'EVENT' => ReminderType.event,
    'LOCATION' => ReminderType.location,
    _ => ReminderType.task,
  };
}

ReminderImportance _parseImportance(String? importance) {
  return switch (importance?.toUpperCase()) {
    'HIGH' => ReminderImportance.high,
    'MEDIUM' => ReminderImportance.medium,
    'LOW' => ReminderImportance.low,
    'INFO' => ReminderImportance.info,
    _ => ReminderImportance.medium,
  };
}

DateTime? _parseDateTime(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;
  try {
    return DateTime.parse(dateStr);
  } catch (_) {
    return null;
  }
}
