import 'localized_text.dart';

/// One level of the progression curve.
///
/// Levels are never hand-assigned: [LevelCurve.levelForXp] derives the level
/// from the cumulative XP total, and [minXp] is generated from the same
/// formula the `levels` table is seeded with.
final class LevelDef {
  const LevelDef({
    required this.level,
    required this.title,
    required this.minXp,
    required this.iconKey,
  });

  /// 1-based level number.
  final int level;

  /// Bilingual level title; Arabic is primary.
  final LocalizedText title;

  /// Cumulative XP required to reach this level.
  final int minXp;

  /// Semantic icon key for the UI to map onto an icon.
  final String iconKey;

  @override
  String toString() => 'LevelDef($level, $minXp XP)';
}

/// The XP → level curve.
///
/// ## Formula
///
/// Cumulative XP required to reach level `L` (where `n = L - 1`):
///
/// ```text
/// minXp(L) = 25 * n * (n + 1)        // n >= 0
/// ```
///
/// which is the quadratic series `0, 50, 150, 300, 500, 750, 1050, ...`, i.e.
/// each level needs `50 * n` more XP than the previous one
/// (`50, 100, 150, 200, 250, ...`). The curve is capped at
/// [maxLevel] = 50, which needs 61,250 XP.
///
/// A level is therefore *always* derived:
///
/// ```text
/// level = max { L : minXp(L) <= totalXp }, capped at maxLevel
/// ```
///
/// and the level number itself is never written to a user or achievement row,
/// so XP can be recalculated, revoked or migrated without drift.
abstract final class LevelCurve {
  /// Highest level the curve produces.
  static const int maxLevel = 50;

  /// Fixed multiplier of the quadratic curve.
  static const int _multiplier = 25;

  /// Cumulative XP required to reach [level]. Level 1 needs `0` XP.
  static int minXpForLevel(int level) {
    if (level <= 1) return 0;
    final int capped = level > maxLevel ? maxLevel : level;
    final int n = capped - 1;
    return _multiplier * n * (n + 1);
  }

  /// XP needed to move from [level] to the next one; `0` at [maxLevel].
  static int xpToNextLevel(int level) {
    if (level >= maxLevel) return 0;
    return minXpForLevel(level + 1) - minXpForLevel(level);
  }

  /// XP accumulated inside the current level.
  static int xpIntoLevel(int level, int totalXp) {
    final int into = totalXp - minXpForLevel(level);
    if (into < 0) return 0;
    return into;
  }

  /// Progress inside the current level as a fraction between `0` and `1`.
  static double levelProgress(int level, int totalXp) {
    final int needed = xpToNextLevel(level);
    if (needed <= 0) return 1;
    final int into = xpIntoLevel(level, totalXp);
    if (into >= needed) return 1;
    return into / needed;
  }

  /// Derives the level for a cumulative XP [totalXp].
  static int levelForXp(int totalXp) {
    if (totalXp <= 0) return 1;
    int level = 1;
    while (level < maxLevel && minXpForLevel(level + 1) <= totalXp) {
      level++;
    }
    return level;
  }

  /// Derives the full level record for a cumulative XP [totalXp].
  static LevelDef definitionForXp(int totalXp) => forLevel(levelForXp(totalXp));

  /// The level record for [level], with its generated title and icon.
  static LevelDef forLevel(int level) {
    final int safeLevel = level < 1
        ? 1
        : level > maxLevel
            ? maxLevel
            : level;
    final _LevelTier tier = _tierFor(safeLevel);
    return LevelDef(
      level: safeLevel,
      title: LocalizedText(ar: tier.titleAr, en: tier.titleEn),
      minXp: minXpForLevel(safeLevel),
      iconKey: tier.iconKey,
    );
  }

  /// Every level of the curve, for seeding the `levels` table.
  static List<LevelDef> get definitions => List<LevelDef>.generate(
        maxLevel,
        (int index) => forLevel(index + 1),
        growable: false,
      );

  static _LevelTier _tierFor(int level) {
    for (final _LevelTier tier in _tiers) {
      if (level >= tier.from && level <= tier.to) return tier;
    }
    return _tiers.last;
  }

  static const List<_LevelTier> _tiers = <_LevelTier>[
    _LevelTier(
      from: 1,
      to: 2,
      titleAr: 'مبتدئ',
      titleEn: 'Beginner',
      iconKey: 'level_seed',
    ),
    _LevelTier(
      from: 3,
      to: 4,
      titleAr: 'متدرّب',
      titleEn: 'Trainee',
      iconKey: 'level_sprout',
    ),
    _LevelTier(
      from: 5,
      to: 6,
      titleAr: 'متمرّس',
      titleEn: 'Practiced',
      iconKey: 'level_shield',
    ),
    _LevelTier(
      from: 7,
      to: 9,
      titleAr: 'ماهر',
      titleEn: 'Skilled',
      iconKey: 'level_star',
    ),
    _LevelTier(
      from: 10,
      to: 12,
      titleAr: 'مبدع',
      titleEn: 'Creative',
      iconKey: 'level_spark',
    ),
    _LevelTier(
      from: 13,
      to: 15,
      titleAr: 'محترف',
      titleEn: 'Professional',
      iconKey: 'level_crown',
    ),
    _LevelTier(
      from: 16,
      to: 20,
      titleAr: 'خبير',
      titleEn: 'Expert',
      iconKey: 'level_diamond',
    ),
    _LevelTier(
      from: 21,
      to: 25,
      titleAr: 'قائد',
      titleEn: 'Leader',
      iconKey: 'level_banner',
    ),
    _LevelTier(
      from: 26,
      to: 32,
      titleAr: 'عبقري',
      titleEn: 'Genius',
      iconKey: 'level_torch',
    ),
    _LevelTier(
      from: 33,
      to: 40,
      titleAr: 'أسطورة',
      titleEn: 'Legend',
      iconKey: 'level_flame',
    ),
    _LevelTier(
      from: 41,
      to: LevelCurve.maxLevel,
      titleAr: 'خلّاق',
      titleEn: 'Luminary',
      iconKey: 'level_infinity',
    ),
  ];
}

final class _LevelTier {
  const _LevelTier({
    required this.from,
    required this.to,
    required this.titleAr,
    required this.titleEn,
    required this.iconKey,
  });

  final int from;
  final int to;
  final String titleAr;
  final String titleEn;
  final String iconKey;
}