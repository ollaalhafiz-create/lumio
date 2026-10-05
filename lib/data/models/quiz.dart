import 'enums.dart';
import 'question.dart';
import 'localized_text.dart';
import 'row_values.dart';

/// A quiz: a set of questions with a pass mark, a time limit and an XP reward.
class Quiz {
  const Quiz({
    required this.id,
    required this.subjectId,
    this.chapterId,
    this.lessonId,
    required this.title,
    this.description = LocalizedText.empty,
    this.passingScore = 60,
    this.timeLimitSeconds = 0,
    this.difficulty = Difficulty.easy,
    this.isRandomOrder = true,
    this.maxAttempts = 0,
    this.xpReward = 50,
    this.sortOrder = 0,
    this.isPublished = true,
    required this.createdAt,
  });

  factory Quiz.fromRow(Map<String, Object?> row) => Quiz(
        id: intValue(row['id']),
        subjectId: intValue(row['subject_id']),
        chapterId: intOrNull(row['chapter_id']),
        lessonId: intOrNull(row['lesson_id']),
        title: LocalizedText.fromColumns(row['title_ar'], row['title_en']),
        description: LocalizedText.fromColumns(
          row['description_ar'],
          row['description_en'],
        ),
        passingScore: intValue(row['passing_score'], orElse: 60),
        timeLimitSeconds: intValue(row['time_limit_seconds']),
        difficulty: Difficulty.fromValue(row['difficulty']),
        isRandomOrder: boolValue(row['is_random_order']),
        maxAttempts: intValue(row['max_attempts']),
        xpReward: intValue(row['xp_reward'], orElse: 50),
        sortOrder: intValue(row['sort_order']),
        isPublished: boolValue(row['is_published']),
        createdAt: dateTimeValue(row['created_at']),
      );

  final int id;
  final int subjectId;
  final int? chapterId;
  final int? lessonId;

  /// Bilingual quiz title; Arabic is primary.
  final LocalizedText title;

  /// Bilingual short description.
  final LocalizedText description;

  /// Percentage (`0` .. `100`) needed to pass.
  final int passingScore;

  /// Seconds allowed, `0` when the quiz is untimed.
  final int timeLimitSeconds;

  final Difficulty difficulty;
  final bool isRandomOrder;

  /// Maximum attempts, `0` meaning unlimited.
  final int maxAttempts;

  /// XP granted for a passed attempt; see `QuizRepository.submitQuiz` for the
  /// partial-credit rule used for failed attempts.
  final int xpReward;

  final int sortOrder;
  final bool isPublished;
  final DateTime createdAt;

  /// `true` when the quiz is limited in time.
  bool get isTimed => timeLimitSeconds > 0;

  /// `true` when attempts are capped.
  bool get isAttemptLimited => maxAttempts > 0;

  /// Whether an [accuracy] fraction passes the quiz.
  bool passesWith(double accuracy) => accuracy * 100 >= passingScore;

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'subject_id': subjectId,
        'chapter_id': chapterId,
        'lesson_id': lessonId,
        'title_ar': title.ar,
        'title_en': title.en,
        'description_ar': description.ar,
        'description_en': description.en,
        'passing_score': passingScore,
        'time_limit_seconds': timeLimitSeconds,
        'difficulty': difficulty.level,
        'is_random_order': boolToInt(isRandomOrder),
        'max_attempts': maxAttempts,
        'xp_reward': xpReward,
        'sort_order': sortOrder,
        'is_published': boolToInt(isPublished),
        'created_at': dateTimeToMillis(createdAt),
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  Quiz copyWith({
    LocalizedText? title,
    LocalizedText? description,
    int? passingScore,
    int? timeLimitSeconds,
    int? xpReward,
  }) =>
      Quiz(
        id: id,
        subjectId: subjectId,
        chapterId: chapterId,
        lessonId: lessonId,
        title: title ?? this.title,
        description: description ?? this.description,
        passingScore: passingScore ?? this.passingScore,
        timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
        difficulty: difficulty,
        isRandomOrder: isRandomOrder,
        maxAttempts: maxAttempts,
        xpReward: xpReward ?? this.xpReward,
        sortOrder: sortOrder,
        isPublished: isPublished,
        createdAt: createdAt,
      );

  @override
  String toString() => 'Quiz($id, ${title.ar})';
}

/// A quiz together with the questions that were selected for it.
class QuizBundle {
  const QuizBundle({required this.quiz, required this.questions});

  final Quiz quiz;

  /// Questions of this attempt, already shuffled when the quiz asks for it.
  final List<Question> questions;

  /// Sum of the points of every question; the denominator of the score.
  int get maxScore =>
      questions.fold<int>(0, (int sum, Question question) => sum + question.points);

  @override
  String toString() => 'QuizBundle(${quiz.id}, ${questions.length} questions)';
}