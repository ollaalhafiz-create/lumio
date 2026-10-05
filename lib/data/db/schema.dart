/// Table and column names.
///
/// Every SQL statement in the data layer refers to identifiers through these
/// constants so a schema change is a single-file edit. Column names follow the
/// bilingual convention `*_ar` / `*_en` for every piece of user-authored or
/// seeded text, and `*_local_date` for the local-time day bucket.
library;

/// Physical table names.
abstract final class Tables {
  /// The single local learner profile.
  static const String users = 'users';

  /// Study subjects (`الرياضيات`, `العلوم`, ...).
  static const String subjects = 'subjects';

  /// Chapters inside a subject.
  static const String chapters = 'chapters';

  /// Lessons inside a chapter.
  static const String lessons = 'lessons';

  /// Questions belonging to a lesson.
  static const String questions = 'questions';

  /// Answer options of a question.
  static const String questionOptions = 'question_options';

  /// Quizzes that group questions.
  static const String quizzes = 'quizzes';

  /// One finished attempt at a quiz.
  static const String quizResults = 'quiz_results';

  /// Per-question answer of a finished attempt.
  static const String quizAnswers = 'quiz_answers';

  /// Flashcards for spaced repetition.
  static const String flashcards = 'flashcards';

  /// Timed study sessions, used for the study-time statistics.
  static const String studySessions = 'study_sessions';

  /// Append-only XP ledger. Totals are always derived with `SUM(amount)`.
  static const String xpEvents = 'xp_events';

  /// Generated level curve, seeded from `LevelCurve`.
  static const String levels = 'levels';

  /// Achievement definitions.
  static const String achievements = 'achievements';

  /// Challenge definitions (daily and weekly).
  static const String challenges = 'challenges';

  /// Progress of one challenge inside one period.
  static const String challengeCompletions = 'challenge_completions';

  /// Idempotency ledger of every claimed reward.
  static const String rewardClaims = 'reward_claims';

  /// Per-user key/value settings.
  static const String settings = 'settings';

  /// Progress of the learner against one content item.
  static const String studentProgress = 'student_progress';

  /// One row per learner per local day; the source of the streak.
  static const String dailyActivity = 'daily_activity';

  /// Daily and weekly study goals.
  static const String studyGoals = 'study_goals';

  /// Free-form bilingual notes the learner writes about an item.
  static const String reviewNotes = 'review_notes';
}

/// Shared column names.
abstract final class Col {
  static const String id = 'id';
  static const String level = 'level';
  static const String userId = 'user_id';
  static const String subjectId = 'subject_id';
  static const String chapterId = 'chapter_id';
  static const String lessonId = 'lesson_id';
  static const String quizId = 'quiz_id';
  static const String resultId = 'result_id';
  static const String questionId = 'question_id';
  static const String achievementId = 'achievement_id';
  static const String challengeId = 'challenge_id';
  static const String goalId = 'goal_id';
  static const String xpEventId = 'xp_event_id';
  static const String nameAr = 'name_ar';
  static const String nameEn = 'name_en';
  static const String displayNameAr = 'display_name_ar';
  static const String displayNameEn = 'display_name_en';
  static const String avatarEmoji = 'avatar_emoji';
  static const String gradeLevelAr = 'grade_level_ar';
  static const String gradeLevelEn = 'grade_level_en';
  static const String titleAr = 'title_ar';
  static const String titleEn = 'title_en';
  static const String bodyAr = 'body_ar';
  static const String bodyEn = 'body_en';
  static const String frontAr = 'front_ar';
  static const String frontEn = 'front_en';
  static const String backAr = 'back_ar';
  static const String backEn = 'back_en';
  static const String hintAr = 'hint_ar';
  static const String hintEn = 'hint_en';
  static const String promptAr = 'prompt_ar';
  static const String promptEn = 'prompt_en';
  static const String explanationAr = 'explanation_ar';
  static const String explanationEn = 'explanation_en';
  static const String textAr = 'text_ar';
  static const String textEn = 'text_en';
  static const String summaryAr = 'summary_ar';
  static const String summaryEn = 'summary_en';
  static const String descriptionAr = 'description_ar';
  static const String descriptionEn = 'description_en';
  static const String code = 'code';
  static const String key = 'key';
  static const String value = 'value';
  static const String valueType = 'value_type';
  static const String metric = 'metric';
  static const String threshold = 'threshold';
  static const String period = 'period';
  static const String target = 'target';
  static const String targetType = 'target_type';
  static const String targetValue = 'target_value';
  static const String periodKey = 'period_key';
  static const String entityType = 'entity_type';
  static const String entityId = 'entity_id';
  static const String status = 'status';
  static const String progress = 'progress';
  static const String points = 'points';
  static const String questionType = 'question_type';
  static const String lessonType = 'lesson_type';
  static const String passingScore = 'passing_score';
  static const String timeLimitSeconds = 'time_limit_seconds';
  static const String maxAttempts = 'max_attempts';
  static const String durationMinutes = 'duration_minutes';
  static const String durationSeconds = 'duration_seconds';
  static const String estimatedMinutes = 'estimated_minutes';
  static const String score = 'score';
  static const String maxScore = 'max_score';
  static const String accuracy = 'accuracy';
  static const String passed = 'passed';
  static const String correctCount = 'correct_count';
  static const String questionCount = 'question_count';
  static const String earnedPoints = 'earned_points';
  static const String selectedOptionKeys = 'selected_option_keys';
  static const String timeSpentSeconds = 'time_spent_seconds';
  static const String progressPercent = 'progress_percent';
  static const String bestScore = 'best_score';
  static const String attempts = 'attempts';
  static const String lastActivityAt = 'last_activity_at';
  static const String questionsAnswered = 'questions_answered';
  static const String questionsCorrect = 'questions_correct';
  static const String quizzesTaken = 'quizzes_taken';
  static const String lessonsOpened = 'lessons_opened';
  static const String flashcardsReviewed = 'flashcards_reviewed';
  static const String studySeconds = 'study_seconds';
  static const String goalsCompleted = 'goals_completed';
  static const String rewardType = 'reward_type';
  static const String rewardId = 'reward_id';
  static const String difficulty = 'difficulty';
  static const String sortOrder = 'sort_order';
  static const String iconKey = 'icon_key';
  static const String colorHex = 'color_hex';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String completedAt = 'completed_at';
  static const String claimedAt = 'claimed_at';
  static const String startedAt = 'started_at';
  static const String endedAt = 'ended_at';
  static const String localDate = 'local_date';
  static const String xpEarned = 'xp_earned';
  static const String xpAwarded = 'xp_awarded';
  static const String xpReward = 'xp_reward';
  static const String amount = 'amount';
  static const String reason = 'reason';
  static const String sourceKey = 'source_key';
  static const String sourceType = 'source_type';
  static const String sourceId = 'source_id';
  static const String minXp = 'min_xp';
  static const String isActive = 'is_active';
  static const String completed = 'completed';
  static const String rewardXp = 'reward_xp';
  static const String isArchived = 'is_archived';
  static const String isPinned = 'is_pinned';
  static const String isPublished = 'is_published';
  static const String isRandomOrder = 'is_random_order';
  static const String isCorrect = 'is_correct';
  static const String optionKey = 'option_key';
}

/// Index and constraint names, referenced by the migration steps.
abstract final class Constraints {
  static const String usersDisplayName = 'ux_users_display_name';

  static const String subjectsSortOrder = 'ux_subjects_sort_order';
  static const String chaptersSubjectSort = 'ux_chapters_subject_sort';
  static const String lessonsChapterSort = 'ux_lessons_chapter_sort';
  static const String questionsLesson = 'ix_questions_lesson';
  static const String questionOptionsQuestion = 'ux_question_options_question';
  static const String quizzesLesson = 'ix_quizzes_lesson';
  static const String quizResultsUser = 'ix_quiz_results_user';
  static const String quizAnswersResult = 'ix_quiz_answers_result';
  static const String flashcardsLesson = 'ix_flashcards_lesson';
  static const String xpEventsSourceKey = 'ux_xp_events_source_key';
  static const String xpEventsUserCreated = 'ix_xp_events_user_created';
  static const String xpEventsUserDate = 'ix_xp_events_user_date';
  static const String levelsMinXp = 'ux_levels_min_xp';
  static const String achievementsCode = 'ux_achievements_code';
  static const String challengesCode = 'ux_challenges_code';
  static const String challengeCompletionsPeriod = 'ux_challenge_completions_period';
  static const String rewardClaimsReward = 'ux_reward_claims_reward';
  static const String rewardClaimsXpEvent = 'ix_reward_claims_xp_event';
  static const String settingsUserKey = 'ux_settings_user_key';
  static const String studentProgressEntity = 'ux_student_progress_entity';
  static const String dailyActivityUserDate = 'ux_daily_activity_user_date';
  static const String studyGoalsUserPeriod = 'ux_study_goals_user_period';
  static const String reviewNotesEntity = 'ix_review_notes_entity';
  static const String studySessionsUserDate = 'ix_study_sessions_user_date';
}

/// Setting keys used by `UserSettings`.
abstract final class SettingKeys {
  static const String language = 'language';
  static const String themeMode = 'theme_mode';
  static const String useArabicNumerals = 'use_arabic_numerals';
  static const String dailyReminderEnabled = 'daily_reminder_enabled';
  static const String reminderHour = 'reminder_hour';
  static const String reminderMinute = 'reminder_minute';
  static const String soundEnabled = 'sound_enabled';
  static const String hapticsEnabled = 'haptics_enabled';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String showAnswerExplanation = 'show_answer_explanation';
  static const String autoPlayAudio = 'auto_play_audio';
}