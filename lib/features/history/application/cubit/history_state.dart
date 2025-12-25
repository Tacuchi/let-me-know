import 'package:equatable/equatable.dart';

import '../../../reminders/domain/entities/reminder.dart';




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
  final String searchQuery;

  const HistoryLoaded({
    required this.all,
    required this.completedThisMonth,
    required this.completedTotal,
    this.searchQuery = '',
  });

  List<Reminder> get filtered {
    var result = all;

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((r) {
        return r.title.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  
  }

  HistoryLoaded copyWith({
    List<Reminder>? all,
    int? completedThisMonth,
    int? completedTotal,
    String? searchQuery,
  }) {
    return HistoryLoaded(
      all: all ?? this.all,
      completedThisMonth: completedThisMonth ?? this.completedThisMonth,
      completedTotal: completedTotal ?? this.completedTotal,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [all, completedThisMonth, completedTotal, searchQuery];
}

final class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
