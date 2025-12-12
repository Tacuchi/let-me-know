import 'package:let_me_know/features/reminders/domain/entities/reminder.dart';
import 'package:let_me_know/features/reminders/domain/entities/reminder_status.dart';
import 'package:let_me_know/features/reminders/domain/repositories/reminder_repository.dart';

import '../datasources/local_reminder_datasource.dart';
import '../models/reminder_model.dart';

/// Implementación local de `ReminderRepository` usando SQLite (sqflite).
class ReminderRepositoryImpl implements ReminderRepository {
  final LocalReminderDataSource _local;

  ReminderRepositoryImpl(this._local);

  @override
  Future<List<Reminder>> getAll() async {
    final models = await _local.getAll();
    return models.map((m) => m.toEntity()).toList(growable: false);
  }

  @override
  Future<Reminder?> getById(String id) async {
    final model = await _local.getById(id);
    return model?.toEntity();
  }

  @override
  Future<List<Reminder>> getForToday() async {
    final models = await _local.getForToday();
    return models.map((m) => m.toEntity()).toList(growable: false);
  }

  @override
  Future<List<Reminder>> getByStatus(ReminderStatus status) async {
    final models = await _local.getByStatus(status);
    return models.map((m) => m.toEntity()).toList(growable: false);
  }

  @override
  Future<void> save(Reminder reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    await _local.upsert(model);
  }

  @override
  Future<void> delete(String id) async {
    await _local.delete(id);
  }

  @override
  Future<void> markAsCompleted(String id) async {
    await _local.markAsCompleted(id);
  }

  @override
  Stream<List<Reminder>> watchAll() {
    return _local.watchAll().map(
      (models) => models.map((m) => m.toEntity()).toList(growable: false),
    );
  }

  @override
  Stream<List<Reminder>> watchForToday() {
    return _local.watchForToday().map(
      (models) => models.map((m) => m.toEntity()).toList(growable: false),
    );
  }
}
