import 'enums.dart';
import 'localized_text.dart';
import 'row_values.dart';

/// A repeatable challenge: `تحدي النقاط اليومية`, `تحدي العشرية`, ...
///
/// A challenge is a definition; its progress lives in `challenge_completions`
/// and is keyed by [periodKey], which is `YYYY-MM-DD` for a daily challenge and
/// `YYYY-Www` for a weekly one.
class Challenge {
  const Challenge({
    required this.id,
    required this.code,
    required this.name,
    this.description = LocalizedText.empty,
    this.period = RepeatPeriod.daily,
    required this.metric,
    required this.target,
    this.xpReward = 25,
    this.difficulty = Difficulty.easy,
    this.subjectId,
    this.iconKey = 'challenge_flag',
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory Challenge.fromRow(Map<String, Object?> row) => Challenge(
        id: intValue(row['id']),
        code: textValue(row['code']),
        name: LocalizedText.fromColumns(row['name_ar'], row['name_en']),
        description: LocalizedText.fromColumns(
          row['description_ar'],
          row['description_en'],
        ),
        period: RepeatPeriod.fromValue(row['period']),
        metric: ChallengeMetric.fromValue(row['metric']),
        target: intValue(row['target']),
        xpReward: intValue(row['xp_reward']),
        difficulty: Difficulty.fromValue(row['difficulty']),
        subjectId: intOrNull(row['subject_id']),
        iconKey: textValue(row['icon_key'], orElse: 'challenge_flag'),
        sortOrder: intValue(row['sort_order']),
        isActive: boolValue(row['is_active']),
      );

  final int id;

  /// Stable machine code, for example `daily_xp_50`.
  final String code;

  /// Bilingual challenge name; Arabic is primary.
  final LocalizedText name;

  /// Bilingual description of the task.
  final LocalizedText description;

  /// Whether the challenge repeats daily or weekly.
  final RepeatPeriod period;

  /// The statistic the challenge measures.
  final ChallengeMetric metric;

  /// Value of [metric] required to complete the challenge.
  final int target;

  /// XP granted when the reward is claimed; once per period.
  final int xpReward;

  final Difficulty difficulty;

  /// Optional subject the challenge is limited to.
  final int? subjectId;

  /// Semantic icon key for the UI.
  final String iconKey;

  final int sortOrder;
  final bool isActive;

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'code': code,
        'name_ar': name.ar,
        'name_en': name.en,
        'description_ar': description.ar,
        'description_en': description.en,
        'period': period.key,
        'metric': metric.key,
        'target': target,
        'xp_reward': xpReward,
        'difficulty': difficulty.level,
        'subject_id': subjectId,
        'icon_key': iconKey,
        'sort_order': sortOrder,
        'is_active': boolToInt(isActive),
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  @override
  String toString() => 'Challenge($id, $code)';
}

/// The stored progress of one challenge inside one period.
class ChallengeCompletion {
  const ChallengeCompletion({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.periodKey,
    this.progress = 0,
    this.target = 0,
    this.status = ChallengeStatus.inProgress,
    this.completedAt,
    this.claimedAt,
    this.xpAwarded = 0,
  });

  factory ChallengeCompletion.fromRow(Map<String, Object?> row) =>
      ChallengeCompletion(
        id: intValue(row['id']),
        challengeId: intValue(row['challenge_id']),
        userId: intValue(row['user_id']),
        periodKey: textValue(row['period_key']),
        progress: intValue(row['progress']),
        target: intValue(row['target']),
        status: ChallengeStatus.fromValue(row['status']),
        completedAt: dateTimeOrNull(row['completed_at']),
        claimedAt: dateTimeOrNull(row['claimed_at']),
        xpAwarded: intValue(row['xp_awarded']),
      );

  final int id;
  final int challengeId;
  final int userId;

  /// `YYYY-MM-DD` for daily challenges, `YYYY-Www` for weekly ones.
  final String periodKey;

  final int progress;
  final int target;
  final ChallengeStatus status;
  final DateTime? completedAt;
  final DateTime? claimedAt;
  final int xpAwarded;

  /// `true` once the target has been reached.
  bool get isCompleted =>
      status != ChallengeStatus.inProgress || (target > 0 && progress >= target);

  /// `true` once the reward has been claimed for this period.
  bool get isClaimed =>
      status == ChallengeStatus.claimed || claimedAt != null;

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'challenge_id': challengeId,
        'user_id': userId,
        'period_key': periodKey,
        'progress': progress,
        'target': target,
        'status': status.key,
        'completed_at':
            completedAt == null ? null : dateTimeToMillis(completedAt!),
        'claimed_at': claimedAt == null ? null : dateTimeToMillis(claimedAt!),
        'xp_awarded': xpAwarded,
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  /// The update used when refreshing progress in place.
  Map<String, Object?> toProgressRow({
    required int progress,
    required int target,
    required ChallengeStatus status,
    DateTime? completedAt,
  }) =>
      <String, Object?>{
        'progress': progress,
        'target': target,
        'status': status.key,
        'completed_at':
            completedAt == null ? null : dateTimeToMillis(completedAt),
      };

  @override
  String toString() =>
      'ChallengeCompletion($challengeId, $periodKey, $progress/$target)';
}

/// A challenge definition joined with its progress for one period.
class ChallengeProgress {
  const ChallengeProgress({
    required this.challenge,
    required this.periodKey,
    required this.progress,
    required this.target,
    required this.status,
    this.completedAt,
    this.claimedAt,
    this.xpAwarded = 0,
  });

  /// Live view: the definition plus the progress stored for [periodKey].
  factory ChallengeProgress.initial({
    required Challenge challenge,
    required String periodKey,
  }) =>
      ChallengeProgress(
        challenge: challenge,
        periodKey: periodKey,
        progress: 0,
        target: challenge.target,
        status: ChallengeStatus.inProgress,
      );

  final Challenge challenge;
  final String periodKey;
  final int progress;
  final int target;
  final ChallengeStatus status;
  final DateTime? completedAt;
  final DateTime? claimedAt;
  final int xpAwarded;

  bool get isCompleted =>
      status != ChallengeStatus.inProgress || (target > 0 && progress >= target);

  bool get isClaimed =>
      status == ChallengeStatus.claimed || claimedAt != null;

  /// `true` when the reward can be claimed for this period.
  bool get isClaimable => isCompleted && !isClaimed;

  /// Progress towards the target as a fraction between `0` and `1`.
  double get fraction {
    if (target <= 0) return 1;
    if (progress >= target) return 1;
    return (progress / target).clamp(0.0, 1.0);
  }

  /// Units still missing, `0` once complete.
  int get remaining => target - progress <= 0 ? 0 : target - progress;
}