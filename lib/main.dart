import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/l10n_extension.dart';
import 'core/localization/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/lumio_intro_flow.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'l10n/gen/app_localizations.dart';
import 'shell/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Resolved before the first frame so the intro flow never has to wait: the
  // native splash is already on screen while this runs.
  final bool seenOnboarding = await OnboardingScreen.hasSeen();

  final LocaleProvider localeProvider = LocaleProvider();
  await localeProvider.load();

  runApp(
    LumioApp(
      localeProvider: localeProvider,
      showIntro: true,
      showOnboarding: !seenOnboarding,
    ),
  );
}

class LumioApp extends StatelessWidget {
  const LumioApp({
    super.key,
    required this.localeProvider,
    this.showIntro = false,
    this.showOnboarding = false,
  });

  final LocaleProvider localeProvider;

  /// Whether to play the branded splash and, on a first run, onboarding.
  /// Defaults to `false` so the app can be mounted directly on a screen.
  final bool showIntro;

  /// Whether onboarding should be included in [showIntro].
  final bool showOnboarding;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeProvider,
      builder: (BuildContext context, Widget? child) {
        final Locale locale = localeProvider.locale;
        return MaterialApp(
          onGenerateTitle: (BuildContext context) => context.l10n.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(
            textDirection: localeProvider.textDirection,
          ),
          darkTheme: AppTheme.dark(
            textDirection: localeProvider.textDirection,
          ),
          // Rebuilding on locale change lets the theme mirror instantly, in
          // step with Flutter's own Directionality resolution.
          themeMode: ThemeMode.light,
          locale: locale,
          supportedLocales: LocaleProvider.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<Object>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Arabic first, so an unrecognised system locale falls back to the
          // app's primary language rather than English.
          localeListResolutionCallback:
              (List<Locale>? locales, Iterable<Locale> supported) {
            if (locales == null || locales.isEmpty) {
              return LocaleProvider.fallbackLocale;
            }
            for (final Locale candidate in locales) {
              for (final Locale option in supported) {
                if (candidate.languageCode == option.languageCode) {
                  return option;
                }
              }
            }
            return LocaleProvider.fallbackLocale;
          },
          home: showIntro
              ? LumioIntroFlow(showOnboarding: showOnboarding)
              : const HomeShell(),
        );
      },
    );
  }
}