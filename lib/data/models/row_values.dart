/// Null-safe readers for SQLite row maps.
///
/// sqflite hands back `Map<String, Object?>` where every value is nullable at
/// the type level even when the column is declared `NOT NULL`. These helpers
/// keep that casting in one place so models stay readable.
library;

/// Reads an integer, falling back to [orElse] when the value is null or not an
/// integer.
int intValue(Object? value, {int orElse = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return orElse;
}

/// Reads an optional integer.
int? intOrNull(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}

/// Reads an optional text value, treating empty strings as absent.
String? textOrNull(Object? value) {
  if (value is String && value.isNotEmpty) return value;
  return null;
}

/// Reads text, falling back to [orElse].
String textValue(Object? value, {String orElse = ''}) =>
    textOrNull(value) ?? orElse;

/// Reads a double, falling back to [orElse].
double doubleValue(Object? value, {double orElse = 0}) {
  if (value is num) return value.toDouble();
  return orElse;
}

/// Reads an optional double.
double? doubleOrNull(Object? value) {
  if (value is num) return value.toDouble();
  return null;
}

/// Reads a boolean stored as an integer (`0` / `1`).
bool boolValue(Object? value) => intValue(value) != 0;

/// Reads a boolean stored as an integer, defaulting to `false`.
bool boolOrFalse(Object? value) => boolValue(value);

/// Converts an `int`/`bool` value into the `0` / `1` form SQLite expects.
int boolToInt(bool value) => value ? 1 : 0;

/// Reads a nullable timestamp stored as epoch milliseconds.
DateTime? dateTimeOrNull(Object? value) {
  final int? millis = intOrNull(value);
  if (millis == null || millis == 0) return null;
  return DateTime.fromMillisecondsSinceEpoch(millis);
}

/// Reads a timestamp stored as epoch milliseconds.
DateTime dateTimeValue(Object? value) =>
    dateTimeOrNull(value) ?? DateTime.fromMillisecondsSinceEpoch(0);

/// Converts a [DateTime] into the epoch-milliseconds representation.
int dateTimeToMillis(DateTime value) => value.millisecondsSinceEpoch;

/// Parses a `,` separated list of short keys (used for answer option keys).
List<String> parseKeyList(Object? value) {
  final String raw = textValue(value);
  if (raw.isEmpty) return const <String>[];
  return raw
      .split(',')
      .map((String part) => part.trim())
      .where((String part) => part.isNotEmpty)
      .toList(growable: false);
}

/// Joins short keys into the `,` separated representation used by the schema.
String joinKeyList(List<String> keys) => keys.join(',');