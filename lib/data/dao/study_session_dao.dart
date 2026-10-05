import '../db/schema.dart';
import '../models/enums.dart';
import '../models/local_day.dart';
import '../models/row_values.dart';
import '../models/study_session.dart';
import 'dao.dart';

/// Reads and writes timed study sessions.
class StudySessionDao extends Dao {
  StudySessionDao(super.executor);

  Future<int> insert(StudySession session) =>
      insertRow(Tables.studySessions, session.toInsertRow());

  /// Closes an open session with its real duration.
  Future<int> finish(int id, DateTime endedAt, int durationSeconds) =>
      executor.update(
        Tables.studySessions,
        <String, Object?>{
          Col.endedAt: endedAt.millisecondsSinceEpoch,
          Col.durationSeconds: durationSeconds,
          Col.completed: 1,
        },
        where: '${Col.id} = ?',
        whereArgs: <Object?>[id],
      );

  /// The session that is still open for [userId], if any.
  Future<StudySession?> openSession(int userId) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.studySessions,
      where: '${Col.userId} = ? AND ${Col.endedAt} IS NULL',
      whereArgs: <Object?>[userId],
      orderBy: '${Col.id} DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return StudySession.fromRow(rows.first);
  }

  Future<List<StudySession>> recentFor(int userId, {int limit = 20}) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.studySessions,
      where: '${Col.userId} = ?',
      whereArgs: <Object?>[userId],
      orderBy: '${Col.startedAt} DESC, ${Col.id} DESC',
      limit: limit,
    );
    return rows.map(StudySession.fromRow).toList(growable: false);
  }

  /// Total study seconds of the learner.
  Future<int> totalSeconds(int userId) async {
    final List<Map<String, Object?>> rows = await executor.rawQuery(
      'SELECT COALESCE(SUM(${Col.durationSeconds}), 0) AS total '
      'FROM ${Tables.studySessions} WHERE ${Col.userId} = ?',
      <Object?>[userId],
    );
    return intValue(rows.first['total']);
  }

  /// Study seconds between two local days, used by the minute challenges.
  Future<int> secondsBetween(int userId, LocalDay from, LocalDay to) async {
    final List<Map<String, Object?>> rows = await executor.rawQuery(
      'SELECT COALESCE(SUM(${Col.durationSeconds}), 0) AS total '
      'FROM ${Tables.studySessions} '
      'WHERE ${Col.userId} = ? AND ${Col.localDate} BETWEEN ? AND ?',
      <Object?>[userId, from.key, to.key],
    );
    return intValue(rows.first['total']);
  }

  Future<List<StudySession>> forEntity(
    int userId,
    ProgressEntity entity,
    int entityId,
  ) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.studySessions,
      where: '${Col.userId} = ? AND ${Col.entityType} = ? AND ${Col.entityId} = ?',
      whereArgs: <Object?>[userId, entity.key, entityId],
      orderBy: '${Col.startedAt} DESC',
    );
    return rows.map(StudySession.fromRow).toList(growable: false);
  }

  Future<int> deleteFor(int userId) => executor.delete(
        Tables.studySessions,
        where: '${Col.userId} = ?',
        whereArgs: <Object?>[userId],
      );
}