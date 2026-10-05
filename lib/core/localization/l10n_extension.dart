import 'package:flutter/widgets.dart';

import '../../l10n/gen/app_localizations.dart';

/// Convenient, non-null access to the generated localizations.
///
/// Going through [l10n] keeps the localization lookup in one place instead of
/// repeating `AppLocalizations.of(context)` at every call site.
extension AppLocalizationsX on BuildContext {
  /// The localizations for the active locale.
  ///
  /// The lookup cannot fail while the app is running, because `MaterialApp`
  /// installs `AppLocalizations.delegate` for every locale in
  /// `LocaleProvider.supportedLocales`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}