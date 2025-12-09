import 'package:equatable/equatable.dart';

import 'reminder_status.dart';
import 'reminder_type.dart';

/// Entidad de dominio que representa un recordatorio
/// Inmutable y sin dependencias de framework
class Reminder extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledAt;
  final ReminderType type;
  final ReminderStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledAt,
    required this.type,
    required this.status,
    required this.createdAt,
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
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Verifica si el recordatorio está vencido
  bool get isOverdue =>
      status == ReminderStatus.pending && scheduledAt.isBefore(DateTime.now());

  /// Verifica si el recordatorio es próximo (menos de 2 horas)
  bool get isUpcoming {
    if (status != ReminderStatus.pending) return false;
    final diff = scheduledAt.difference(DateTime.now());
    return diff.inHours < 2 && diff.inMinutes > 0;
  }

  /// Verifica si el recordatorio es para hoy
  bool get isToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        scheduledAt,
        type,
        status,
        createdAt,
        completedAt,
      ];
}

