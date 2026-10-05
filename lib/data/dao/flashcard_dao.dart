import '../db/schema.dart';
import '../models/flashcard.dart';
import 'dao.dart';

/// Reads and writes flashcards.
class FlashcardDao extends Dao {
  FlashcardDao(super.executor);

  Future<int> insert(Flashcard card) =>
      insertRow(Tables.flashcards, card.toInsertRow());

  Future<int> update(Flashcard card) => executor.update(
        Tables.flashcards,
        card.toRow(),
        where: '${Col.id} = ?',
        whereArgs: <Object?>[card.id],
      );

  Future<Flashcard?> byId(int id) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.flashcards,
      where: '${Col.id} = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Flashcard.fromRow(rows.first);
  }

  Future<List<Flashcard>> byLesson(int lessonId) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.flashcards,
      where: '${Col.lessonId} = ? AND ${Col.isArchived} = 0',
      whereArgs: <Object?>[lessonId],
      orderBy: '${Col.sortOrder} ASC, ${Col.id} ASC',
    );
    return rows.map(Flashcard.fromRow).toList(growable: false);
  }

  Future<List<Flashcard>> byChapter(int chapterId) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.flashcards,
      where: '${Col.chapterId} = ? AND ${Col.isArchived} = 0',
      whereArgs: <Object?>[chapterId],
      orderBy: '${Col.sortOrder} ASC, ${Col.id} ASC',
    );
    return rows.map(Flashcard.fromRow).toList(growable: false);
  }

  /// Every active flashcard of a subject.
  Future<List<Flashcard>> bySubject(int subjectId) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.flashcards,
      where: '${Col.subjectId} = ? AND ${Col.isArchived} = 0',
      whereArgs: <Object?>[subjectId],
      orderBy: '${Col.sortOrder} ASC, ${Col.id} ASC',
    );
    return rows.map(Flashcard.fromRow).toList(growable: false);
  }

  Future<List<Flashcard>> all({int limit = 200}) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.flashcards,
      where: '${Col.isArchived} = 0',
      orderBy: '${Col.subjectId} ASC, ${Col.sortOrder} ASC, ${Col.id} ASC',
      limit: limit,
    );
    return rows.map(Flashcard.fromRow).toList(growable: false);
  }

  Future<int> countForSubject(int subjectId) => countRows(
        Tables.flashcards,
        where: '${Col.subjectId} = ? AND ${Col.isArchived} = 0',
        whereArgs: <Object?>[subjectId],
      );
}