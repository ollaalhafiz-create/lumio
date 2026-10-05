import '../db/schema.dart';
import 'package:sqflite/sqflite.dart';
import '../models/enums.dart';
import '../models/gamification.dart';
import '../models/row_values.dart';
import 'dao.dart';

/// A reward already granted to the learner.
class RewardClaimRow {
  const RewardClaimRow({
    required this.id,
    required this.userId,
    required this.type,
    required this.rewardId,
    required this.periodKey,
    required this.claimedAt,
    required this.xpAwarded,
    this.xpEventId,
  });

  factory RewardClaimRow.fromRow(Map<String, Object?> row) => RewardClaimRow(
        id: intValue(row[Col.id]),
        userId: intValue(row[Col.userId]),
        type: RewardType.fromValue(row[Col.rewardType]),
        rewardId: intValue(row[Col.rewardId]),
        periodKey: textValue(row[Col.periodKey]),
        claimedAt: dateTimeValue(row[Col.claimedAt]),
        xpAwarded: intValue(row[Col.xpAwarded]),
        xpEventId: intOrNull(row[Col.xpEventId]),
      );

  final int id;
  final int userId;
  final RewardType type;
  final int rewardId;

  /// `''` for one-off rewards, the day or week key for repeating ones.
  final String periodKey;

  final DateTime claimedAt;
  final int xpAwarded;
  final int? xpEventId;
}

/// The idempotency ledger of claimed rewards.
///
/// Every reward the app can hand out — achievements, challenges and study-goal
/// bonuses — goes through [tryClaim]. The table has a unique constraint on
/// `(user_id, reward_type, reward_id, period_key)` and the insert uses
/// `INSERT OR IGNORE`, so a second claim of the same reward in the same period
/// cannot create a second row, no matter how many times it is called.
class RewardDao extends Dao {
  RewardDao(super.executor);

  /// Attempts to claim a reward.
  ///
  /// Returns `true` only for the caller that created the row. A duplicate call
  /// inside the same period returns `false` without touching XP.
  Future<bool> tryClaim({
    required int userId,
    required RewardType type,
    required int rewardId,
    required String periodKey,
    required DateTime claimedAt,
    int xpAwarded = 0,
  }) async {
    await insertRow(
      Tables.rewardClaims,
      <String, Object?>{
        Col.userId: userId,
        Col.rewardType: type.key,
        Col.rewardId: rewardId,
        // `''` rather than NULL: SQLite treats NULLs as distinct in a unique
        // index, which would let a one-off reward be claimed twice.
        Col.periodKey: periodKey,
        Col.claimedAt: claimedAt.millisecondsSinceEpoch,
        Col.xpAwarded: xpAwarded,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // Read the row back: the insert above may have been ignored, so only a row
    // that carries our own `claimed_at` proves that this call won the claim.
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.rewardClaims,
      where: '${Col.userId} = ? AND ${Col.rewardType} = ? AND ${Col.rewardId} = ? '
          'AND ${Col.periodKey} = ?',
      whereArgs: <Object?>[userId, type.key, rewardId, periodKey],
      limit: 1,
    );
    if (rows.isEmpty) return false;
    return intValue(rows.first[Col.claimedAt]) == claimedAt.millisecondsSinceEpoch;
  }

  /// Records how much XP the claim granted, and which ledger row it produced.
  Future<void> attachXpEvent({
    required int userId,
    required RewardType type,
    required int rewardId,
    required String periodKey,
    required int xpAwarded,
    required int? xpEventId,
  }) =>
      executor.update(
        Tables.rewardClaims,
        <String, Object?>{
          Col.xpAwarded: xpAwarded,
          Col.xpEventId: xpEventId,
        },
        where: '${Col.userId} = ? AND ${Col.rewardType} = ? AND ${Col.rewardId} = ? '
            'AND ${Col.periodKey} = ?',
        whereArgs: <Object?>[userId, type.key, rewardId, periodKey],
      );

  /// Whether [rewardId] was already claimed by [userId] in [periodKey].
  Future<bool> isClaimed({
    required int userId,
    required RewardType type,
    required int rewardId,
    required String periodKey,
  }) async =>
      await countRows(
        Tables.rewardClaims,
        where: '${Col.userId} = ? AND ${Col.rewardType} = ? AND ${Col.rewardId} = ? '
            'AND ${Col.periodKey} = ?',
        whereArgs: <Object?>[userId, type.key, rewardId, periodKey],
      ) >
      0;

  /// Reward ids of one type the learner has already claimed; `periodKey` of
  /// `''` matches one-off rewards only.
  Future<Set<int>> claimedIds({
    required int userId,
    required RewardType type,
    String periodKey = '',
  }) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.rewardClaims,
      columns: <String>[Col.rewardId],
      distinct: true,
      where: '${Col.userId} = ? AND ${Col.rewardType} = ? AND ${Col.periodKey} = ?',
      whereArgs: <Object?>[userId, type.key, periodKey],
    );
    return <int>{
      for (final Map<String, Object?> row in rows) intValue(row[Col.rewardId]),
    };
  }

  /// The claim of one reward in one period, or `null`.
  Future<RewardClaimRow?> claimFor({
    required int userId,
    required RewardType type,
    required int rewardId,
    required String periodKey,
  }) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.rewardClaims,
      where: '${Col.userId} = ? AND ${Col.rewardType} = ? AND ${Col.rewardId} = ? '
          'AND ${Col.periodKey} = ?',
      whereArgs: <Object?>[userId, type.key, rewardId, periodKey],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return RewardClaimRow.fromRow(rows.first);
  }

  /// Claim history of the learner, newest first.
  Future<List<RewardClaimRow>> historyFor(int userId, {int limit = 50}) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.rewardClaims,
      where: '${Col.userId} = ?',
      whereArgs: <Object?>[userId],
      orderBy: '${Col.claimedAt} DESC, ${Col.id} DESC',
      limit: limit,
    );
    return rows.map(RewardClaimRow.fromRow).toList(growable: false);
  }

  /// Number of claims the learner has, optionally of one type.
  Future<int> countClaims(int userId, {RewardType? type}) => countRows(
        Tables.rewardClaims,
        where: type == null
            ? '${Col.userId} = ?'
            : '${Col.userId} = ? AND ${Col.rewardType} = ?',
        whereArgs: <Object?>[userId, if (type != null) type.key],
      );

  /// Turns a claim row into the value the repository returns.
  RewardClaim toOutcome({
    required RewardType type,
    required int rewardId,
    required String periodKey,
    required bool claimed,
    required int xpAwarded,
    required DateTime at,
  }) =>
      RewardClaim(
        type: type,
        rewardId: rewardId,
        periodKey: periodKey,
        outcome: claimed
            ? RewardClaimOutcome.claimed
            : RewardClaimOutcome.alreadyClaimed,
        xpAwarded: claimed ? xpAwarded : 0,
        claimedAt: claimed ? at : null,
      );
}