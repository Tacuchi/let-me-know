import 'package:drift/drift.dart';
import 'package:let_me_know/core/database/drift/app_database.dart';
import 'package:let_me_know/features/reminders/domain/entities/reminder.dart';
import 'package:let_me_know/features/reminders/domain/entities/reminder_importance.dart';
import 'package:let_me_know/features/reminders/domain/entities/reminder_source.dart';
import 'package:let_me_know/features/reminders/domain/entities/reminder_status.dart';
import 'package:let_me_know/features/reminders/domain/entities/reminder_type.dart';
import 'package:let_me_know/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:let_me_know/di/injection_container.dart';
import 'package:let_me_know/services/notifications/notification_service.dart';

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
  Future<List<Reminder>> getForTomorrow() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
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
  Future<List<Reminder>> getForWeek() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final endExclusive = start.add(const Duration(days: 7));

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

    if (reminder.scheduledAt != null && reminder.hasNotification) {
      final notificationService = getIt<NotificationService>();
      await notificationService.scheduleNotification(reminder);
    }
  }

  @override
  Future<void> delete(String id) async {
    final reminder = await getById(id);
    if (reminder?.notificationId != null) {
      final notificationService = getIt<NotificationService>();
      await notificationService.cancelNotification(reminder!.notificationId!);
    }

    await (_db.delete(_db.reminders)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> markAsCompleted(String id) async {
    final reminder = await getById(id);
    if (reminder?.notificationId != null) {
      final notificationService = getIt<NotificationService>();
      await notificationService.cancelNotification(reminder!.notificationId!);
    }

    await (_db.update(_db.reminders)..where((t) => t.id.equals(id))).write(
      RemindersCompanion(
        status: const Value('completed'),
        completedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  @override
  Future<void> snooze(String id, Duration duration) async {
    final reminder = await getById(id);
    if (reminder == null) return;

    // Cancelar notificación actual si existe
    if (reminder.notificationId != null) {
      final notificationService = getIt<NotificationService>();
      await notificationService.cancelNotification(reminder.notificationId!);
    }

    final newTime = DateTime.now().add(duration);

    await (_db.update(_db.reminders)..where((t) => t.id.equals(id))).write(
      RemindersCompanion(
        scheduledAtMs: Value(newTime.millisecondsSinceEpoch),
        snoozedUntilMs: Value(newTime.millisecondsSinceEpoch),
        status: const Value('pending'),
        updatedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    // Reprogramar notificación con nuevo tiempo
    if (reminder.hasNotification) {
      final notificationService = getIt<NotificationService>();
      await notificationService.scheduleNotification(
        reminder.copyWith(scheduledAt: newTime),
      );
    }
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

  @override
  Future<List<Reminder>> getUpcoming({int limit = 5}) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final rows = await (_db.select(_db.reminders)
          ..where(
            (t) =>
                t.status.equals(ReminderStatus.pending.name) &
                t.scheduledAtMs.isBiggerOrEqualValue(nowMs),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAtMs)])
          ..limit(limit))
        .get();

    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Stream<List<Reminder>> watchUpcoming({int limit = 5}) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    return (_db.select(_db.reminders)
          ..where(
            (t) =>
                t.status.equals(ReminderStatus.pending.name) &
                t.scheduledAtMs.isBiggerOrEqualValue(nowMs),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAtMs)])
          ..limit(limit))
        .watch()
        .map((rows) => rows.map(_toEntity).toList(growable: false));
  }

  @override
  Future<List<Reminder>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final pattern = '%${query.toLowerCase()}%';

    final rows = await (_db.select(_db.reminders)
          ..where(
            (t) =>
                t.title.lower().like(pattern) |
                t.description.lower().like(pattern),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAtMs)]))
        .get();

    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<List<Reminder>> searchNotes(String objectQuery) async {
    if (objectQuery.trim().isEmpty) return [];

    final pattern = '%${objectQuery.toLowerCase()}%';

    // Buscar en notas de ubicación (type = location)
    // Busca en: object, location, title, description
    final rows = await (_db.select(_db.reminders)
          ..where(
            (t) =>
                t.type.equals(ReminderType.location.name) &
                (t.object.lower().like(pattern) |
                    t.location.lower().like(pattern) |
                    t.title.lower().like(pattern) |
                    t.description.lower().like(pattern)),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)]))
        .get();

    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<List<Reminder>> getUpcomingAlerts({
    Duration within = const Duration(hours: 2),
  }) async {
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;
    final endMs = now.add(within).millisecondsSinceEpoch;

    // Recordatorios pendientes que se activarán dentro del rango
    // Excluir notas (type != location)
    final rows = await (_db.select(_db.reminders)
          ..where(
            (t) =>
                t.type.isNotValue(ReminderType.location.name) &
                t.status.equals(ReminderStatus.pending.name) &
                t.scheduledAtMs.isBiggerOrEqualValue(nowMs) &
                t.scheduledAtMs.isSmallerOrEqualValue(endMs),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAtMs)]))
        .get();

    return rows.map(_toEntity).toList(growable: false);
  }
}
