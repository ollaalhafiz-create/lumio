import 'localized_text.dart';
import 'row_values.dart';

/// A finished attempt at a quiz.
///
/// [xpAwarded] records what this attempt granted, but the learner's XP total is
/// always derived with `SUM(xp_events.amount)` — this column is only used to
/// show the reward next to the result.
class QuizResult {
  const QuizResult({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.startedAt,
    this.completedAt,
    this.score = 0,
    this.maxScore = 0,
    this.correctCount = 0,
    this.questionCount = 0,
    this.durationSeconds = 0,
    this.passed = false,
    this.accuracy = 0,
    this.xpAwarded = 0,
    this.answers = const <QuizAnswer>[],
    this.quizTitle = LocalizedText.empty,
  });

  factory QuizResult.fromRow(
    Map<String, Object?> row, {
    List<QuizAnswer> answers = const <QuizAnswer>[],
    LocalizedText? quizTitle,
  }) =>
      QuizResult(
        id: intValue(row['id']),
        quizId: intValue(row['quiz_id']),
        userId: intValue(row['user_id']),
        startedAt: dateTimeValue(row['started_at']),
        completedAt: dateTimeOrNull(row['completed_at']),
        score: intValue(row['score']),
        maxScore: intValue(row['max_score']),
        correctCount: intValue(row['correct_count']),
        questionCount: intValue(row['question_count']),
        durationSeconds: intValue(row['duration_seconds']),
        passed: boolValue(row['passed']),
        accuracy: doubleValue(row['accuracy']),
        xpAwarded: intValue(row['xp_awarded']),
        answers: answers,
        quizTitle: quizTitle ?? LocalizedText.empty,
      );

  final int id;
  final int quizId;
  final int userId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int score;
  final int maxScore;
  final int correctCount;
  final int questionCount;
  final int durationSeconds;
  final bool passed;

  /// Accuracy as a fraction between `0` and `1`.
  final double accuracy;

  final int xpAwarded;

  /// Per-question answers, present when the caller asked for the review list.
  final List<QuizAnswer> answers;

  /// Title of the quiz, present when the caller joined it.
  final LocalizedText quizTitle;

  /// `true` when every answered question was correct.
  bool get isPerfect => questionCount > 0 && correctCount == questionCount;

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'quiz_id': quizId,
        'user_id': userId,
        'started_at': dateTimeToMillis(startedAt),
        'completed_at':
            completedAt == null ? null : dateTimeToMillis(completedAt!),
        'score': score,
        'max_score': maxScore,
        'correct_count': correctCount,
        'question_count': questionCount,
        'duration_seconds': durationSeconds,
        'passed': boolToInt(passed),
        'accuracy': accuracy,
        'xp_awarded': xpAwarded,
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  @override
  String toString() => 'QuizResult($id, quiz $quizId)';
}

/// The learner's answer to one question inside a finished attempt.
class QuizAnswer {
  const QuizAnswer({
    this.id = 0,
    required this.resultId,
    required this.questionId,
    required this.selectedKeys,
    required this.isCorrect,
    this.earnedPoints = 0,
    this.timeSpentSeconds = 0,
    this.prompt = LocalizedText.empty,
    this.explanation = LocalizedText.empty,
    this.correctKeys = const <String>[],
  });

  factory QuizAnswer.fromRow(
    Map<String, Object?> row, {
    LocalizedText? prompt,
    LocalizedText? explanation,
    List<String> correctKeys = const <String>[],
  }) =>
      QuizAnswer(
        id: intValue(row['id']),
        resultId: intValue(row['result_id']),
        questionId: intValue(row['question_id']),
        selectedKeys: parseKeyList(row['selected_option_keys']),
        isCorrect: boolValue(row['is_correct']),
        earnedPoints: intValue(row['earned_points']),
        timeSpentSeconds: intValue(row['time_spent_seconds']),
        prompt: prompt ?? LocalizedText.empty,
        explanation: explanation ?? LocalizedText.empty,
        correctKeys: correctKeys,
      );

  final int id;
  final int resultId;
  final int questionId;

  /// Option keys the learner picked.
  final List<String> selectedKeys;

  final bool isCorrect;
  final int earnedPoints;
  final int timeSpentSeconds;

  /// Question text, present when the caller joined the review.
  final LocalizedText prompt;

  /// Explanation, present when the caller joined the review.
  final LocalizedText explanation;

  /// Keys of the correct options, present when the caller joined the review.
  final List<String> correctKeys;

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'result_id': resultId,
        'question_id': questionId,
        'selected_option_keys': joinKeyList(selectedKeys),
        'is_correct': boolToInt(isCorrect),
        'earned_points': earnedPoints,
        'time_spent_seconds': timeSpentSeconds,
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  QuizAnswer copyWith({int? id, int? resultId}) => QuizAnswer(
        id: id ?? this.id,
        resultId: resultId ?? this.resultId,
        questionId: questionId,
        selectedKeys: selectedKeys,
        isCorrect: isCorrect,
        earnedPoints: earnedPoints,
        timeSpentSeconds: timeSpentSeconds,
        prompt: prompt,
        explanation: explanation,
        correctKeys: correctKeys,
      );
}

/// The answer set of one attempt, submitted by the quiz screen.
class QuizSubmission {
  const QuizSubmission({
    required this.quizId,
    required this.startedAt,
    required this.answers,
    this.durationSeconds = 0,
  });

  final int quizId;
  final DateTime startedAt;

  /// Question id to the option keys the learner picked.
  final Map<int, List<String>> answers;

  /// Wall-clock seconds spent on the attempt.
  final int durationSeconds;

  /// Options picked for [questionId].
  List<String> selectedFor(int questionId) =>
      answers[questionId] ?? const <String>[];
}