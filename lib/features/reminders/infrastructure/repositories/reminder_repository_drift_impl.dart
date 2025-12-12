import 'package:drift/drift.dart';
import 'package:let_me_know/core/database/drift/app_database.dart';
import 'package:let_me_know/features/reminders/domain/entities/reminder.dart';
import 'package:let_me_know/features/reminders/domain/entities/reminder_importance.dart';
import 'package:let_me_know/features/reminders/domain/entities/reminder_source.dart';
import 'package:let_me_know/features/reminders/domain/entities/reminder_status.dart';
import 'package:let_me_know/features/reminders/domain/entities/reminder_type.dart';
import 'package:let_me_know/features/reminders/domain/repositories/reminder_repository.dart';

class ReminderRepositoryDriftImpl implements ReminderRepository {
  final AppDatabase _db;

  ReminderRepositoryDriftImpl(this._db);

  Reminder _toEntity(ReminderRow row) {
    return Reminder(
      id: row.id,
      title: row.title,
      description: row.description,
      scheduledAt: row.scheduledAtMs != null
          ? DateTime.fromMillisecondsSinceEpoch(row.scheduledAtMs!)
          : null,
      type: ReminderType.values.byName(row.type),
      status: ReminderStatus.values.byName(row.status),
      importance: ReminderImportance.values.byName(row.importance),
      source: ReminderSource.values.byName(row.source),
      object: row.object,
      location: row.location,
      hasNotification: row.hasNotification,
      notificationId: row.notificationId,
      lastNotifiedAt: row.lastNotifiedAtMs != null
          ? DateTime.fromMillisecondsSinceEpoch(row.lastNotifiedAtMs!)
          : null,
      snoozedUntil: row.snoozedUntilMs != null
          ? DateTime.fromMillisecondsSinceEpoch(row.snoozedUntilMs!)
          : null,
      recurrenceGroupId: row.recurrenceGroupId,
      recurrenceRule: row.recurrenceRule,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAtMs),
      updatedAt: row.updatedAtMs != null
          ? DateTime.fromMillisecondsSinceEpoch(row.updatedAtMs!)
          : null,
      completedAt: row.completedAtMs != null
          ? DateTime.fromMillisecondsSinceEpoch(row.completedAtMs!)
          : null,
    );
  }

  RemindersCompanion _toCompanion(Reminder reminder) {
    return RemindersCompanion(
      id: Value(reminder.id),
      title: Value(reminder.title),
      description: Value(reminder.description),
      scheduledAtMs: Value(reminder.scheduledAt?.millisecondsSinceEpoch),
      type: Value(reminder.type.name),
      status: Value(reminder.status.name),
      importance: Value(reminder.importance.name),
      source: Value(reminder.source.name),
      object: Value(reminder.object),
      location: Value(reminder.location),
      hasNotification: Value(reminder.hasNotification),
      notificationId: Value(reminder.notificationId),
      lastNotifiedAtMs: Value(reminder.lastNotifiedAt?.millisecondsSinceEpoch),
      snoozedUntilMs: Value(reminder.snoozedUntil?.millisecondsSinceEpoch),
      recurrenceGroupId: Value(reminder.recurrenceGroupId),
      recurrenceRule: Value(reminder.recurrenceRule),
      createdAtMs: Value(reminder.createdAt.millisecondsSinceEpoch),
      updatedAtMs: Value(reminder.updatedAt?.millisecondsSinceEpoch),
      completedAtMs: Value(reminder.completedAt?.millisecondsSinceEpoch),
    );
  }

  @override
  Future<List<Reminder>> getAll() async {
    final rows = await (_db.select(
      _db.reminders,
    )..orderBy([(t) => OrderingTerm.asc(t.scheduledAtMs)])).get();
    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<Reminder?> getById(String id) async {
    final row =
        await (_db.select(_db.reminders)
              ..where((t) => t.id.equals(id))
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<List<Reminder>> getForToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final endExclusive = start.add(const Duration(days: 1));

    final startMs = start.millisecondsSinceEpoch;
    final endMs = endExclusive.millisecondsSinceEpoch;

    final rows =
        await (_db.select(_db.reminders)
              ..where(
                (t) =>
                    t.scheduledAtMs.isBiggerOrEqualValue(startMs) &
                    t.scheduledAtMs.isSmallerThanValue(endMs),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.scheduledAtMs)]))
            .get();

    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<List<Reminder>> getByStatus(ReminderStatus status) async {
    final rows =
        await (_db.select(_db.reminders)
              ..where((t) => t.status.equals(status.name))
              ..orderBy([(t) => OrderingTerm.asc(t.scheduledAtMs)]))
            .get();

    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<void> save(Reminder reminder) async {
    await _db
        .into(_db.reminders)
        .insertOnConflictUpdate(_toCompanion(reminder));
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.reminders)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> markAsCompleted(String id) async {
    await (_db.update(_db.reminders)..where((t) => t.id.equals(id))).write(
      RemindersCompanion(
        status: const Value('completed'),
        completedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  @override
  Stream<List<Reminder>> watchAll() {
    return (_db.select(_db.reminders)
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAtMs)]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList(growable: false));
  }

  @override
  Stream<List<Reminder>> watchForToday() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final endExclusive = start.add(const Duration(days: 1));

    final startMs = start.millisecondsSinceEpoch;
    final endMs = endExclusive.millisecondsSinceEpoch;

    return (_db.select(_db.reminders)
          ..where(
            (t) =>
                t.scheduledAtMs.isBiggerOrEqualValue(startMs) &
                t.scheduledAtMs.isSmallerThanValue(endMs),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAtMs)]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList(growable: false));
  }
}
