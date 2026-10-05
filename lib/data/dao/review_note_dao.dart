import '../db/schema.dart';
import '../models/review_note.dart';
import 'dao.dart';

/// Reads and writes the learner's bilingual review notes.
class ReviewNoteDao extends Dao {
  ReviewNoteDao(super.executor);

  Future<int> insert(ReviewNote note) =>
      insertRow(Tables.reviewNotes, note.toInsertRow());

  Future<int> update(ReviewNote note) => executor.update(
        Tables.reviewNotes,
        note.toRow(),
        where: '${Col.id} = ?',
        whereArgs: <Object?>[note.id],
      );

  Future<ReviewNote?> byId(int id) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.reviewNotes,
      where: '${Col.id} = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ReviewNote.fromRow(rows.first);
  }

  /// Notes of one item, pinned notes first.
  Future<List<ReviewNote>> forEntity(
    int userId,
    String entityType,
    int entityId,
  ) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.reviewNotes,
      where: '${Col.userId} = ? AND ${Col.entityType} = ? AND ${Col.entityId} = ?',
      whereArgs: <Object?>[userId, entityType, entityId],
      orderBy: '${Col.isPinned} DESC, ${Col.updatedAt} DESC, ${Col.id} DESC',
    );
    return rows.map(ReviewNote.fromRow).toList(growable: false);
  }

  /// All notes of the learner, newest first.
  Future<List<ReviewNote>> allFor(int userId, {int limit = 100}) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.reviewNotes,
      where: '${Col.userId} = ?',
      whereArgs: <Object?>[userId],
      orderBy: '${Col.isPinned} DESC, ${Col.updatedAt} DESC, ${Col.id} DESC',
      limit: limit,
    );
    return rows.map(ReviewNote.fromRow).toList(growable: false);
  }

  Future<int> deleteById(int id) => executor.delete(
        Tables.reviewNotes,
        where: '${Col.id} = ?',
        whereArgs: <Object?>[id],
      );

  Future<int> deleteFor(int userId, String entityType, int entityId) =>
      executor.delete(
        Tables.reviewNotes,
        where: '${Col.userId} = ? AND ${Col.entityType} = ? AND ${Col.entityId} = ?',
        whereArgs: <Object?>[userId, entityType, entityId],
      );

  Future<int> countFor(int userId) => countRows(
        Tables.reviewNotes,
        where: '${Col.userId} = ?',
        whereArgs: <Object?>[userId],
      );
}