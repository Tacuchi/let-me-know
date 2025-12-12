import 'package:equatable/equatable.dart';

import 'reminder_importance.dart';
import 'reminder_source.dart';
import 'reminder_status.dart';
import 'reminder_type.dart';

/// Entidad de dominio que representa un recordatorio
/// Inmutable y sin dependencias de framework
class Reminder extends Equatable {
  final String id;
  final String title;
  final String description;

  /// Fecha/hora del recordatorio.
  /// - null para notas (p.ej. ubicación) que no requieren notificación.
  final DateTime? scheduledAt;
  final ReminderType type;
  final ReminderStatus status;
  final ReminderImportance importance;
  final ReminderSource source;

  /// Metadatos para notas de ubicación (type == location).
  final String? object;
  final String? location;

  /// Notificaciones
  final bool hasNotification;
  final int? notificationId;
  final DateTime? lastNotifiedAt;
  final DateTime? snoozedUntil;

  /// Recurrencia (mínimo viable)
  final String? recurrenceGroupId;
  final String? recurrenceRule;

  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledAt,
    required this.type,
    required this.status,
    this.importance = ReminderImportance.medium,
    this.source = ReminderSource.manual,
    this.object,
    this.location,
    this.hasNotification = true,
    this.notificationId,
    this.lastNotifiedAt,
    this.snoozedUntil,
    this.recurrenceGroupId,
    this.recurrenceRule,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  /// Crea una copia del recordatorio con los campos actualizados
  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledAt,
    ReminderType? type,
    ReminderStatus? status,
    ReminderImportance? importance,
    ReminderSource? source,
    String? object,
    String? location,
    bool? hasNotification,
    int? notificationId,
    DateTime? lastNotifiedAt,
    DateTime? snoozedUntil,
    String? recurrenceGroupId,
    String? recurrenceRule,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      type: type ?? this.type,
      status: status ?? this.status,
      importance: importance ?? this.importance,
      source: source ?? this.source,
      object: object ?? this.object,
      location: location ?? this.location,
      hasNotification: hasNotification ?? this.hasNotification,
      notificationId: notificationId ?? this.notificationId,
      lastNotifiedAt: lastNotifiedAt ?? this.lastNotifiedAt,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      recurrenceGroupId: recurrenceGroupId ?? this.recurrenceGroupId,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Verifica si el recordatorio está vencido
  bool get isOverdue =>
      status == ReminderStatus.pending &&
      scheduledAt != null &&
      scheduledAt!.isBefore(DateTime.now());

  /// Verifica si el recordatorio es próximo (menos de 2 horas)
  bool get isUpcoming {
    if (status != ReminderStatus.pending) return false;
    if (scheduledAt == null) return false;
    final diff = scheduledAt!.difference(DateTime.now());
    return diff.inHours < 2 && diff.inMinutes > 0;
  }

  /// Verifica si el recordatorio es para hoy
  bool get isToday {
    if (scheduledAt == null) return false;
    final now = DateTime.now();
    return scheduledAt!.year == now.year &&
        scheduledAt!.month == now.month &&
        scheduledAt!.day == now.day;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    scheduledAt,
    type,
    status,
    importance,
    source,
    object,
    location,
    hasNotification,
    notificationId,
    lastNotifiedAt,
    snoozedUntil,
    recurrenceGroupId,
    recurrenceRule,
    createdAt,
    updatedAt,
    completedAt,
  ];
}
