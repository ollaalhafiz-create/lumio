import '../db/schema.dart';
import '../models/challenge.dart';
import '../models/enums.dart';
import 'dao.dart';

/// Reads and writes challenges plus their per-period progress.
class ChallengeDao extends Dao {
  ChallengeDao(super.executor);

  Future<int> insert(Challenge challenge) =>
      insertRow(Tables.challenges, challenge.toInsertRow());

  Future<int> update(Challenge challenge) => executor.update(
        Tables.challenges,
        challenge.toRow(),
        where: '${Col.id} = ?',
        whereArgs: <Object?>[challenge.id],
      );

  Future<List<Challenge>> all({bool activeOnly = true}) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.challenges,
      where: activeOnly ? '${Col.isActive} = 1' : null,
      orderBy: '${Col.sortOrder} ASC, ${Col.id} ASC',
    );
    return rows.map(Challenge.fromRow).toList(growable: false);
  }

  Future<List<Challenge>> byPeriod(RepeatPeriod period) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.challenges,
      where: '${Col.period} = ? AND ${Col.isActive} = 1',
      whereArgs: <Object?>[period.key],
      orderBy: '${Col.sortOrder} ASC, ${Col.id} ASC',
    );
    return rows.map(Challenge.fromRow).toList(growable: false);
  }

  Future<Challenge?> byId(int id) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.challenges,
      where: '${Col.id} = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Challenge.fromRow(rows.first);
  }

  Future<Challenge?> byCode(String code) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.challenges,
      where: '${Col.code} = ?',
      whereArgs: <Object?>[code],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Challenge.fromRow(rows.first);
  }

  /// Progress rows of [userId] for one period key, keyed by challenge id.
  Future<Map<int, ChallengeCompletion>> progressForPeriod(
    int userId,
    String periodKey,
  ) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.challengeCompletions,
      where: '${Col.userId} = ? AND ${Col.periodKey} = ?',
      whereArgs: <Object?>[userId, periodKey],
    );
    return <int, ChallengeCompletion>{
      for (final ChallengeCompletion row
          in rows.map(ChallengeCompletion.fromRow))
        row.challengeId: row,
    };
  }

  Future<ChallengeCompletion?> completionFor(
    int userId,
    int challengeId,
    String periodKey,
  ) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.challengeCompletions,
      where: '${Col.userId} = ? AND ${Col.challengeId} = ? '
          'AND ${Col.periodKey} = ?',
      whereArgs: <Object?>[userId, challengeId, periodKey],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ChallengeCompletion.fromRow(rows.first);
  }

  /// Creates the progress row of one challenge inside one period.
  Future<void> startCompletion(ChallengeCompletion completion) =>
      insertRow(Tables.challengeCompletions, completion.toInsertRow());

  /// Updates progress in place, leaving `claimed_at` untouched.
  Future<int> updateProgress(
    int id,
    int progress,
    int target,
    ChallengeStatus status,
    DateTime? completedAt,
  ) =>
      executor.update(
        Tables.challengeCompletions,
        <String, Object?>{
          Col.progress: progress,
          Col.target: target,
          Col.status: status.key,
          Col.completedAt: completedAt?.millisecondsSinceEpoch,
        },
        where: '${Col.id} = ?',
        whereArgs: <Object?>[id],
      );

  /// Marks a challenge as claimed inside one period.
  ///
  /// Guarded by a `WHERE status != 'claimed'` clause so a second claim cannot
  /// move the row even if two callers race.
  Future<int> markClaimed(int id, DateTime claimedAt) => executor.update(
        Tables.challengeCompletions,
        <String, Object?>{
          Col.status: ChallengeStatus.claimed.key,
          Col.claimedAt: claimedAt.millisecondsSinceEpoch,
        },
        where: '${Col.id} = ? AND ${Col.status} != ?',
        whereArgs: <Object?>[id, ChallengeStatus.claimed.key],
      );

  Future<int> countActive() => countRows(
        Tables.challenges,
        where: '${Col.isActive} = 1',
      );
}