import 'package:let_me_know/features/reminders/domain/entities/reminder.dart';
import 'package:let_me_know/features/reminders/domain/entities/reminder_status.dart';
import 'package:let_me_know/features/reminders/domain/entities/reminder_type.dart';

/// Modelo de infraestructura para persistencia en SQLite.
///
/// - Convierte entre `Reminder` (dominio) y `Map<String, dynamic>` (SQLite)
/// - Define nombres de tabla/columnas en un solo lugar
class ReminderModel {
  static const tableName = 'reminders';

  static const colId = 'id';
  static const colTitle = 'title';
  static const colDescription = 'description';
  static const colScheduledAt = 'scheduled_at';
  static const colType = 'type';
  static const colStatus = 'status';
  static const colCreatedAt = 'created_at';
  static const colCompletedAt = 'completed_at';

  final String id;
  final String title;
  final String description;
  final DateTime scheduledAt;
  final ReminderType type;
  final ReminderStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledAt,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.completedAt,
  });

  factory ReminderModel.fromEntity(Reminder reminder) {
    return ReminderModel(
      id: reminder.id,
      title: reminder.title,
      description: reminder.description,
      scheduledAt: reminder.scheduledAt,
      type: reminder.type,
      status: reminder.status,
      createdAt: reminder.createdAt,
      completedAt: reminder.completedAt,
    );
  }

  Reminder toEntity() {
    return Reminder(
      id: id,
      title: title,
      description: description,
      scheduledAt: scheduledAt,
      type: type,
      status: status,
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }

  factory ReminderModel.fromMap(Map<String, Object?> map) {
    final typeValue = map[colType] as String?;
    final statusValue = map[colStatus] as String?;

    return ReminderModel(
      id: map[colId] as String,
      title: map[colTitle] as String,
      description: map[colDescription] as String,
      scheduledAt: DateTime.fromMillisecondsSinceEpoch(
        map[colScheduledAt] as int,
      ),
      type: _parseType(typeValue),
      status: _parseStatus(statusValue),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map[colCreatedAt] as int),
      completedAt: (map[colCompletedAt] as int?) != null
          ? DateTime.fromMillisecondsSinceEpoch(map[colCompletedAt] as int)
          : null,
    );
  }

  Map<String, Object?> toMap() {
    return {
      colId: id,
      colTitle: title,
      colDescription: description,
      colScheduledAt: scheduledAt.millisecondsSinceEpoch,
      colType: type.name,
      colStatus: status.name,
      colCreatedAt: createdAt.millisecondsSinceEpoch,
      colCompletedAt: completedAt?.millisecondsSinceEpoch,
    };
  }

  static ReminderType _parseType(String? value) {
    if (value == null) return ReminderType.task;
    try {
      return ReminderType.values.byName(value);
    } catch (_) {
      return ReminderType.task;
    }
  }

  static ReminderStatus _parseStatus(String? value) {
    if (value == null) return ReminderStatus.pending;
    try {
      return ReminderStatus.values.byName(value);
    } catch (_) {
      return ReminderStatus.pending;
    }
  }
}
