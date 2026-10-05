import '../db/schema.dart';
import '../models/quiz.dart';
import 'dao.dart';

/// Reads and writes quizzes.
class QuizDao extends Dao {
  QuizDao(super.executor);

  Future<int> insert(Quiz quiz) => insertRow(Tables.quizzes, quiz.toInsertRow());

  Future<int> update(Quiz quiz) => executor.update(
        Tables.quizzes,
        quiz.toRow(),
        where: '${Col.id} = ?',
        whereArgs: <Object?>[quiz.id],
      );

  Future<Quiz?> byId(int id) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.quizzes,
      where: '${Col.id} = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Quiz.fromRow(rows.first);
  }

  /// Published quizzes of a subject.
  Future<List<Quiz>> bySubject(int subjectId) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.quizzes,
      where: '${Col.subjectId} = ? AND ${Col.isPublished} = 1',
      whereArgs: <Object?>[subjectId],
      orderBy: '${Col.sortOrder} ASC, ${Col.id} ASC',
    );
    return rows.map(Quiz.fromRow).toList(growable: false);
  }

  Future<List<Quiz>> byChapter(int chapterId) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.quizzes,
      where: '${Col.chapterId} = ? AND ${Col.isPublished} = 1',
      whereArgs: <Object?>[chapterId],
      orderBy: '${Col.sortOrder} ASC, ${Col.id} ASC',
    );
    return rows.map(Quiz.fromRow).toList(growable: false);
  }

  Future<List<Quiz>> byLesson(int lessonId) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.quizzes,
      where: '${Col.lessonId} = ? AND ${Col.isPublished} = 1',
      whereArgs: <Object?>[lessonId],
      orderBy: '${Col.sortOrder} ASC, ${Col.id} ASC',
    );
    return rows.map(Quiz.fromRow).toList(growable: false);
  }

  /// Every published quiz, for the quizzes list screen.
  Future<List<Quiz>> published() async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.quizzes,
      where: '${Col.isPublished} = 1',
      orderBy: '${Col.sortOrder} ASC, ${Col.id} ASC',
    );
    return rows.map(Quiz.fromRow).toList(growable: false);
  }

  Future<int> count() => countRows(Tables.quizzes);
}