import 'package:sqflite/sqflite.dart';

/// Base class of every DAO.
///
/// A DAO works on a [DatabaseExecutor] rather than on `Database` directly, so
/// the same DAO can be used on the connection or inside a transaction: the
/// repositories pass `txn` when several writes have to be atomic (submitting a
/// quiz, claiming a reward).
abstract class Dao {
  Dao(this.executor);

  /// The connection or transaction this DAO reads and writes through.
  final DatabaseExecutor executor;

  /// Inserts [values] into [table] and returns the new row id.
  ///
  /// `0` is returned when [conflictAlgorithm] ignores the write, which is how
  /// the guarded inserts detect "this reward was already claimed".
  Future<int> insertRow(
    String table,
    Map<String, Object?> values, {
    ConflictAlgorithm? conflictAlgorithm,
  }) =>
      executor.insert(table, values, conflictAlgorithm: conflictAlgorithm);

  /// Counts the rows of [table] matching the optional filter.
  Future<int> countRows(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final List<Map<String, Object?>> rows = await executor.rawQuery(
      'SELECT COUNT(*) AS c FROM $table${where == null ? '' : ' WHERE $where'}',
      whereArgs,
    );
    return _asInt(rows.first['c']);
  }

  static int _asInt(Object? value) => value is num ? value.toInt() : 0;
}