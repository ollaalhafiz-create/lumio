import 'enums.dart';
import 'local_day.dart';
import 'row_values.dart';

/// A daily or weekly study goal, for example "earn 50 XP today".
class StudyGoal {
  const StudyGoal({
    required this.id,
    required this.userId,
    this.period = RepeatPeriod.daily,
    required this.targetType,
    required this.targetValue,
    this.rewardXp = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory StudyGoal.fromRow(Map<String, Object?> row) => StudyGoal(
        id: intValue(row['id']),
        userId: intValue(row['user_id']),
        period: RepeatPeriod.fromValue(row['period']),
        targetType: GoalTargetType.fromValue(row['target_type']),
        targetValue: intValue(row['target_value']),
        rewardXp: intValue(row['reward_xp']),
        isActive: boolValue(row['is_active']),
        createdAt: dateTimeValue(row['created_at']),
      );

  final int id;
  final int userId;
  final RepeatPeriod period;
  final GoalTargetType targetType;
  final int targetValue;

  /// Bonus XP granted once per period when the goal is met.
  final int rewardXp;

  final bool isActive;
  final DateTime createdAt;

  /// The `period_key` this goal uses for [day].
  String periodKeyFor(LocalDay day) => LocalDay.periodKey(period.key, day);

  /// The `local_date` this goal is anchored to: the exact day for a daily goal,
  /// the Monday of the week for a weekly one.
  LocalDay anchorFor(LocalDay day) =>
      period == RepeatPeriod.weekly ? day.startOfWeek : day;

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'user_id': userId,
        'period': period.key,
        'target_type': targetType.key,
        'target_value': targetValue,
        'reward_xp': rewardXp,
        'is_active': boolToInt(isActive),
        'created_at': dateTimeToMillis(createdAt),
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  StudyGoal copyWith({
    int? targetValue,
    int? rewardXp,
    bool? isActive,
  }) =>
      StudyGoal(
        id: id,
        userId: userId,
        period: period,
        targetType: targetType,
        targetValue: targetValue ?? this.targetValue,
        rewardXp: rewardXp ?? this.rewardXp,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
      );

  @override
  String toString() =>
      'StudyGoal($id, ${period.key} ${targetType.key} $targetValue)';
}

/// A goal together with its measured progress in one period.
class StudyGoalStatus {
  const StudyGoalStatus({
    required this.goal,
    required this.periodKey,
    required this.currentValue,
    required this.isClaimed,
  });

  final StudyGoal goal;

  /// `YYYY-MM-DD` for a daily goal, `YYYY-Www` for a weekly one.
  final String periodKey;

  /// Measured value of [StudyGoal.targetType] inside the period.
  final int currentValue;

  /// `true` when the bonus was already granted for this period.
  final bool isClaimed;

  /// `true` when the target has been reached.
  bool get isCompleted => currentValue >= goal.targetValue;

  /// `true` when the bonus can be granted right now.
  bool get isClaimable => isCompleted && !isClaimed && goal.rewardXp > 0;

  /// Progress towards the target as a fraction between `0` and `1`.
  double get fraction {
    if (goal.targetValue <= 0) return 1;
    if (currentValue >= goal.targetValue) return 1;
    return (currentValue / goal.targetValue).clamp(0.0, 1.0);
  }

  @override
  String toString() =>
      'StudyGoalStatus(${goal.id}, $periodKey, $currentValue/${goal.targetValue})';
}