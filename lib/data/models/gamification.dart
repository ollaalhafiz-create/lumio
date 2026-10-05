import 'enums.dart';
import 'level.dart';
import 'localized_text.dart';

/// Why a reward claim ended the way it did.
enum RewardClaimOutcome {
  /// The reward was granted by this call.
  claimed,

  /// The reward was already granted before; nothing happened.
  alreadyClaimed,

  /// The requirement (metric reached, challenge complete, goal met) is not met.
  notEligible,

  /// No such achievement, challenge or goal.
  notFound,
}

/// The outcome of a reward claim.
///
/// [wasClaimed] is the boolean the UI needs: it is `true` exactly once per
/// reward and period, because the claim is written under a unique constraint
/// and a second call is rejected before any XP is granted.
class RewardClaim {
  const RewardClaim({
    required this.type,
    required this.rewardId,
    required this.periodKey,
    required this.outcome,
    this.xpAwarded = 0,
    this.claimedAt,
  });

  /// Which kind of reward was claimed.
  final RewardType type;

  /// Id of the achievement, challenge or goal.
  final int rewardId;

  /// `''` for one-off rewards such as achievements, the day or week key for
  /// repeating ones.
  final String periodKey;

  final RewardClaimOutcome outcome;

  /// XP granted by this call; `0` when nothing was granted.
  final int xpAwarded;

  /// When the reward was granted.
  final DateTime? claimedAt;

  /// `true` only when this call is the one that granted the reward.
  bool get wasClaimed => outcome == RewardClaimOutcome.claimed;

  /// `true` when the reward had already been claimed before this call.
  bool get wasAlreadyClaimed => outcome == RewardClaimOutcome.alreadyClaimed;

  @override
  String toString() =>
      'RewardClaim(${type.key}:$rewardId, $periodKey, ${outcome.name})';
}

/// Everything the progress screen and the home header need about the learner,
/// with every gamification number derived in the data layer.
///
/// Nothing here is stored: [totalXp] is `SUM(xp_events.amount)`,
/// [level] comes from [LevelCurve] and the streaks come from the distinct
/// `daily_activity.local_date` values, so the numbers cannot drift away from
/// the underlying rows.
class GamificationSummary {
  const GamificationSummary({
    required this.userId,
    required this.totalXp,
    required this.level,
    required this.levelTitle,
    required this.levelIconKey,
    required this.xpIntoLevel,
    required this.xpToNextLevel,
    required this.currentStreak,
    required this.bestStreak,
    required this.activeDays,
    required this.quizzesTaken,
    required this.questionsAnswered,
    required this.questionsCorrect,
    required this.perfectQuizzes,
    required this.lessonsCompleted,
    required this.flashcardsReviewed,
    required this.studySeconds,
    required this.subjectsExplored,
  });

  /// Builds a summary from the raw aggregates the DAOs returned.
  factory GamificationSummary.fromStats({
    required int userId,
    required int totalXp,
    required int currentStreak,
    required int bestStreak,
    required int activeDays,
    required int quizzesTaken,
    required int questionsAnswered,
    required int questionsCorrect,
    required int perfectQuizzes,
    required int lessonsCompleted,
    required int flashcardsReviewed,
    required int studySeconds,
    required int subjectsExplored,
  }) {
    final LevelDef definition = LevelCurve.definitionForXp(totalXp);
    return GamificationSummary(
      userId: userId,
      totalXp: totalXp,
      level: definition.level,
      levelTitle: definition.title,
      levelIconKey: definition.iconKey,
      xpIntoLevel: LevelCurve.xpIntoLevel(definition.level, totalXp),
      xpToNextLevel: LevelCurve.xpToNextLevel(definition.level),
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      activeDays: activeDays,
      quizzesTaken: quizzesTaken,
      questionsAnswered: questionsAnswered,
      questionsCorrect: questionsCorrect,
      perfectQuizzes: perfectQuizzes,
      lessonsCompleted: lessonsCompleted,
      flashcardsReviewed: flashcardsReviewed,
      studySeconds: studySeconds,
      subjectsExplored: subjectsExplored,
    );
  }

  final int userId;

  /// `SUM(xp_events.amount)` for this learner.
  final int totalXp;

  /// Level derived from [totalXp] with [LevelCurve].
  final int level;

  /// Bilingual title of [level]; Arabic is primary.
  final LocalizedText levelTitle;

  /// Semantic icon key of the current level.
  final String levelIconKey;

  /// XP earned inside the current level.
  final int xpIntoLevel;

  /// XP still needed for the next level; `0` at the maximum level.
  final int xpToNextLevel;

  /// Consecutive active days ending today or yesterday.
  final int currentStreak;

  /// Longest run of consecutive active days ever recorded.
  final int bestStreak;

  /// Number of distinct days with activity.
  final int activeDays;

  final int quizzesTaken;
  final int questionsAnswered;
  final int questionsCorrect;
  final int perfectQuizzes;
  final int lessonsCompleted;
  final int flashcardsReviewed;
  final int studySeconds;

  /// Number of subjects with at least one completed lesson.
  final int subjectsExplored;

  /// Overall accuracy as a fraction between `0` and `1`.
  double get accuracy =>
      questionsAnswered == 0 ? 0 : questionsCorrect / questionsAnswered;

  /// Total study time in whole minutes.
  int get studyMinutes => studySeconds ~/ 60;

  /// XP still missing to reach the next level.
  int get xpToNextLevelRemaining =>
      xpToNextLevel <= 0 ? 0 : xpToNextLevel - xpIntoLevel;

  /// Progress inside the current level as a fraction between `0` and `1`.
  double get levelProgress => LevelCurve.levelProgress(level, totalXp);

  @override
  String toString() =>
      'GamificationSummary($userId, $totalXp XP, level $level)';
}