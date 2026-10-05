import '../db/schema.dart';
import 'package:sqflite/sqflite.dart';
import '../models/enums.dart';
import '../models/row_values.dart';
import '../models/study_goal.dart';
import 'dao.dart';

/// Reads and writes study goals and their per-period completion state.
class StudyGoalDao extends Dao {
  StudyGoalDao(super.executor);

  Future<int> insert(StudyGoal goal) =>
      insertRow(Tables.studyGoals, goal.toInsertRow());

  /// Writes the goal definition, replacing an existing one with the same
  /// `(user, period, target type)`.
  Future<void> upsert(StudyGoal goal) => executor.insert(
        Tables.studyGoals,
        goal.toInsertRow(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  /// Active goals of the learner, or every goal when [activeOnly] is `false`.
  Future<List<StudyGoal>> allFor(int userId, {bool activeOnly = true}) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.studyGoals,
      where: activeOnly
          ? '${Col.userId} = ? AND ${Col.isActive} = 1'
          : '${Col.userId} = ?',
      whereArgs: <Object?>[userId],
      orderBy: '${Col.period} ASC, ${Col.id} ASC',
    );
    return rows.map(StudyGoal.fromRow).toList(growable: false);
  }

  /// Active goals of one period.
  Future<List<StudyGoal>> byPeriod(int userId, RepeatPeriod period) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.studyGoals,
      where: '${Col.userId} = ? AND ${Col.period} = ? AND ${Col.isActive} = 1',
      whereArgs: <Object?>[userId, period.key],
      orderBy: '${Col.id} ASC',
    );
    return rows.map(StudyGoal.fromRow).toList(growable: false);
  }

  Future<StudyGoal?> byId(int id) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.studyGoals,
      where: '${Col.id} = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return StudyGoal.fromRow(rows.first);
  }

  /// Period keys of one goal that were already rewarded, used to keep the goal
  /// bonus idempotent.
  Future<Set<String>> rewardedPeriodKeys(int userId, int goalId) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.rewardClaims,
      columns: <String>[Col.periodKey],
      where: '${Col.userId} = ? AND ${Col.rewardType} = ? AND ${Col.rewardId} = ?',
      whereArgs: <Object?>[userId, RewardType.goal.key, goalId],
    );
    return <String>{
      for (final Map<String, Object?> row in rows) textValue(row[Col.periodKey]),
    };
  }

  Future<int> setActive(int id, bool active) => executor.update(
        Tables.studyGoals,
        <String, Object?>{Col.isActive: active ? 1 : 0},
        where: '${Col.id} = ?',
        whereArgs: <Object?>[id],
      );

  Future<int> deleteFor(int userId) => executor.delete(
        Tables.studyGoals,
        where: '${Col.userId} = ?',
        whereArgs: <Object?>[userId],
      );

}
