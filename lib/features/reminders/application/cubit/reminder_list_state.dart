import 'package:equatable/equatable.dart';

import '../../domain/entities/reminder.dart';
import '../../domain/entities/reminder_status.dart';
import '../../domain/entities/reminder_type.dart';

enum ReminderListFilter { all, today, pending, completed, notes }

extension ReminderListFilterX on ReminderListFilter {
  String get label {
    return switch (this) {
      ReminderListFilter.all => 'Todos',
      ReminderListFilter.today => 'Hoy',
      ReminderListFilter.pending => 'Pendientes',
      ReminderListFilter.completed => 'Completados',
      ReminderListFilter.notes => 'Notas',
    };
  }
}

sealed class ReminderListState extends Equatable {
  const ReminderListState();

  @override
  List<Object?> get props => const [];
}

final class ReminderListLoading extends ReminderListState {
  const ReminderListLoading();
}

final class ReminderListLoaded extends ReminderListState {
  final List<Reminder> all;
  final ReminderListFilter filter;
  final String? searchQuery;
  final List<Reminder>? searchResults;

  const ReminderListLoaded({
    required this.all,
    required this.filter,
    this.searchQuery,
    this.searchResults,
  });

  bool get isSearching => searchQuery != null && searchQuery!.isNotEmpty;

  List<Reminder> get filtered {
    if (isSearching) return searchResults ?? [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return switch (filter) {
      ReminderListFilter.all => all,
      ReminderListFilter.today =>
        all
            .where(
              (r) =>
                  r.type != ReminderType.location && // Excluir notas
                  r.scheduledAt != null &&
                  !r.scheduledAt!.isBefore(today) &&
                  r.scheduledAt!.isBefore(tomorrow),
            )
            .toList(growable: false),
      ReminderListFilter.pending =>
        all
            .where(
              (r) =>
                  r.type != ReminderType.location && // Excluir notas
                  (r.status == ReminderStatus.pending ||
                   r.status == ReminderStatus.overdue),
            )
            .toList(growable: false),
      ReminderListFilter.completed =>
        all
            .where((r) => r.status == ReminderStatus.completed)
            .toList(growable: false),
      ReminderListFilter.notes =>
        all
            .where((r) => r.type == ReminderType.location)
            .toList(growable: false),
    };
  }

  int get pendingCount =>
      all.where((r) => r.status == ReminderStatus.pending).length;

  int get overdueCount => all
      .where((r) => r.status == ReminderStatus.overdue || r.isOverdue)
      .length;

  int get completedCount =>
      all.where((r) => r.status == ReminderStatus.completed).length;

  ReminderListLoaded copyWith({
    List<Reminder>? all,
    ReminderListFilter? filter,
    String? searchQuery,
    List<Reminder>? searchResults,
    bool clearSearch = false,
  }) {
    return ReminderListLoaded(
      all: all ?? this.all,
      filter: filter ?? this.filter,
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      searchResults: clearSearch ? null : (searchResults ?? this.searchResults),
    );
  }

  @override
  List<Object?> get props => [all, filter, searchQuery, searchResults];
}

final class ReminderListError extends ReminderListState {
  final String message;

  const ReminderListError(this.message);

  @override
  List<Object?> get props => [message];
}
