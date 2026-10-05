import 'enums.dart';
import 'localized_text.dart';
import 'row_values.dart';

/// An achievement definition, for example `أسبوع متتالٍ`.
class Achievement {
  const Achievement({
    required this.id,
    required this.code,
    required this.name,
    this.description = LocalizedText.empty,
    required this.iconKey,
    required this.metric,
    required this.threshold,
    this.xpReward = 25,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory Achievement.fromRow(Map<String, Object?> row) => Achievement(
        id: intValue(row['id']),
        code: textValue(row['code']),
        name: LocalizedText.fromColumns(row['name_ar'], row['name_en']),
        description: LocalizedText.fromColumns(
          row['description_ar'],
          row['description_en'],
        ),
        iconKey: textValue(row['icon_key']),
        metric: AchievementMetric.fromValue(row['metric']),
        threshold: intValue(row['threshold']),
        xpReward: intValue(row['xp_reward']),
        sortOrder: intValue(row['sort_order']),
        isActive: boolValue(row['is_active']),
      );

  final int id;

  /// Stable machine code, for example `streak_7`.
  final String code;

  /// Bilingual achievement name; Arabic is primary.
  final LocalizedText name;

  /// Bilingual explanation of how to unlock it.
  final LocalizedText description;

  /// Semantic icon key for the UI.
  final String iconKey;

  /// The statistic this achievement watches.
  final AchievementMetric metric;

  /// Value of [metric] required to unlock.
  final int threshold;

  /// XP granted when the reward is claimed.
  final int xpReward;

  final int sortOrder;
  final bool isActive;

  Map<String, Object?> toRow() => <String, Object?>{
        'id': id,
        'code': code,
        'name_ar': name.ar,
        'name_en': name.en,
        'description_ar': description.ar,
        'description_en': description.en,
        'icon_key': iconKey,
        'metric': metric.key,
        'threshold': threshold,
        'xp_reward': xpReward,
        'sort_order': sortOrder,
        'is_active': boolToInt(isActive),
      };

  Map<String, Object?> toInsertRow() =>
      Map<String, Object?>.from(toRow())..remove('id');

  @override
  String toString() => 'Achievement($id, $code)';
}

/// An achievement together with the learner's live progress against it.
class AchievementStatus {
  const AchievementStatus({
    required this.achievement,
    required this.currentValue,
    required this.isUnlocked,
    required this.isClaimed,
  });

  final Achievement achievement;

  /// Current value of [Achievement.metric].
  final int currentValue;

  /// `true` when [Achievement.threshold] has been reached.
  final bool isUnlocked;

  /// `true` when the reward was already claimed. Claiming again is impossible.
  final bool isClaimed;

  /// `true` when the achievement can be claimed right now.
  bool get isClaimable => isUnlocked && !isClaimed;

  /// Progress towards the threshold as a fraction between `0` and `1`.
  double get progress {
    final int threshold = achievement.threshold;
    if (threshold <= 0) return 1;
    if (currentValue >= threshold) return 1;
    return (currentValue / threshold).clamp(0.0, 1.0);
  }

  /// XP still missing, `0` once unlocked.
  int get remaining => achievement.threshold - currentValue <= 0
      ? 0
      : achievement.threshold - currentValue;

  @override
  String toString() =>
      'AchievementStatus(${achievement.code}, $currentValue/${achievement.threshold})';
}