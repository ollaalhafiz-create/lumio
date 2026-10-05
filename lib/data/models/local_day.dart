/// A calendar day in the device's local time zone.
///
/// Streaks and daily goals are business days, not instants: an activity at
/// 00:30 local time belongs to the day it was recorded on. Every write to
/// `daily_activity`, `study_sessions` and `xp_events` stores a [key] produced
/// here, so day buckets survive app restarts, timezone changes of the device
/// clock and daylight-saving shifts. Day arithmetic is done on `DateTime.utc`
/// values so it never drifts across a DST boundary.
final class LocalDay implements Comparable<LocalDay> {
  const LocalDay(this.year, this.month, this.day);

  /// Builds a [LocalDay] from the date part of [value].
  factory LocalDay.fromDateTime(DateTime value) =>
      LocalDay(value.year, value.month, value.day);

  /// Parses a `YYYY-MM-DD` key, returning `null` when [value] is not one.
  static LocalDay? tryParse(String? value) {
    if (value == null) return null;
    final List<String> parts = value.split('-');
    if (parts.length != 3) return null;
    final int? year = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    final int? day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return LocalDay(year, month, day);
  }

  /// Today, in the device's local time zone.
  factory LocalDay.today([DateTime? now]) =>
      LocalDay.fromDateTime(now ?? DateTime.now());

  final int year;
  final int month;
  final int day;

  /// `YYYY-MM-DD`, the value stored in `*_local_date` columns.
  String get key =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  /// Local midnight. Only used for arithmetic and weekday lookup.
  DateTime get dateTime => DateTime(year, month, day);

  DateTime get _utc => DateTime.utc(year, month, day);

  /// The previous calendar day.
  LocalDay get previous => LocalDay.fromDateTime(dateTime.subtract(const Duration(days: 1)));

  /// The next calendar day.
  LocalDay get next => LocalDay.fromDateTime(dateTime.add(const Duration(days: 1)));

  /// This day shifted back by [days] calendar days.
  LocalDay minusDays(int days) =>
      LocalDay.fromDateTime(dateTime.subtract(Duration(days: days)));

  /// This day shifted forward by [days] calendar days.
  LocalDay plusDays(int days) =>
      LocalDay.fromDateTime(dateTime.add(Duration(days: days)));

  /// Monday of the week this day belongs to.
  LocalDay get startOfWeek => LocalDay.fromDateTime(
        dateTime.subtract(Duration(days: dateTime.weekday - 1)),
      );

  /// Signed number of days between [this] and [other].
  int daysUntil(LocalDay other) => _utc.difference(other._utc).inDays;

  /// ISO-8601 week-numbering year.
  int get isoYear {
    final DateTime thursday = _thursdayOfIsoWeek;
    return thursday.year;
  }

  /// ISO-8601 week number, `1` .. `53`.
  int get isoWeek {
    final DateTime thursday = _thursdayOfIsoWeek;
    final DateTime firstOfYear = DateTime.utc(thursday.year, 1, 1);
    return ((thursday.difference(firstOfYear).inDays) ~/ 7) + 1;
  }

  /// `YYYY-Www`, used as the period key of weekly challenges and goals.
  String get weekKey =>
      '${isoYear.toString().padLeft(4, '0')}-W${isoWeek.toString().padLeft(2, '0')}';

  /// Period key for challenges of the given [period].
  ///
  /// Daily items use the plain day key, weekly items use the ISO week key.
  static String periodKey(String period, LocalDay day) =>
      period == 'weekly' ? day.weekKey : day.key;

  DateTime get _thursdayOfIsoWeek {
    final int weekday = _utc.weekday;
    return _utc.add(Duration(days: 4 - weekday));
  }

  @override
  int compareTo(LocalDay other) => key.compareTo(other.key);

  bool operator <(LocalDay other) => compareTo(other) < 0;

  bool operator <=(LocalDay other) => compareTo(other) <= 0;

  bool operator >(LocalDay other) => compareTo(other) > 0;

  bool operator >=(LocalDay other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is LocalDay &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => key;
}