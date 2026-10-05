import '../db/schema.dart';
import '../models/achievement.dart';
import 'dao.dart';

/// Reads and writes achievement definitions.
class AchievementDao extends Dao {
  AchievementDao(super.executor);

  Future<int> insert(Achievement achievement) =>
      insertRow(Tables.achievements, achievement.toInsertRow());

  Future<int> update(Achievement achievement) => executor.update(
        Tables.achievements,
        achievement.toRow(),
        where: '${Col.id} = ?',
        whereArgs: <Object?>[achievement.id],
      );

  /// All achievements in display order.
  Future<List<Achievement>> all({bool activeOnly = true}) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.achievements,
      where: activeOnly ? '${Col.isActive} = 1' : null,
      orderBy: '${Col.sortOrder} ASC, ${Col.id} ASC',
    );
    return rows.map(Achievement.fromRow).toList(growable: false);
  }

  Future<Achievement?> byId(int id) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.achievements,
      where: '${Col.id} = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Achievement.fromRow(rows.first);
  }

  Future<Achievement?> byCode(String code) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.achievements,
      where: '${Col.code} = ?',
      whereArgs: <Object?>[code],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Achievement.fromRow(rows.first);
  }

  /// Achievements that use [metric]; used when several achievements share one
  /// statistic.
  Future<List<Achievement>> byMetric(String metric) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.achievements,
      where: '${Col.metric} = ? AND ${Col.isActive} = 1',
      whereArgs: <Object?>[metric],
      orderBy: '${Col.threshold} ASC, ${Col.id} ASC',
    );
    return rows.map(Achievement.fromRow).toList(growable: false);
  }
}