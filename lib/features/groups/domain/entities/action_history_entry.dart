import 'package:equatable/equatable.dart';

/// Tipo de acción registrada en el historial.
enum HistoryAction { created, completed, deleted }

/// Entrada del historial de acciones.
class ActionHistoryEntry extends Equatable {
  final String id;
  final HistoryAction action;
  final String reminderId;
  final String reminderTitle;
  final String? groupId;
  final String? groupLabel;
  final DateTime actionAt;

  const ActionHistoryEntry({
    required this.id,
    required this.action,
    required this.reminderId,
    required this.reminderTitle,
    this.groupId,
    this.groupLabel,
    required this.actionAt,
  });

  @override
  List<Object?> get props => [
        id,
        action,
        reminderId,
        reminderTitle,
        groupId,
        groupLabel,
        actionAt,
      ];
}
