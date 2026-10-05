/// Closed sets shared by the schema, the DAOs and the repositories.
///
/// Every enum exposes a stable [key] which is the exact string stored in
/// SQLite. The keys are also the identifiers the UI can map onto localized
/// labels, so no user-facing text ever lives in this layer.
library;

/// How hard a lesson, question, quiz, flashcard or challenge is.
enum Difficulty {
  easy('easy', 1),
  medium('medium', 2),
  hard('hard', 3);

  const Difficulty(this.key, this.level);

  /// Stable storage value.
  final String key;

  /// Numeric level, `1` (easiest) to `3` (hardest).
  final int level;

  /// Resolves [value] to a difficulty, defaulting to [Difficulty.easy].
  static Difficulty fromValue(Object? value) {
    if (value is int) {
      return Difficulty.values.firstWhere(
        (Difficulty item) => item.level == value,
        orElse: () => Difficulty.easy,
      );
    }
    final String raw = value is String ? value : '';
    return Difficulty.values.firstWhere(
      (Difficulty item) => item.key == raw,
      orElse: () => Difficulty.easy,
    );
  }
}

/// What a lesson asks the learner to do.
enum LessonType {
  reading('reading'),
  practice('practice'),
  review('review');

  const LessonType(this.key);

  final String key;

  static LessonType fromValue(Object? value) {
    final String raw = value is String ? value : '';
    return LessonType.values.firstWhere(
      (LessonType item) => item.key == raw,
      orElse: () => LessonType.reading,
    );
  }
}

/// How a question is answered.
enum QuestionType {
  single('single'),
  multiple('multiple'),
  trueFalse('true_false');

  const QuestionType(this.key);

  final String key;

  /// `true` when the learner may tick more than one option.
  bool get allowsMultiple => this == QuestionType.multiple;

  static QuestionType fromValue(Object? value) {
    final String raw = value is String ? value : '';
    return QuestionType.values.firstWhere(
      (QuestionType item) => item.key == raw,
      orElse: () => QuestionType.single,
    );
  }
}

/// Progress of the learner against one content item.
enum ProgressStatus {
  notStarted('not_started'),
  inProgress('in_progress'),
  completed('completed');

  const ProgressStatus(this.key);

  final String key;

  static ProgressStatus fromValue(Object? value) {
    final String raw = value is String ? value : '';
    return ProgressStatus.values.firstWhere(
      (ProgressStatus item) => item.key == raw,
      orElse: () => ProgressStatus.notStarted,
    );
  }
}

/// What kind of entity a progress row or a review note is attached to.
enum ProgressEntity {
  subject('subject'),
  chapter('chapter'),
  lesson('lesson'),
  quiz('quiz');

  const ProgressEntity(this.key);

  final String key;

  static ProgressEntity fromValue(Object? value) {
    final String raw = value is String ? value : '';
    return ProgressEntity.values.firstWhere(
      (ProgressEntity item) => item.key == raw,
      orElse: () => ProgressEntity.lesson,
    );
  }
}

/// The measurable statistic behind an achievement.
enum AchievementMetric {
  quizzesTaken('quizzes_taken'),
  perfectQuizzes('perfect_quizzes'),
  accuracyPercent('accuracy_percent'),
  lessonsCompleted('lessons_completed'),
  flashcardsReviewed('flashcards_reviewed'),
  subjectsExplored('subjects_explored'),
  streakDays('streak_days'),
  totalXp('total_xp');

  const AchievementMetric(this.key);

  final String key;

  static AchievementMetric fromValue(Object? value) {
    final String raw = value is String ? value : '';
    return AchievementMetric.values.firstWhere(
      (AchievementMetric item) => item.key == raw,
      orElse: () => AchievementMetric.quizzesTaken,
    );
  }
}

/// The measurable statistic behind a challenge.
enum ChallengeMetric {
  correctAnswers('correct_answers'),
  xpEarned('xp_earned'),
  quizzesTaken('quizzes_taken'),
  flashcardsReviewed('flashcards_reviewed'),
  studyMinutes('study_minutes'),
  accuracyPercent('accuracy_percent'),
  activeDays('active_days');

  const ChallengeMetric(this.key);

  final String key;

  static ChallengeMetric fromValue(Object? value) {
    final String raw = value is String ? value : '';
    return ChallengeMetric.values.firstWhere(
      (ChallengeMetric item) => item.key == raw,
      orElse: () => ChallengeMetric.xpEarned,
    );
  }
}

/// How often a challenge or a goal repeats.
enum RepeatPeriod {
  daily('daily'),
  weekly('weekly');

  const RepeatPeriod(this.key);

  final String key;

  static RepeatPeriod fromValue(Object? value) {
    final String raw = value is String ? value : '';
    return RepeatPeriod.values.firstWhere(
      (RepeatPeriod item) => item.key == raw,
      orElse: () => RepeatPeriod.daily,
    );
  }
}

/// State of one challenge inside one period.
enum ChallengeStatus {
  inProgress('in_progress'),
  completed('completed'),
  claimed('claimed');

  const ChallengeStatus(this.key);

  final String key;

  static ChallengeStatus fromValue(Object? value) {
    final String raw = value is String ? value : '';
    return ChallengeStatus.values.firstWhere(
      (ChallengeStatus item) => item.key == raw,
      orElse: () => ChallengeStatus.inProgress,
    );
  }
}

/// The statistic a study goal measures.
enum GoalTargetType {
  xp('xp'),
  questions('questions'),
  minutes('minutes'),
  quizzes('quizzes'),
  lessons('lessons'),
  accuracyPercent('accuracy_percent');

  const GoalTargetType(this.key);

  final String key;

  static GoalTargetType fromValue(Object? value) {
    final String raw = value is String ? value : '';
    return GoalTargetType.values.firstWhere(
      (GoalTargetType item) => item.key == raw,
      orElse: () => GoalTargetType.xp,
    );
  }
}

/// Which kind of reward a claim belongs to.
///
/// The value is the `reward_type` discriminator in `reward_claims`; together
/// with `reward_id` and `period_key` it forms the unique key that makes
/// claiming idempotent.
enum RewardType {
  achievement('achievement'),
  challenge('challenge'),
  goal('goal');

  const RewardType(this.key);

  final String key;

  static RewardType fromValue(Object? value) {
    final String raw = value is String ? value : '';
    return RewardType.values.firstWhere(
      (RewardType item) => item.key == raw,
      orElse: () => RewardType.achievement,
    );
  }
}

/// Why an XP ledger row exists.
///
/// Stored in `xp_events.reason` so the history screen can group and explain
/// earnings without hard-coding knowledge of the call sites.
enum XpReason {
  quizReward('quiz_reward'),
  quizPerfectBonus('quiz_perfect_bonus'),
  achievementReward('achievement_reward'),
  challengeReward('challenge_reward'),
  goalReward('goal_reward'),
  lessonReward('lesson_reward'),
  adjustment('adjustment');

  const XpReason(this.key);

  final String key;

  static XpReason fromValue(Object? value) {
    final String raw = value is String ? value : '';
    return XpReason.values.firstWhere(
      (XpReason item) => item.key == raw,
      orElse: () => XpReason.quizReward,
    );
  }
}

/// Light / dark preference. The data layer stores the choice only; applying it
/// is the UI layer's job, so a theme change never rewrites content.
enum ThemePreference {
  system('system'),
  light('light'),
  dark('dark');

  const ThemePreference(this.key);

  final String key;

  static ThemePreference fromValue(Object? value) {
    final String raw = value is String ? value : '';
    return ThemePreference.values.firstWhere(
      (ThemePreference item) => item.key == raw,
      orElse: () => ThemePreference.system,
    );
  }
}