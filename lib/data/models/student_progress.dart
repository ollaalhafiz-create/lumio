import 'row_values.dart';

/// Progress of the learner against one content item (subject, chapter, lesson
/// or quiz).
class StudentProgress {
  const StudentProgress({
    required this.id,
    required this.userId,
    required this.entityType,
    required this.entityId,
    this.progressPercent = 0,
    this.bestScore = 0,
    this.attempts = 0,
    this.timeSpentSeconds = 0,
    this.lastActivityAt,
    this.completedAt,
  });

  factory StudentProgress.fromRow(Map<String, Object?> row) => StudentProgress(
        id: intValue(row['id']),
        userId: intValue(row['user_id']),
        entityType: textValue(row['entity_type']),
        entityId: intValue(row['entity_id']),
        progressPercent: intValue(row['progress_percent']),
        bestScore: intValue(row['best_score']),
        attempts: intValue(row['attempts']),
        timeSpentSeconds: intValue(row['time_spent_seconds']),
        lastActivityAt: dateTimeOrNull(row['last_activity_at']),
        completedAt: dateTimeOrNull(row['completed_at']),
      );

  final int id;
  final int userId;
  final String entityType;
  final int entityId;

  /// `0` .. `100`.
  final int progressPercent;

  /// Best score of a quiz attempt, as a percentage.
  final int bestScore;

  final int attempts;
  final int timeSpentSeconds;
  final DateTime? lastActivityAt;
  final DateTime? completedAt;

  /// Whether the learner finished this item.
  bool get isCompleted => completedAt != null || progressPercent >= 100;

  /// Whether the learner started but did not finish.
  bool get isInProgress =>
      !isCompleted && (progressPercent > 0 || attempts > 0);

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'user_id': userId,
        'entity_type': entityType,
        'entity_id': entityId,
        'progress_percent': progressPercent,
        'best_score': bestScore,
        'attempts': attempts,
        'time_spent_seconds': timeSpentSeconds,
        'last_activity_at': lastActivityAt == null
            ? null
            : dateTimeToMillis(lastActivityAt!),
        'completed_at':
            completedAt == null ? null : dateTimeToMillis(completedAt!),
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  /// The mutable part of the row, used by the upsert statements.
  Map<String, Object?> toMutableRow({
    required int progressPercent,
    required int bestScore,
    required int attempts,
    required int timeSpentSeconds,
    DateTime? lastActivityAt,
    DateTime? completedAt,
  }) =>
      <String, Object?>{
        'progress_percent': progressPercent,
        'best_score': bestScore,
        'attempts': attempts,
        'time_spent_seconds': timeSpentSeconds,
        'last_activity_at': lastActivityAt == null
            ? null
            : dateTimeToMillis(lastActivityAt),
        'completed_at':
            completedAt == null ? null : dateTimeToMillis(completedAt),
      };

  @override
  String toString() =>
      'StudentProgress($userId, $entityType:$entityId, $progressPercent%)';
}