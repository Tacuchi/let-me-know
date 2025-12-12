import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('ReminderRow')
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get scheduledAtMs => integer().nullable()();
  TextColumn get type => text()();
  TextColumn get status => text()();
  TextColumn get importance => text().withDefault(const Constant('medium'))();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get object => text().nullable()();
  TextColumn get location => text().nullable()();
  BoolColumn get hasNotification =>
      boolean().withDefault(const Constant(true))();
  IntColumn get notificationId => integer().nullable()();
  IntColumn get lastNotifiedAtMs => integer().nullable()();
  IntColumn get snoozedUntilMs => integer().nullable()();
  TextColumn get recurrenceGroupId => text().nullable()();
  TextColumn get recurrenceRule => text().nullable()();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer().nullable()();
  IntColumn get completedAtMs => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Reminders])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await _migrateFromSqfliteV1ToDriftV2(migrator);
      }
    },
  );

  Future<void> _migrateFromSqfliteV1ToDriftV2(Migrator migrator) async {
    final hasOld = await customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='reminders'",
    ).getSingleOrNull();

    if (hasOld == null) {
      await migrator.createAll();
      return;
    }

    await customStatement('ALTER TABLE reminders RENAME TO reminders_old');
    await migrator.createTable(reminders);

    await customStatement('''
INSERT INTO reminders (
  id,
  title,
  description,
  scheduled_at_ms,
  type,
  status,
  importance,
  source,
  object,
  location,
  has_notification,
  notification_id,
  last_notified_at_ms,
  snoozed_until_ms,
  recurrence_group_id,
  recurrence_rule,
  created_at_ms,
  updated_at_ms,
  completed_at_ms
)
SELECT
  id,
  title,
  description,
  scheduled_at,
  type,
  status,
  'medium' as importance,
  'manual' as source,
  NULL as object,
  NULL as location,
  1 as has_notification,
  NULL as notification_id,
  NULL as last_notified_at_ms,
  NULL as snoozed_until_ms,
  NULL as recurrence_group_id,
  NULL as recurrence_rule,
  created_at,
  NULL as updated_at_ms,
  completed_at
FROM reminders_old;
''');

    await customStatement('DROP TABLE reminders_old');

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_reminders_scheduled_at ON reminders (scheduled_at_ms);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_reminders_status ON reminders (status);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_reminders_created_at ON reminders (created_at_ms);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_reminders_completed_at ON reminders (completed_at_ms);',
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'let_me_know.db'));
    return NativeDatabase.createInBackground(file);
  });
}
