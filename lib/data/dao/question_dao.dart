import '../db/schema.dart';
import '../models/question.dart';
import 'dao.dart';

/// Reads and writes questions together with their answer options.
class QuestionDao extends Dao {
  QuestionDao(super.executor);

  Future<int> insert(Question question) =>
      insertRow(Tables.questions, question.toInsertRow());

  Future<int> insertOption(QuestionOption option) =>
      insertRow(Tables.questionOptions, option.toInsertRow());

  /// Writes a question and all of its options.
  ///
  /// The options are inserted with the question id already known, so the write
  /// can be a single batch.
  Future<void> insertWithOptions(Question question) async {
    await insert(question);
    for (final QuestionOption option in question.options) {
      await insertOption(option.copyWith(questionId: question.id));
    }
  }

  /// Options of the given questions, grouped by question id and ordered.
  Future<Map<int, List<QuestionOption>>> optionsFor(
    List<int> questionIds,
  ) async {
    if (questionIds.isEmpty) return const <int, List<QuestionOption>>{};
    final String placeholders = List<String>.filled(questionIds.length, '?').join(', ');
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.questionOptions,
      where: '${Col.questionId} IN ($placeholders)',
      whereArgs: questionIds,
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

  Future<List<Question>> byLesson(int lessonId) =>
      _load(<String, Object?>{Col.lessonId: lessonId}, '${Col.sortOrder} ASC');

  Future<List<Question>> byChapter(int chapterId) =>
      _load(<String, Object?>{Col.chapterId: chapterId}, '${Col.sortOrder} ASC');

  Future<List<Question>> bySubject(int subjectId) =>
      _load(<String, Object?>{Col.subjectId: subjectId}, '${Col.sortOrder} ASC');

  Future<Question?> byId(int id) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.questions,
      where: '${Col.id} = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final Question question = Question.fromRow(rows.first);
    final Map<int, List<QuestionOption>> options =
        await optionsFor(<int>[question.id]);
    return question.copyWith(options: options[question.id] ?? const <QuestionOption>[]);
  }

  Future<int> countForLesson(int lessonId) => countRows(
        Tables.questions,
        where: '${Col.lessonId} = ?',
        whereArgs: <Object?>[lessonId],
      );

  Future<int> countForChapter(int chapterId) => countRows(
        Tables.questions,
        where: '${Col.chapterId} = ?',
        whereArgs: <Object?>[chapterId],
      );

  Future<List<Question>> _load(
    Map<String, Object?> filters,
    String orderBy,
  ) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.questions,
      where: filters.keys.map((String key) => '$key = ?').join(' AND '),
      whereArgs: filters.values.toList(growable: false),
      orderBy: orderBy,
    );
    if (rows.isEmpty) return const <Question>[];
    final Map<int, List<QuestionOption>> options = await optionsFor(
      rows.map((Map<String, Object?> row) => row[Col.id] as int).toList(),
    );
    return rows
        .map(
          (Map<String, Object?> row) => Question.fromRow(
            row,
            options: options[row[Col.id] as int] ?? const <QuestionOption>[],
          ),
        )
        .toList(growable: false);
  }
}