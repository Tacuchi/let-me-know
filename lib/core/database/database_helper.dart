import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/reminders/infrastructure/models/reminder_model.dart';

/// Helper de base de datos SQLite.
///
/// Encapsula:
/// - Apertura de la DB
/// - Migraciones por versión
/// - Creación de tablas/índices
class DatabaseHelper {
  static const _dbName = 'let_me_know.db';
  static const _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;

    final dbPath = await _getDbPath();
    final db = await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    _database = db;
    return db;
  }

  Future<void> close() async {
    final db = _database;
    _database = null;
    await db?.close();
  }

  Future<String> _getDbPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, _dbName);
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
CREATE TABLE ${ReminderModel.tableName} (
  ${ReminderModel.colId} TEXT PRIMARY KEY,
  ${ReminderModel.colTitle} TEXT NOT NULL,
  ${ReminderModel.colDescription} TEXT NOT NULL,
  ${ReminderModel.colScheduledAt} INTEGER NOT NULL,
  ${ReminderModel.colType} TEXT NOT NULL,
  ${ReminderModel.colStatus} TEXT NOT NULL,
  ${ReminderModel.colCreatedAt} INTEGER NOT NULL,
  ${ReminderModel.colCompletedAt} INTEGER
);
''');

    await db.execute('''
CREATE INDEX idx_reminders_scheduled_at
ON ${ReminderModel.tableName} (${ReminderModel.colScheduledAt});
''');

    await db.execute('''
CREATE INDEX idx_reminders_status
ON ${ReminderModel.tableName} (${ReminderModel.colStatus});
''');

    await db.execute('''
CREATE INDEX idx_reminders_created_at
ON ${ReminderModel.tableName} (${ReminderModel.colCreatedAt});
''');
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migraciones futuras.
    // if (oldVersion < 2) { ... }
  }
}
