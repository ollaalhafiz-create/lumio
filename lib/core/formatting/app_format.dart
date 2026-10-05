import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Locale-aware number, date and duration formatting.
///
/// Arabic is the primary locale. [ar] renders Eastern Arabic-Indic numerals
/// (٠١٢٣٤٥٦٧٨٩); [en] renders Western Arabic numerals (0123456789).
/// [useArabicNumerals] lets the user opt out of Arabic-Indic digits while
/// keeping the Arabic language, which is a common real-world preference.
class AppFormat {
  const AppFormat(this.localeCode, {required this.useArabicNumerals});

  final String localeCode;
  final bool useArabicNumerals;

  factory AppFormat.of(BuildContext context, {bool? useArabicNumerals}) {
    final String code = Localizations.localeOf(context).languageCode;
    return AppFormat(
      code == 'ar' ? 'ar' : 'en',
      useArabicNumerals: useArabicNumerals ?? false,
    );
  }

  static const AppFormat ar = AppFormat('ar', useArabicNumerals: true);
  static const AppFormat arWestern =
      AppFormat('ar', useArabicNumerals: false);
  static const AppFormat en = AppFormat('en', useArabicNumerals: false);

  /// Locales understood by `intl` for digits/calendar formatting.
  List<String> get _intlLocales => <String>[
        localeCode == 'ar' && useArabicNumerals ? 'ar' : 'en_US',
      ];

  /// Formats an integer using the locale's numeral system.
  String number(num value, {int decimalDigits = 0}) {
    final NumberFormat format = NumberFormat.decimalPatternDigits(
      locale: _intlLocales.first,
      decimalDigits: decimalDigits,
    );
    return format.format(value);
  }

  /// Formats a fraction as a percentage, e.g. `٨٥٪`.
  String percent(num fraction) => number((fraction * 100).round());

  /// Formats a date, e.g. `١٤ أكتوبر ٢٠٢٦` or `Oct 14, 2026`.
  String date(DateTime value) =>
      DateFormat.yMMMMd(_intlLocales.first).format(value);

  /// Formats a short date, e.g. `١٤/١٠/٢٠٢٦`.
  String shortDate(DateTime value) =>
      DateFormat.yMd(_intlLocales.first).format(value);

  /// Formats a time, e.g. `٣:٠٥ م`.
  String time(DateTime value) =>
      DateFormat.jm(_intlLocales.first).format(value);

  /// Formats a duration in whole minutes, e.g. `٤٥ د` / `45 min`.
  ///
  /// Arabic uses the abbreviated `د` for minutes so that it reads naturally
  /// alongside Arabic-Indic numerals.
  String minutes(int value) => localeCode == 'ar'
      ? '$value د'
      : '${_decimal.format(value)} min';

  NumberFormat get _decimal => NumberFormat.decimalPattern(_intlLocales.first);

  /// Converts Western digits in a string to Arabic-Indic digits.
  ///
  /// Useful for content that originates outside the app, such as quiz
  /// question text stored in the database.
  static String toArabicNumerals(String input) {
    const List<String> arabicDigits = <String>[
      '٠',
      '١',
      '٢',
      '٣',
      '٤',
      '٥',
      '٦',
      '٧',
      '٨',
      '٩',
    ];
    final StringBuffer buffer = StringBuffer();
    for (final int rune in input.runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        buffer.write(arabicDigits[rune - 0x30]);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }
}