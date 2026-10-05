import '../db/schema.dart';
import '../models/daily_activity.dart';
import '../models/local_day.dart';
import '../models/row_values.dart';
import 'dao.dart';

/// Reads and writes `daily_activity`, the table every streak is derived from.
class DailyActivityDao extends Dao {
  DailyActivityDao(super.executor);

  /// Adds [delta] to the counters of [day].
  ///
  /// The upsert increments column by column (`col = col + ?`) so several events
  /// on the same day add up, and it works whether the row exists or not.
  Future<void> record(int userId, LocalDay day, ActivityDelta delta) async {
    if (delta.isEmpty) return;
    final Map<String, Object?> values = delta.toRow();
    final String assignments = values.keys
        .map((String column) => '$column = $table.$column + ?')
        .join(', ');
    await executor.rawInsert(
      'INSERT INTO $table (${Col.userId}, ${Col.localDate}, ${values.keys.join(', ')}, '
      '${Col.updatedAt}) '
      'VALUES (?, ?, ${List<String>.filled(values.length, '?').join(', ')}, ?) '
      'ON CONFLICT(${Col.userId}, ${Col.localDate}) DO UPDATE SET '
      '$assignments, ${Col.updatedAt} = excluded.${Col.updatedAt}',
      <Object?>[
        userId,
        day.key,
        ...values.values,
        DateTime.now().millisecondsSinceEpoch,
      ],
    );
  }

  Future<DailyActivity?> forDay(int userId, LocalDay day) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.dailyActivity,
      where: '${Col.userId} = ? AND ${Col.localDate} = ?',
      whereArgs: <Object?>[userId, day.key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DailyActivity.fromRow(rows.first);
  }

  /// Activity rows between [from] and [to] inclusive, oldest first.
  Future<List<DailyActivity>> between(
    int userId,
    LocalDay from,
    LocalDay to,
  ) async {
    final List<Map<String, Object?>> rows = await executor.query(
      Tables.dailyActivity,
      where: '${Col.userId} = ? AND ${Col.localDate} BETWEEN ? AND ?',
      whereArgs: <Object?>[userId, from.key, to.key],
      orderBy: '${Col.localDate} ASC',
    );
    return rows.map(DailyActivity.fromRow).toList(growable: false);
  }

  /// Distinct local days that contain real activity, newest first.
  ///
  /// The activity filter keeps days that were created but never touched from
  /// inflating the streak.
  Future<List<LocalDay>> activeDays(int userId, {int limit = 1000}) async {
    final List<Map<String, Object?>> rows = await executor.rawQuery(
      'SELECT ${Col.localDate} AS d FROM $table '
      'WHERE ${Col.userId} = ? AND ($hasActivityPredicate) '
      'GROUP BY ${Col.localDate} ORDER BY d DESC LIMIT ?',
      <Object?>[userId, limit],
    );
    final List<LocalDay> days = <LocalDay>[];
    for (final Map<String, Object?> row in rows) {
      final LocalDay? day = LocalDay.tryParse(textValue(row['d']));
      if (day != null) days.add(day);
    }
    return days;
  }

  /// Number of distinct active days.
  Future<int> activeDayCount(int userId) async {
    final List<Map<String, Object?>> rows = await executor.rawQuery(
      'SELECT COUNT(DISTINCT ${Col.localDate}) AS c FROM $table '
      'WHERE ${Col.userId} = ? AND ($hasActivityPredicate)',
      <Object?>[userId],
    );
    return intValue(rows.first['c']);
  }

  /// Sum of one counter column over a local date range.
  ///
  /// [column] must be one of the `*_answered` / `*_taken` / `*_reviewed` counter
  /// columns; callers pass the constants from [Col].
  Future<int> sumBetween(
    int userId,
    String column,
    LocalDay from,
    LocalDay to,
  ) async {
    final List<Map<String, Object?>> rows = await executor.rawQuery(
      'SELECT COALESCE(SUM($column), 0) AS total FROM $table '
      'WHERE ${Col.userId} = ? AND ${Col.localDate} BETWEEN ? AND ?',
      <Object?>[userId, from.key, to.key],
    );
    return intValue(rows.first['total']);
  }

  /// The last [days] days ending today, including days with no activity row.
  Future<List<DailyActivitySlot>> recentSlots(
    int userId, {
    int days = 7,
    LocalDay? today,
  }) async {
    final LocalDay end = today ?? LocalDay.today();
    final LocalDay start = end.minusDays(days - 1);
    final Map<String, DailyActivity> byDate = <String, DailyActivity>{
      for (final DailyActivity row in await between(userId, start, end))
        row.localDate: row,
    };
    return List<DailyActivitySlot>.generate(days, (int index) {
      final LocalDay day = start.plusDays(index);
      return DailyActivitySlot(day: day, activity: byDate[day.key]);
    }, growable: false);
  }

  Future<int> deleteFor(int userId) => executor.delete(
        Tables.dailyActivity,
        where: '${Col.userId} = ?',
        whereArgs: <Object?>[userId],
      );

  /// The table this DAO writes to, used to qualify columns inside the upsert.
  static const String table = Tables.dailyActivity;

  /// `true` when at least one counter of the row is non-zero.
  static const String hasActivityPredicate =
      '${Col.xpEarned} <> 0 OR ${Col.questionsAnswered} <> 0 '
      'OR ${Col.questionsCorrect} <> 0 OR ${Col.quizzesTaken} <> 0 '
      'OR ${Col.lessonsOpened} <> 0 OR ${Col.flashcardsReviewed} <> 0 '
      'OR ${Col.studySeconds} <> 0';
}