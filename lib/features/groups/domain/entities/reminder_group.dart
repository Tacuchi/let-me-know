import 'package:equatable/equatable.dart';

/// Grupo de recordatorios (ej: tratamiento médico).
class ReminderGroup extends Equatable {
  final String id;
  final String label;
  final String type;
  final int itemCount;
  final DateTime createdAt;

  const ReminderGroup({
    required this.id,
    required this.label,
    required this.type,
    required this.itemCount,
    required this.createdAt,
  });

  ReminderGroup copyWith({
    String? id,
    String? label,
    String? type,
    int? itemCount,
    DateTime? createdAt,
  }) {
    return ReminderGroup(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      itemCount: itemCount ?? this.itemCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, label, type, itemCount, createdAt];
}
