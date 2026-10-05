/// A user-facing string that exists in Arabic and, when available, English.
///
/// Arabic is the primary language of the app, so [ar] is required and [en] is
/// optional: [resolve] falls back to the Arabic text when no translation has
/// been written yet. Nothing here concatenates punctuation or reorders text,
/// which keeps the value direction-agnostic and safe in RTL and LTR.
final class LocalizedText {
  const LocalizedText({required this.ar, this.en});

  /// Arabic-only text.
  const LocalizedText.arOnly(this.ar) : en = null;

  /// Builds a value from two raw column values.
  factory LocalizedText.fromColumns(Object? ar, Object? en) =>
      LocalizedText(ar: ar is String ? ar : '', en: en is String ? en : null);

  /// An empty value.
  static const LocalizedText empty = LocalizedText(ar: '');

  final String ar;
  final String? en;

  /// `true` when an English translation has been provided.
  bool get hasTranslation {
    final String? value = en;
    return value != null && value.trim().isNotEmpty;
  }

  /// Text for [languageCode] (`'ar'` or `'en'`), falling back to Arabic.
  String resolve(String languageCode) {
    if (languageCode != 'ar' && hasTranslation) return en!;
    return ar;
  }

  /// Returns a copy with [value] as the English translation.
  LocalizedText withEnglish(String? value) =>
      LocalizedText(ar: ar, en: value);

  /// Returns the `title_ar` / `title_en` (or any `_ar` / `_en`) column pair.
  Map<String, Object?> toColumns(String arColumn, String enColumn) =>
      <String, Object?>{arColumn: ar, enColumn: en};

  @override
  bool operator ==(Object other) =>
      other is LocalizedText && other.ar == ar && other.en == en;

  @override
  int get hashCode => Object.hash(ar, en);

  @override
  String toString() => 'LocalizedText(ar: $ar, en: $en)';
}