import '../db/schema.dart';
import 'package:sqflite/sqflite.dart';
import '../models/local_day.dart';
import '../models/row_values.dart';
import '../models/xp_event.dart';
import 'dao.dart';

/// The append-only XP ledger.
///
/// This DAO deliberately has no `update` and no `delete`: a correction is a new
/// negative row, and totals are always `SUM(amount)`.
class XpEventDao extends Dao {
  XpEventDao(super.executor);

  /// Appends [event] to the ledger and returns its row id.
  ///
  /// When [event.sourceKey] was already used, the insert is ignored and `0` is
  /// returned, which is how a reward that pays XP can only ever be granted
  /// once.
  Future<int> append(
    XpEvent event, {
    required ConflictAlgorithm conflictAlgorithm,
  }) =>
      insertRow(
        Tables.xpEvents,
        event.toInsertRow(),
        conflictAlgorithm: conflictAlgorithm,
      );

  /// Total XP of [userId]: `SUM(amount)` over the whole ledger.
  Future<int> totalXp(int userId) async {
    final List<Map<String, Object?>> rows = await executor.rawQuery(
      'SELECT COALESCE(SUM(${Col.amount}), 0) AS total FROM ${Tables.xpEvents} '
      'WHERE ${Col.userId} = ?',
      <Object?>[userId],
    );
    return intValue(rows.first['total']);
  }

  /// Newest ledger rows first.
  Future<List<XpEvent>> recentForUser(int userId, {int limit = 50}) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.xpEvents,
      where: '${Col.userId} = ?',
      whereArgs: <Object?>[userId],
      orderBy: '${Col.id} DESC',
      limit: limit,
    );
    return rows.map(XpEvent.fromRow).toList(growable: false);
  }

  /// Sum of positive earnings between [from] and [to] inclusive.
  ///
  /// Corrections are excluded: a challenge measured on `xp_earned` counts what
  /// was earned in the period, never what was revoked.
  Future<int> earnedBetween(int userId, LocalDay from, LocalDay to) async {
    final List<Map<String, Object?>> rows = await executor.rawQuery(
      'SELECT COALESCE(SUM(${Col.amount}), 0) AS total FROM ${Tables.xpEvents} '
      'WHERE ${Col.userId} = ? AND ${Col.localDate} BETWEEN ? AND ? '
      'AND ${Col.amount} > 0',
      <Object?>[userId, from.key, to.key],
    );
    return intValue(rows.first['total']);
  }

  /// Sum of positive earnings recorded on one exact day.
  Future<int> earnedOn(int userId, LocalDay day) =>
      earnedBetween(userId, day, day);

  /// Ledger rows that reference a source row, oldest first.
  Future<List<XpEvent>> forSource(String sourceType, int sourceId) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.xpEvents,
      where: '${Col.sourceType} = ? AND ${Col.sourceId} = ?',
      whereArgs: <Object?>[sourceType, sourceId],
      orderBy: '${Col.id} ASC',
    );
    return rows.map(XpEvent.fromRow).toList(growable: false);
  }

  /// Whether [sourceKey] has already been used by the ledger.
  Future<bool> hasSourceKey(String sourceKey) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.xpEvents,
      columns: <String>[Col.id],
      where: '${Col.sourceKey} = ?',
      whereArgs: <Object?>[sourceKey],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<int> countForUser(int userId) =>
      countRows(Tables.xpEvents, where: '${Col.userId} = ?', whereArgs: <Object?>[userId]);
}