import 'package:equatable/equatable.dart';

import '../../../reminders/domain/entities/reminder.dart';

enum NotesFilter { all, recent, byObject, byLocation }

extension NotesFilterX on NotesFilter {
  String get label {
    return switch (this) {
      NotesFilter.all => 'Todas',
      NotesFilter.recent => 'Recientes',
      NotesFilter.byObject => 'Por objeto',
      NotesFilter.byLocation => 'Por lugar',
    };
  }
}

sealed class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => const [];
}

final class NotesLoading extends NotesState {
  const NotesLoading();
}

final class NotesLoaded extends NotesState {
  final List<Reminder> all;
  final NotesFilter filter;
  final String? searchQuery;
  final List<Reminder>? searchResults;

  const NotesLoaded({
    required this.all,
    this.filter = NotesFilter.all,
    this.searchQuery,
    this.searchResults,
  });

  bool get isSearching => searchQuery != null && searchQuery!.isNotEmpty;

  List<Reminder> get filtered {
    if (isSearching) return searchResults ?? [];

    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));

    return switch (filter) {
      NotesFilter.all => all,
      NotesFilter.recent => all
          .where((r) => r.createdAt.isAfter(oneWeekAgo))
          .toList(growable: false),
      NotesFilter.byObject => all
          .where((r) => r.object != null && r.object!.isNotEmpty)
          .toList(growable: false),
      NotesFilter.byLocation => all
          .where((r) => r.location != null && r.location!.isNotEmpty)
          .toList(growable: false),
    };
  }

  int get totalCount => all.length;

  NotesLoaded copyWith({
    List<Reminder>? all,
    NotesFilter? filter,
    String? searchQuery,
    List<Reminder>? searchResults,
    bool clearSearch = false,
  }) {
    return NotesLoaded(
      all: all ?? this.all,
      filter: filter ?? this.filter,
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      searchResults: clearSearch ? null : (searchResults ?? this.searchResults),
    );
  }

  @override
  List<Object?> get props => [all, filter, searchQuery, searchResults];
}

final class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object?> get props => [message];
}
