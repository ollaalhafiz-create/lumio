import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'migrations.dart';

/// Owns the SQLite connection: opening, migrating and closing.
///
/// The class is a thin wrapper so nothing above it ever touches
/// `openDatabase`, and so tests can inject a [DatabaseFactory] and a temporary
/// [path].
class AppDatabase {
  AppDatabase._({required this.db, required this.path});

  /// File name of the app database inside the platform databases directory.
  static const String fileName = 'lumio.db';

  final Database db;

  /// Absolute path of the opened file, or `:memory:` for in-memory databases.
  final String path;

  /// The connection, for the DAOs.
  DatabaseExecutor get executor => db;

  /// `true` while the connection is usable.
  bool get isOpen => db.isOpen;

  /// Opens the database, creating it and running the migrations when needed.
  ///
  /// [factory] and [path] exist so tests (and desktop tooling) can point the
  /// app at a throwaway file with a different SQLite implementation.
  ///
  /// [pinVersion] is a testing hook: it creates a brand new file at an older
  /// schema version so the next open has to go through `onUpgrade`. It must not
  /// be higher than [Migrations.currentVersion].
  static Future<AppDatabase> open({
    DatabaseFactory? factory,
    String? path,
    int? pinVersion,
  }) async {
    final DatabaseFactory databaseFactory = factory ?? databaseFactorySqflitePlugin;
    if (pinVersion != null && pinVersion > Migrations.currentVersion) {
      throw ArgumentError.value(
        pinVersion,
        'pinVersion',
        'Cannot create a file newer than schema v${Migrations.currentVersion}',
      );
    }
    final String resolvedPath =
        path ?? p.join(await databaseFactory.getDatabasesPath(), fileName);

    final Database db = await databaseFactory.openDatabase(
      resolvedPath,
      options: OpenDatabaseOptions(
        version: pinVersion ?? Migrations.currentVersion,
        onConfigure: _onConfigure,
        onCreate: (Database database, int version) =>
            Migrations.createAll(database),
        onUpgrade: (Database database, int from, int to) =>
            Migrations.upgrade(database, from, to),
      ),
    );

    return AppDatabase._(db: db, path: resolvedPath);
  }

  /// Foreign keys are off by default on some SQLite builds; the schema relies
  /// on `ON DELETE CASCADE`, so they are switched on for every connection.
  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// The stored schema version (`PRAGMA user_version`).
  Future<int> get schemaVersion async {
    final List<Map<String, Object?>> rows = await db.rawQuery('PRAGMA user_version');
    final Object? value = rows.first.values.first;
    return value is num ? value.toInt() : 0;
  }

  /// Names of every table in the database, sorted.
  Future<List<String>> tableNames() async {
    final List<Map<String, Object?>> rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' ORDER BY name",
    );
    return <String>[
      for (final Map<String, Object?> row in rows)
        if (row['name'] is String) row['name']! as String,
    ];
  }

  /// `true` when [table] exists in the opened database.
  Future<bool> hasTable(String table) => Migrations.hasTable(db, table);

  /// Runs [body] inside a transaction on this connection.
  Future<T> transaction<T>(Future<T> Function(Transaction txn) body) =>
      db.transaction<T>(body);

  /// Closes the connection. Safe to call twice.
  Future<void> close() async {
    if (db.isOpen) await db.close();
  }

  /// Deletes the database file, ignoring a missing one.
  static Future<void> deleteDatabaseFile({
    DatabaseFactory? factory,
    String? path,
  }) async {
    final DatabaseFactory databaseFactory = factory ?? databaseFactorySqflitePlugin;
    final String resolvedPath =
        path ?? p.join(await databaseFactory.getDatabasesPath(), fileName);
    await databaseFactory.deleteDatabase(resolvedPath);
  }
}