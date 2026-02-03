import '../../../features/reminders/domain/entities/reminder.dart';
import '../../../features/reminders/domain/entities/reminder_importance.dart';
import '../../../features/reminders/domain/entities/reminder_status.dart';
import '../../../features/reminders/domain/entities/reminder_type.dart';

/// Representación de un recordatorio para enviar al LLM como contexto.
class MemoryItem {
  final String id;
  final String title;
  final String type;
  final String status;
  final String importance;
  final String? scheduledAt;
  final String? object;
  final String? location;
  final String? person;

  const MemoryItem({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.importance,
    this.scheduledAt,
    this.object,
    this.location,
    this.person,
  });

  /// Crea un MemoryItem desde un Reminder del dominio.
  factory MemoryItem.fromReminder(Reminder reminder) {
    return MemoryItem(
      id: reminder.id,
      title: reminder.title,
      type: _typeToString(reminder.type),
      status: _statusToString(reminder.status),
      importance: _importanceToString(reminder.importance),
      scheduledAt: reminder.scheduledAt?.toIso8601String(),
      object: reminder.object,
      location: reminder.location,
      person: _extractPerson(reminder),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'status': status,
      'importance': importance,
      if (scheduledAt != null) 'scheduledAt': scheduledAt,
      if (object != null) 'object': object,
      if (location != null) 'location': location,
      if (person != null) 'person': person,
    };
  }

  static String _typeToString(ReminderType type) {
    return switch (type) {
      ReminderType.medication => 'MEDICATION',
      ReminderType.appointment => 'APPOINTMENT',
      ReminderType.call => 'CALL',
      ReminderType.shopping => 'SHOPPING',
      ReminderType.task => 'TASK',
      ReminderType.event => 'EVENT',
      ReminderType.location => 'LOCATION',
    };
  }

  static String _statusToString(ReminderStatus status) {
    return switch (status) {
      ReminderStatus.pending => 'PENDING',
      ReminderStatus.completed => 'COMPLETED',
      ReminderStatus.cancelled => 'CANCELLED',
      ReminderStatus.overdue => 'PENDING',
    };
  }

  static String _importanceToString(ReminderImportance importance) {
    return switch (importance) {
      ReminderImportance.high => 'HIGH',
      ReminderImportance.medium => 'MEDIUM',
      ReminderImportance.low => 'LOW',
      ReminderImportance.info => 'INFO',
    };
  }

  static String? _extractPerson(Reminder reminder) {
    if (reminder.type == ReminderType.call) {
      final match = RegExp(r'llamar a (\w+)', caseSensitive: false)
          .firstMatch(reminder.description);
      return match?.group(1);
    }
    return null;
  }
}
