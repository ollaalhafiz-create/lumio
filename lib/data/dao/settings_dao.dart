import '../db/schema.dart';
import 'package:sqflite/sqflite.dart';
import '../models/row_values.dart';
import 'dao.dart';

/// Reads and writes the per-user key/value settings table.
class SettingsDao extends Dao {
  SettingsDao(super.executor);

  /// Every setting of [userId] as a `key` to `value` map.
  Future<Map<String, Object?>> storageFor(int userId) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.settings,
      columns: <String>[Col.key, Col.value],
      where: '${Col.userId} = ?',
      whereArgs: <Object?>[userId],
    );
    return <String, Object?>{
      for (final Map<String, Object?> row in rows)
        textValue(row[Col.key]): row[Col.value],
    };
  }

  /// One setting value, or `null` when the key was never written.
  Future<Object?> value(int userId, String key) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.settings,
      columns: <String>[Col.value],
      where: '${Col.userId} = ? AND ${Col.key} = ?',
      whereArgs: <Object?>[userId, key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first[Col.value];
  }

  /// Writes one setting, replacing any previous value of [key].
  Future<void> setValue(
    int userId,
    String key,
    Object? value,
    String valueType, {
    required DateTime updatedAt,
  }) =>
      executor.insert(
        Tables.settings,
        <String, Object?>{
          Col.userId: userId,
          Col.key: key,
          Col.value: value,
          Col.valueType: valueType,
          Col.updatedAt: updatedAt.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  /// Writes several settings at once.
  Future<void> setAll(
    int userId,
    Map<String, ({Object? value, String type})> values, {
    required DateTime updatedAt,
  }) async {
    final Batch batch = executor.batch();
    for (final MapEntry<String, ({Object? value, String type})> entry
        in values.entries) {
      batch.insert(
        Tables.settings,
        <String, Object?>{
          Col.userId: userId,
          Col.key: entry.key,
          Col.value: entry.value.value,
          Col.valueType: entry.value.type,
          Col.updatedAt: updatedAt.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}