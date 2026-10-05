import '../db/schema.dart';
import '../models/lesson.dart';
import 'dao.dart';

/// Reads and writes lessons.
class LessonDao extends Dao {
  LessonDao(super.executor);

  Future<int> insert(Lesson lesson) =>
      insertRow(Tables.lessons, lesson.toInsertRow());

  Future<int> update(Lesson lesson) => executor.update(
        Tables.lessons,
        lesson.toRow(),
        where: '${Col.id} = ?',
        whereArgs: <Object?>[lesson.id],
      );

  Future<List<Lesson>> byChapter(int chapterId) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.lessons,
      where: '${Col.chapterId} = ?',
      whereArgs: <Object?>[chapterId],
      orderBy: '${Col.sortOrder} ASC, ${Col.id} ASC',
    );
    return rows.map(Lesson.fromRow).toList(growable: false);
  }

  /// Published lessons of a subject, resolved through their chapter.
  Future<List<Lesson>> bySubject(int subjectId) async {
    final List<Map<String, Object?>> rows = await executor.rawQuery(
      'SELECT l.* FROM ${Tables.lessons} l '
      'INNER JOIN ${Tables.chapters} c ON c.${Col.id} = l.${Col.chapterId} '
      'WHERE c.${Col.subjectId} = ? AND l.${Col.isPublished} = 1 '
      'ORDER BY c.${Col.sortOrder} ASC, l.${Col.sortOrder} ASC, l.${Col.id} ASC',
      <Object?>[subjectId],
    );
    return rows.map(Lesson.fromRow).toList(growable: false);
  }

  Future<Lesson?> byId(int id) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.lessons,
      where: '${Col.id} = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Lesson.fromRow(rows.first);
  }

  /// Total published lessons of a subject, used for progress percentages.
  Future<int> countForSubject(int subjectId) async {
    final List<Map<String, Object?>> rows = await executor.rawQuery(
      'SELECT COUNT(*) AS c FROM ${Tables.lessons} l '
      'INNER JOIN ${Tables.chapters} c ON c.${Col.id} = l.${Col.chapterId} '
      'WHERE c.${Col.subjectId} = ? AND l.${Col.isPublished} = 1',
      <Object?>[subjectId],
    );
    return rows.first['c'] is num ? (rows.first['c']! as num).toInt() : 0;
  }
}