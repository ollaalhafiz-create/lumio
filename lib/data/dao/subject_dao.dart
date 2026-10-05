import '../db/schema.dart';
import '../models/subject.dart';
import 'dao.dart';

/// Reads and writes subjects.
class SubjectDao extends Dao {
  SubjectDao(super.executor);

  Future<int> insert(Subject subject) =>
      insertRow(Tables.subjects, subject.toInsertRow());

  Future<int> update(Subject subject) => executor.update(
        Tables.subjects,
        subject.toRow(),
        where: '${Col.id} = ?',
        whereArgs: <Object?>[subject.id],
      );

  /// All subjects in display order, archived ones last.
  Future<List<Subject>> all({bool includeArchived = false}) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.subjects,
      where: includeArchived ? null : '${Col.isArchived} = 0',
      orderBy: '${Col.sortOrder} ASC, ${Col.id} ASC',
    );
    return rows.map(Subject.fromRow).toList(growable: false);
  }

  Future<Subject?> byId(int id) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.subjects,
      where: '${Col.id} = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Subject.fromRow(rows.first);
  }

  Future<int> count() => countRows(Tables.subjects);

  Future<int> setArchived(int id, bool archived) => executor.update(
        Tables.subjects,
        <String, Object?>{Col.isArchived: archived ? 1 : 0},
        where: '${Col.id} = ?',
        whereArgs: <Object?>[id],
      );
}