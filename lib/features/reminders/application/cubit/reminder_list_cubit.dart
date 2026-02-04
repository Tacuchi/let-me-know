import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import 'reminder_list_state.dart';

class ReminderListCubit extends Cubit<ReminderListState> {
  final ReminderRepository _repository;

  StreamSubscription? _sub;
  ReminderListFilter _filter = ReminderListFilter.all;
  String? _searchQuery;

  ReminderListCubit(this._repository) : super(const ReminderListLoading());

  void start() {
    if (_sub != null) return;

    emit(const ReminderListLoading());
    unawaited(refresh());

    _sub = _repository.watchAll().listen(
      (items) {
        final current = state;
        if (current is ReminderListLoaded && current.isSearching) {
          emit(current.copyWith(all: items));
        } else {
          emit(ReminderListLoaded(all: items, filter: _filter));
        }
      },
      onError: (_) {
        emit(
          const ReminderListError('No se pudieron cargar los recordatorios'),
        );
      },
    );
  }

  void setFilter(ReminderListFilter filter) {
    _filter = filter;
    _searchQuery = null;

    final current = state;
    if (current is ReminderListLoaded) {
      emit(current.copyWith(filter: _filter, clearSearch: true));
    }
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    final current = state;

    if (current is! ReminderListLoaded) return;

    if (query.trim().isEmpty) {
      emit(current.copyWith(clearSearch: true));
      return;
    }

    try {
      final results = await _repository.search(query);
      if (_searchQuery == query) {
        emit(current.copyWith(searchQuery: query, searchResults: results));
      }
    } catch (_) {
      // Ignorar errores de búsqueda, mantener estado actual
    }
  }

  void clearSearch() {
    _searchQuery = null;
    final current = state;
    if (current is ReminderListLoaded) {
      emit(current.copyWith(clearSearch: true));
    }
  }

  Future<void> refresh() async {
    try {
      final items = await _repository.getAll();
      emit(ReminderListLoaded(all: items, filter: _filter));
    } catch (_) {
      emit(const ReminderListError('No se pudieron cargar los recordatorios'));
    }
  }

  Future<void> markAsCompleted(String id) async {
    try {
      await _repository.markAsCompleted(id);
      await refresh();
    } catch (_) {
      emit(const ReminderListError('No se pudo completar el recordatorio'));
    }
  }

  /// Marca un recordatorio como pendiente (deshacer completado)
  Future<void> markAsPending(String id) async {
    try {
      await _repository.markAsPending(id);
      await refresh();
    } catch (_) {
      emit(const ReminderListError('No se pudo restaurar el recordatorio'));
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repository.delete(id);
      await refresh();
    } catch (_) {
      emit(const ReminderListError('No se pudo eliminar el recordatorio'));
    }
  }

  /// Restaura un recordatorio previamente eliminado
  Future<void> restore(Reminder reminder) async {
    try {
      await _repository.save(reminder);
      await refresh();
    } catch (_) {
      emit(const ReminderListError('No se pudo restaurar el recordatorio'));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    _sub = null;
    return super.close();
  }
}
