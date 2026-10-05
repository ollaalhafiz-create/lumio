import 'enums.dart';
import 'row_values.dart';

/// A timed stretch of study, used for the "study time" statistic and for the
/// daily challenge measured in minutes.
///
/// [localDate] is written when the session is closed so the day bucket cannot
/// drift when the device clock moves across midnight while a session is open.
class StudySession {
  const StudySession({
    required this.id,
    required this.userId,
    this.entityType,
    this.entityId,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds = 0,
    required this.localDate,
    this.isCompleted = false,
  });

  factory StudySession.fromRow(Map<String, Object?> row) => StudySession(
        id: intValue(row['id']),
        userId: intValue(row['user_id']),
        entityType: ProgressEntity.fromValue(row['entity_type']),
        entityId: intOrNull(row['entity_id']),
        startedAt: dateTimeValue(row['started_at']),
        endedAt: dateTimeOrNull(row['ended_at']),
        durationSeconds: intValue(row['duration_seconds']),
        localDate: textValue(row['local_date']),
        isCompleted: boolValue(row['completed']),
      );

  final int id;
  final int userId;

  /// Optional link to the item being studied.
  final ProgressEntity? entityType;
  final int? entityId;

  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;

  /// `YYYY-MM-DD` local day the session belongs to.
  final String localDate;

  final bool isCompleted;

  /// Study time in whole minutes.
  int get minutes => durationSeconds ~/ 60;

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'user_id': userId,
        'entity_type': entityType?.key,
        'entity_id': entityId,
        'started_at': dateTimeToMillis(startedAt),
        'ended_at': endedAt == null ? null : dateTimeToMillis(endedAt!),
        'duration_seconds': durationSeconds,
        'local_date': localDate,
        'completed': boolToInt(isCompleted),
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  StudySession copyWith({
    int? id,
    DateTime? endedAt,
    int? durationSeconds,
    bool? isCompleted,
  }) =>
      StudySession(
        id: id ?? this.id,
        userId: userId,
        entityType: entityType,
        entityId: entityId,
        startedAt: startedAt,
        endedAt: endedAt ?? this.endedAt,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        localDate: localDate,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  @override
  String toString() => 'StudySession($id, ${durationSeconds}s)';
}