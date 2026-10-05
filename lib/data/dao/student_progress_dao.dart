import '../db/schema.dart';
import 'package:sqflite/sqflite.dart';
import '../models/enums.dart';
import '../models/student_progress.dart';
import 'dao.dart';

/// Reads and writes `student_progress`.
///
/// A row exists per `(user, entity type, entity id)` — the unique constraint is
/// what makes every write an upsert.
class StudentProgressDao extends Dao {
  StudentProgressDao(super.executor);

  /// Writes the progress of one item, inserting it when it is new.
  Future<void> upsert({
    required int userId,
    required ProgressEntity entity,
    required int entityId,
    required int progressPercent,
    required int bestScore,
    required int attempts,
    required int timeSpentSeconds,
    DateTime? lastActivityAt,
    DateTime? completedAt,
  }) async {
    final Map<String, Object?> mutable = <String, Object?>{
      Col.progressPercent: progressPercent,
      Col.bestScore: bestScore,
      Col.attempts: attempts,
      Col.timeSpentSeconds: timeSpentSeconds,
      Col.lastActivityAt: lastActivityAt?.millisecondsSinceEpoch,
      Col.completedAt: completedAt?.millisecondsSinceEpoch,
    };
    await executor.insert(
      Tables.studentProgress,
      <String, Object?>{
        Col.userId: userId,
        Col.entityType: entity.key,
        Col.entityId: entityId,
        ...mutable,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    // `ignore` keeps the best score of earlier attempts, so the update has to
    // read the current row and write back the improved values.
    final StudentProgress? current = await forEntity(userId, entity, entityId);
    if (current == null) return;
    await executor.update(
      Tables.studentProgress,
      <String, Object?>{
        Col.progressPercent: _best(current.progressPercent, progressPercent),
        Col.bestScore: _best(current.bestScore, bestScore),
        Col.attempts: current.attempts + attempts,
        Col.timeSpentSeconds: current.timeSpentSeconds + timeSpentSeconds,
        Col.lastActivityAt:
            (lastActivityAt ?? current.lastActivityAt)?.millisecondsSinceEpoch,
        Col.completedAt: (completedAt ?? current.completedAt)?.millisecondsSinceEpoch,
      },
      where: '${Col.id} = ?',
      whereArgs: <Object?>[current.id],
    );
  }

  Future<StudentProgress?> forEntity(
    int userId,
    ProgressEntity entity,
    int entityId,
  ) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.studentProgress,
      where: '${Col.userId} = ? AND ${Col.entityType} = ? AND ${Col.entityId} = ?',
      whereArgs: <Object?>[userId, entity.key, entityId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return StudentProgress.fromRow(rows.first);
  }

  /// Every progress row of one entity type, for progress aggregation.
  Future<List<StudentProgress>> byEntityType(
    int userId,
    ProgressEntity entity,
  ) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.studentProgress,
      where: '${Col.userId} = ? AND ${Col.entityType} = ?',
      whereArgs: <Object?>[userId, entity.key],
      orderBy: '${Col.entityId} ASC',
    );
    return rows.map(StudentProgress.fromRow).toList(growable: false);
  }

  /// Progress of one entity as a percentage of the total content size.
  ///
  /// `completed * 100 / total`, which keeps the value meaningful when new
  /// lessons are seeded into an existing subject.
  int percentOf(int completed, int total) {
    if (total <= 0) return 0;
    return (completed * 100 / total).round().clamp(0, 100);
  }

  Future<int> countFor(
    int userId,
    ProgressEntity entity, {
    bool completedOnly = false,
  }) =>
      countRows(
        Tables.studentProgress,
        where: completedOnly
            ? '${Col.userId} = ? AND ${Col.entityType} = ? '
                'AND ${Col.completedAt} IS NOT NULL'
            : '${Col.userId} = ? AND ${Col.entityType} = ?',
        whereArgs: <Object?>[userId, entity.key],
      );

  Future<int> deleteFor(int userId) => executor.delete(
        Tables.studentProgress,
        where: '${Col.userId} = ?',
        whereArgs: <Object?>[userId],
      );

  static int _best(int current, int candidate) =>
      candidate > current ? candidate : current;
}