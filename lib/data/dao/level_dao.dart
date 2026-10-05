import '../db/schema.dart';
import 'package:sqflite/sqflite.dart';
import '../models/level.dart';
import '../models/localized_text.dart';
import '../models/row_values.dart';
import 'dao.dart';

/// Reads the generated level curve and derives levels from XP.
class LevelDao extends Dao {
  LevelDao(super.executor);

  /// Writes the whole curve, replacing any previous rows.
  ///
  /// Called by the migrations so the table always mirrors [LevelCurve]; the
  /// table exists for display, never for computing the level number.
  Future<void> replaceAll(List<LevelDef> definitions) async {
    await executor.delete(Tables.levels);
    final Batch batch = executor.batch();
    for (final LevelDef definition in definitions) {
      batch.insert(Tables.levels, _toRow(definition));
    }
    await batch.commit(noResult: true);
  }

  Future<List<LevelDef>> all() async {
    final List<Map<String, Object?>> rows =
        await executor.query(Tables.levels, orderBy: '${Col.level} ASC');
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<LevelDef?> byLevel(int level) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.levels,
      where: '${Col.level} = ?',
      whereArgs: <Object?>[level],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  /// XP threshold of the next level above [level], used by the progress bar.
  Future<int?> minXpOfNextLevel(int level) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.levels,
      columns: <String>[Col.minXp],
      where: '${Col.level} > ?',
      whereArgs: <Object?>[level],
      orderBy: '${Col.level} ASC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return intOrNull(rows.first[Col.minXp]);
  }

  static Map<String, Object?> _toRow(LevelDef definition) => <String, Object?>{
        Col.level: definition.level,
        Col.titleAr: definition.title.ar,
        Col.titleEn: definition.title.en,
        Col.minXp: definition.minXp,
        Col.iconKey: definition.iconKey,
      };

  static LevelDef _fromRow(Map<String, Object?> row) => LevelDef(
        level: intValue(row[Col.level]),
        title: LocalizedText.fromColumns(row[Col.titleAr], row[Col.titleEn]),
        minXp: intValue(row[Col.minXp]),
        iconKey: textValue(row[Col.iconKey]),
      );
}