import '../db/schema.dart';
import 'enums.dart';
import 'row_values.dart';

/// Typed view over the `settings` key/value table.
///
/// The table stays generic so new settings never need a migration, while this
/// class gives the UI a single immutable object with real defaults: missing or
/// unreadable rows fall back to Arabic-first defaults.
class UserSettings {
  const UserSettings({
    this.language = defaultLanguage,
    this.themeMode = ThemePreference.system,
    this.useArabicNumerals = true,
    this.dailyReminderEnabled = true,
    this.reminderHour = 20,
    this.reminderMinute = 0,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.onboardingCompleted = false,
    this.showAnswerExplanation = true,
    this.autoPlayAudio = true,
  });

  /// Reads settings from the `key` / `value` pairs of the settings table.
  factory UserSettings.fromStorage(Map<String, Object?> storage) {
    String readString(String key, String fallback) =>
        textOrNull(storage[key]) ?? fallback;

    bool readBool(String key, bool fallback) {
      final Object? value = storage[key];
      if (value == null) return fallback;
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is! String) return fallback;
      final String raw = value.trim().toLowerCase();
      if (raw == 'true' || raw == '1') return true;
      if (raw == 'false' || raw == '0') return false;
      return fallback;
    }

    return UserSettings(
      language: readString(SettingKeys.language, defaultLanguage),
      themeMode: ThemePreference.fromValue(
        readString(SettingKeys.themeMode, ThemePreference.system.key),
      ),
      useArabicNumerals: readBool(SettingKeys.useArabicNumerals, true),
      dailyReminderEnabled:
          readBool(SettingKeys.dailyReminderEnabled, true),
      reminderHour: intValue(
        storage[SettingKeys.reminderHour],
        orElse: 20,
      ),
      reminderMinute: intValue(
        storage[SettingKeys.reminderMinute],
        orElse: 0,
      ),
      soundEnabled: readBool(SettingKeys.soundEnabled, true),
      hapticsEnabled: readBool(SettingKeys.hapticsEnabled, true),
      onboardingCompleted: readBool(SettingKeys.onboardingCompleted, false),
      showAnswerExplanation:
          readBool(SettingKeys.showAnswerExplanation, true),
      autoPlayAudio: readBool(SettingKeys.autoPlayAudio, true),
    );
  }

  /// Arabic is the app's primary language.
  static const String defaultLanguage = 'ar';

  /// `ar` or `en`; any other stored value is treated as Arabic.
  final String language;

  final ThemePreference themeMode;

  /// Whether numbers are rendered with Arabic-Indic digits.
  final bool useArabicNumerals;

  final bool dailyReminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool onboardingCompleted;
  final bool showAnswerExplanation;
  final bool autoPlayAudio;

  /// `true` when the active language is Arabic.
  bool get isArabic => language != 'en';

  /// The reminder time as `HH:mm`.
  String get reminderTime =>
      '${reminderHour.toString().padLeft(2, '0')}:'
      '${reminderMinute.toString().padLeft(2, '0')}';

  /// Every setting as `key` to `(value, value_type)` rows, ready to be written
  /// to the `settings` table.
  Map<String, ({Object? value, String type})> toStorage() =>
      <String, ({Object? value, String type})>{
        SettingKeys.language: (value: language, type: 'string'),
        SettingKeys.themeMode: (value: themeMode.key, type: 'string'),
        SettingKeys.useArabicNumerals:
            (value: boolToInt(useArabicNumerals), type: 'int'),
        SettingKeys.dailyReminderEnabled:
            (value: boolToInt(dailyReminderEnabled), type: 'int'),
        SettingKeys.reminderHour: (value: reminderHour, type: 'int'),
        SettingKeys.reminderMinute: (value: reminderMinute, type: 'int'),
        SettingKeys.soundEnabled: (value: boolToInt(soundEnabled), type: 'int'),
        SettingKeys.hapticsEnabled:
            (value: boolToInt(hapticsEnabled), type: 'int'),
        SettingKeys.onboardingCompleted:
            (value: boolToInt(onboardingCompleted), type: 'int'),
        SettingKeys.showAnswerExplanation:
            (value: boolToInt(showAnswerExplanation), type: 'int'),
        SettingKeys.autoPlayAudio:
            (value: boolToInt(autoPlayAudio), type: 'int'),
      };

  UserSettings copyWith({
    String? language,
    ThemePreference? themeMode,
    bool? useArabicNumerals,
    bool? dailyReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? onboardingCompleted,
    bool? showAnswerExplanation,
    bool? autoPlayAudio,
  }) =>
      UserSettings(
        language: language ?? this.language,
        themeMode: themeMode ?? this.themeMode,
        useArabicNumerals: useArabicNumerals ?? this.useArabicNumerals,
        dailyReminderEnabled:
            dailyReminderEnabled ?? this.dailyReminderEnabled,
        reminderHour: reminderHour ?? this.reminderHour,
        reminderMinute: reminderMinute ?? this.reminderMinute,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
        showAnswerExplanation:
            showAnswerExplanation ?? this.showAnswerExplanation,
        autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      );

  @override
  String toString() => 'UserSettings($language, ${themeMode.key})';
}