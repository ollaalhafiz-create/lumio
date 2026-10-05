import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Owns the active [Locale] and persists the user's choice.
///
/// Arabic is the default and primary language: [supportedLocales] is ordered
/// with Arabic first, and [fallbackLocale] is Arabic, so a missing or unknown
/// system locale still resolves to Arabic rather than English.
class LocaleProvider extends ChangeNotifier {
  LocaleProvider({SharedPreferences? prefs}) {
    // ignore: prefer_initializing_formals
    _prefs = prefs;
  }

  static const String _prefsKey = 'app.locale';

  static const Locale arabic = Locale('ar');
  static const Locale english = Locale('en');

  static const List<Locale> supportedLocales = <Locale>[arabic, english];
  static const Locale fallbackLocale = arabic;

  SharedPreferences? _prefs;

  Locale _locale = arabic;

  /// The currently selected locale. Arabic until the user changes it.
  Locale get locale => _locale;

  TextDirection get textDirection =>
      _locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  bool get isArabic => _locale.languageCode == 'ar';

  /// `true` when the user has explicitly chosen a language in Settings.
  bool get hasExplicitChoice => _prefs?.containsKey(_prefsKey) ?? false;

  /// Loads the persisted locale. Falls back to Arabic.
  Future<void> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final String? code = _prefs?.getString(_prefsKey);
    _locale = switch (code) {
      'en' => english,
      _ => arabic,
    };
    notifyListeners();
  }

  /// Switches the active language and persists it.
  Future<void> setLocale(Locale locale) async {
    _prefs ??= await SharedPreferences.getInstance();
    if (locale.languageCode != 'ar' && locale.languageCode != 'en') {
      return;
    }
    if (locale == _locale) {
      return;
    }
    _locale = locale;
    notifyListeners();
    await _prefs?.setString(_prefsKey, locale.languageCode);
  }

  Future<void> toggleLocale() =>
      setLocale(isArabic ? english : arabic);
}