import '../db/schema.dart';
import '../models/chapter.dart';
import 'dao.dart';

/// Reads and writes chapters.
class ChapterDao extends Dao {
  ChapterDao(super.executor);

  Future<int> insert(Chapter chapter) =>
      insertRow(Tables.chapters, chapter.toInsertRow());

  Future<int> update(Chapter chapter) => executor.update(
        Tables.chapters,
        chapter.toRow(),
        where: '${Col.id} = ?',
        whereArgs: <Object?>[chapter.id],
      );

  Future<List<Chapter>> bySubject(int subjectId) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.chapters,
      where: '${Col.subjectId} = ?',
      whereArgs: <Object?>[subjectId],
      orderBy: '${Col.sortOrder} ASC, ${Col.id} ASC',
    );
    return rows.map(Chapter.fromRow).toList(growable: false);
  }

  /// Every chapter, in subject order then chapter order.
  Future<List<Chapter>> all() async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.chapters,
      orderBy: '${Col.subjectId} ASC, ${Col.sortOrder} ASC, ${Col.id} ASC',
    );
    return rows.map(Chapter.fromRow).toList(growable: false);
  }

  Future<Chapter?> byId(int id) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.chapters,
      where: '${Col.id} = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Chapter.fromRow(rows.first);
  }

  Future<int> countForSubject(int subjectId) => countRows(
        Tables.chapters,
        where: '${Col.subjectId} = ?',
        whereArgs: <Object?>[subjectId],
      );
}