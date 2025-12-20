import 'package:equatable/equatable.dart';

import '../../../reminders/domain/entities/reminder.dart';
import '../../../reminders/domain/entities/reminder_type.dart';

enum HistoryPeriodFilter { all, thisWeek, thisMonth }

extension HistoryPeriodFilterX on HistoryPeriodFilter {
  String get label => switch (this) {
    HistoryPeriodFilter.all => 'Todo',
    HistoryPeriodFilter.thisWeek => 'Esta semana',
    HistoryPeriodFilter.thisMonth => 'Este mes',
  };
}

sealed class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => const [];
}

final class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

final class HistoryLoaded extends HistoryState {
  final List<Reminder> all;
  final int completedThisMonth;
  final int completedTotal;
  final HistoryPeriodFilter periodFilter;
  final ReminderType? typeFilter;

  const HistoryLoaded({
    required this.all,
    required this.completedThisMonth,
    required this.completedTotal,
    this.periodFilter = HistoryPeriodFilter.all,
    this.typeFilter,
  });

  List<Reminder> get filtered {
    var result = all;

    if (typeFilter != null) {
      result = result.where((r) => r.type == typeFilter).toList();
    }

    final now = DateTime.now();
    switch (periodFilter) {
      case HistoryPeriodFilter.all:
        break;
      case HistoryPeriodFilter.thisWeek:
        final weekAgo = now.subtract(const Duration(days: 7));
        result = result.where((r) {
          final at = r.completedAt;
          return at != null && at.isAfter(weekAgo);
        }).toList();
      case HistoryPeriodFilter.thisMonth:
        final startOfMonth = DateTime(now.year, now.month);
        result = result.where((r) {
          final at = r.completedAt;
          return at != null && at.isAfter(startOfMonth);
        }).toList();
    }

    return result;
  }

  HistoryLoaded copyWith({
    List<Reminder>? all,
    int? completedThisMonth,
    int? completedTotal,
    HistoryPeriodFilter? periodFilter,
    ReminderType? typeFilter,
    bool clearTypeFilter = false,
  }) {
    return HistoryLoaded(
      all: all ?? this.all,
      completedThisMonth: completedThisMonth ?? this.completedThisMonth,
      completedTotal: completedTotal ?? this.completedTotal,
      periodFilter: periodFilter ?? this.periodFilter,
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
    );
  }

  @override
  List<Object?> get props => [all, completedThisMonth, completedTotal, periodFilter, typeFilter];
}

final class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
