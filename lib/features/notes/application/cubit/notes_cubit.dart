import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../reminders/domain/entities/reminder_type.dart';
import '../../../reminders/domain/repositories/reminder_repository.dart';
import 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  final ReminderRepository _repository;

  StreamSubscription? _sub;
  NotesFilter _filter = NotesFilter.all;
  String? _searchQuery;

  NotesCubit(this._repository) : super(const NotesLoading());

  void start() {
    if (_sub != null) return;

    emit(const NotesLoading());
    unawaited(refresh());

    _sub = _repository.watchAll().listen(
      (items) {
        final current = state;
        if (current is NotesLoaded && current.isSearching) {
          final notes = items
              .where((r) => r.type == ReminderType.location)
              .toList(growable: false)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          emit(current.copyWith(all: notes));
        } else {
          unawaited(refresh());
        }
      },
      onError: (_) => emit(const NotesError('No se pudieron cargar las notas')),
    );
  }

  void setFilter(NotesFilter filter) {
    _filter = filter;
    _searchQuery = null;

    final current = state;
    if (current is NotesLoaded) {
      emit(current.copyWith(filter: _filter, clearSearch: true));
    }
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    final current = state;

    if (current is! NotesLoaded) return;

    if (query.trim().isEmpty) {
      emit(current.copyWith(clearSearch: true));
      return;
    }

    // Búsqueda local en título, descripción, objeto y ubicación
    final results = current.all.where((r) {
      final q = query.toLowerCase();
      return r.title.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q) ||
          (r.object?.toLowerCase().contains(q) ?? false) ||
          (r.location?.toLowerCase().contains(q) ?? false);
    }).toList(growable: false);

    if (_searchQuery == query) {
      emit(current.copyWith(searchQuery: query, searchResults: results));
    }
  }

  void clearSearch() {
    _searchQuery = null;
    final current = state;
    if (current is NotesLoaded) {
      emit(current.copyWith(clearSearch: true));
    }
  }

  Future<void> refresh() async {
    try {
      final all = await _repository.getAll();

      final notes = all
          .where((r) => r.type == ReminderType.location)
          .toList(growable: false)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(NotesLoaded(all: notes, filter: _filter));
    } catch (_) {
      emit(const NotesError('No se pudieron cargar las notas'));
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repository.delete(id);
      await refresh();
    } catch (_) {
      emit(const NotesError('No se pudo eliminar la nota'));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    _sub = null;
    return super.close();
  }
}
