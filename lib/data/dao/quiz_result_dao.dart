import '../db/schema.dart';
import '../models/localized_text.dart';
import '../models/local_day.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../models/row_values.dart';
import 'dao.dart';

/// Aggregate statistics of the learner, all derived from existing rows.
class LearnerStats {
  const LearnerStats({
    this.quizzesTaken = 0,
    this.questionsAnswered = 0,
    this.questionsCorrect = 0,
    this.perfectQuizzes = 0,
    this.bestAccuracyPercent = 0,
    this.totalStudySeconds = 0,
    this.quizSeconds = 0,
  });

  final int quizzesTaken;
  final int questionsAnswered;
  final int questionsCorrect;
  final int perfectQuizzes;

  /// Best accuracy of a single attempt, as a percentage.
  final int bestAccuracyPercent;

  final int totalStudySeconds;

  /// Seconds spent inside quizzes.
  final int quizSeconds;

  /// Overall accuracy as a fraction between `0` and `1`.
  double get accuracy =>
      questionsAnswered == 0 ? 0 : questionsCorrect / questionsAnswered;

  /// Overall accuracy as a percentage.
  int get accuracyPercent => (accuracy * 100).round();
}

/// Writes and reads quiz attempts and their answers.
class QuizResultDao extends Dao {
  QuizResultDao(super.executor);

  Future<int> insert(QuizResult result) =>
      insertRow(Tables.quizResults, result.toInsertRow());

  Future<void> insertAnswers(List<QuizAnswer> answers) async {
    for (final QuizAnswer answer in answers) {
      await insertRow(Tables.quizAnswers, answer.toInsertRow());
    }
  }

  Future<QuizResult?> byId(int id, {bool withAnswers = false}) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.quizResults,
      where: '${Col.id} = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    if (!withAnswers) return QuizResult.fromRow(rows.first);
    return QuizResult.fromRow(
      rows.first,
      answers: await answersForResult(id),
    );
  }

  /// Answers of one attempt, joined with the question text and the correct
  /// option keys so the review screen has everything it needs.
  Future<List<QuizAnswer>> answersForResult(int resultId) async {
    final List<Map<String, Object?>> rows = await executor.rawQuery(
      'SELECT a.*, q.${Col.promptAr} AS q_prompt_ar, q.${Col.promptEn} AS q_prompt_en, '
      'q.${Col.explanationAr} AS q_explanation_ar, '
      'q.${Col.explanationEn} AS q_explanation_en '
      'FROM ${Tables.quizAnswers} a '
      'INNER JOIN ${Tables.questions} q ON q.${Col.id} = a.${Col.questionId} '
      'WHERE a.${Col.resultId} = ? ORDER BY a.${Col.id} ASC',
      <Object?>[resultId],
    );
    final List<int> questionIds =
        rows.map((Map<String, Object?> row) => intValue(row[Col.questionId])).toList();
    final Map<int, List<QuestionOption>> options = await _optionsByQuestion(questionIds);
    return rows
        .map(
          (Map<String, Object?> row) => QuizAnswer.fromRow(
            row,
            prompt: LocalizedText.fromColumns(
              row['q_prompt_ar'],
              row['q_prompt_en'],
            ),
            explanation: LocalizedText.fromColumns(
              row['q_explanation_ar'],
              row['q_explanation_en'],
            ),
            correctKeys: <String>[
              for (final QuestionOption option
                  in options[intValue(row[Col.questionId])] ??
                  const <QuestionOption>[])
                if (option.isCorrect) option.optionKey,
            ],
          ),
        )
        .toList(growable: false);
  }

  Future<Map<int, List<QuestionOption>>> _optionsByQuestion(List<int> ids) async {
    if (ids.isEmpty) return const <int, List<QuestionOption>>{};
    final String placeholders = List<String>.filled(ids.length, '?').join(', ');
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.questionOptions,
      where: '${Col.questionId} IN ($placeholders)',
      whereArgs: ids,
      orderBy: '${Col.questionId} ASC, ${Col.sortOrder} ASC, ${Col.id} ASC',
    );
    final Map<int, List<QuestionOption>> grouped =
        <int, List<QuestionOption>>{};
    for (final Map<String, Object?> row in rows) {
      final QuestionOption option = QuestionOption.fromRow(row);
      grouped.putIfAbsent(option.questionId, () => <QuestionOption>[]).add(option);
    }
    return grouped;
  }

  /// Attempts of the learner, newest first, optionally joined with quiz titles.
  Future<List<QuizResult>> recentForUser(
    int userId, {
    int limit = 20,
    int? quizId,
    bool withQuizTitle = true,
  }) async {
    final List<Map<String, Object?>> rows = await executor.rawQuery(
      'SELECT r.*, q.${Col.titleAr} AS q_title_ar, q.${Col.titleEn} AS q_title_en '
      'FROM ${Tables.quizResults} r '
      'INNER JOIN ${Tables.quizzes} q ON q.${Col.id} = r.${Col.quizId} '
      'WHERE r.${Col.userId} = ?${quizId == null ? '' : ' AND r.${Col.quizId} = ?'} '
      'ORDER BY r.${Col.completedAt} DESC, r.${Col.id} DESC LIMIT ?',
      <Object?>[userId, ?quizId, limit],
    );
    return rows
        .map(
          (Map<String, Object?> row) => QuizResult.fromRow(
            row,
            quizTitle: withQuizTitle
                ? LocalizedText.fromColumns(row['q_title_ar'], row['q_title_en'])
                : null,
          ),
        )
        .toList(growable: false);
  }

  /// The learner's best attempt at [quizId], or `null`.
  Future<QuizResult?> bestAttempt(int userId, int quizId) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.quizResults,
      where: '${Col.userId} = ? AND ${Col.quizId} = ?',
      whereArgs: <Object?>[userId, quizId],
      orderBy: '${Col.accuracy} DESC, ${Col.id} DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return QuizResult.fromRow(rows.first);
  }

  /// Number of attempts at [quizId].
  Future<int> attemptsFor(int userId, int quizId) => countRows(
        Tables.quizResults,
        where: '${Col.userId} = ? AND ${Col.quizId} = ?',
        whereArgs: <Object?>[userId, quizId],
      );

  /// Lifetime statistics of the learner.
  Future<LearnerStats> statsFor(int userId) async {
    final List<Map<String, Object?>> rows = await executor.rawQuery(
      'SELECT COUNT(*) AS quizzes_taken, '
      'COALESCE(SUM(question_count), 0) AS questions_answered, '
      'COALESCE(SUM(correct_count), 0) AS questions_correct, '
      'COALESCE(SUM(CASE WHEN question_count > 0 AND correct_count = question_count '
      'THEN 1 ELSE 0 END), 0) AS perfect_quizzes, '
      'COALESCE(MAX(accuracy), 0) AS best_accuracy, '
      'COALESCE(SUM(duration_seconds), 0) AS quiz_seconds '
      'FROM ${Tables.quizResults} WHERE ${Col.userId} = ?',
      <Object?>[userId],
    );
    final Map<String, Object?> row = rows.first;
    final List<Map<String, Object?>> studyRows = await executor.rawQuery(
      'SELECT COALESCE(SUM(duration_seconds), 0) AS total FROM ${Tables.studySessions} '
      'WHERE ${Col.userId} = ?',
      <Object?>[userId],
    );
    return LearnerStats(
      quizzesTaken: intValue(row['quizzes_taken']),
      questionsAnswered: intValue(row['questions_answered']),
      questionsCorrect: intValue(row['questions_correct']),
      perfectQuizzes: intValue(row['perfect_quizzes']),
      bestAccuracyPercent: (doubleValue(row['best_accuracy']) * 100).round(),
      quizSeconds: intValue(row['quiz_seconds']),
      totalStudySeconds: intValue(studyRows.first['total']),
    );
  }

  /// Accuracy of the attempts between [from] and [to] inclusive, as a
  /// percentage; `0` when there was no attempt.
  Future<int> accuracyPercentBetween(
    int userId,
    LocalDay from,
    LocalDay to,
  ) async {
    final List<Map<String, Object?>> rows = await executor.rawQuery(
      'SELECT COALESCE(SUM(correct_count), 0) AS correct, '
      'COALESCE(SUM(question_count), 0) AS total '
      'FROM ${Tables.quizResults} WHERE ${Col.userId} = ? '
      'AND ${Col.completedAt} IS NOT NULL '
      'AND date(${Col.completedAt} / 1000, \'unixepoch\', \'localtime\') BETWEEN ? AND ?',
      <Object?>[userId, from.key, to.key],
    );
    final int total = intValue(rows.first['total']);
    if (total == 0) return 0;
    return (intValue(rows.first['correct']) / total * 100).round();
  }

  /// Number of attempts of one quiz inside a local date range.
  Future<int> attemptsBetween(int userId, LocalDay from, LocalDay to) async {
    final List<Map<String, Object?>> rows = await executor.rawQuery(
      'SELECT COUNT(*) AS c FROM ${Tables.quizResults} WHERE ${Col.userId} = ? '
      'AND ${Col.completedAt} IS NOT NULL '
      'AND date(${Col.completedAt} / 1000, \'unixepoch\', \'localtime\') BETWEEN ? AND ?',
      <Object?>[userId, from.key, to.key],
    );
    return intValue(rows.first['c']);
  }
}