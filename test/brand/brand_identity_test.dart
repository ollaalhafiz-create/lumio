import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lumio/core/brand/lumio_logo.dart';
import 'package:lumio/core/brand/lumio_splash.dart';
import 'package:lumio/core/localization/locale_provider.dart';
import 'package:lumio/features/onboarding/onboarding_screen.dart';
import 'package:lumio/l10n/gen/app_localizations.dart';
import 'package:lumio/main.dart';
import 'package:lumio/shell/home_shell.dart';

/// Verifies the branded entry sequence and that the logo is actually present in
/// the shipped widget tree, not just defined in a file nobody renders.
void main() {
  /// The intro flow only reaches onboarding after its minimum-splash timer, so
  /// tests must pump past it rather than expecting it settled immediately.
  Future<void> showOnboarding(WidgetTester tester) async {
    await tester.pumpWidget(
      LumioApp(
        localeProvider: LocaleProvider(),
        showIntro: true,
        showOnboarding: true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
  }

  AppLocalizations l10nOf(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(OnboardingScreen)));

  testWidgets('the Flutter splash is shown before onboarding',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      LumioApp(
        localeProvider: LocaleProvider(),
        showIntro: true,
        showOnboarding: true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.byType(LumioSplash), findsOneWidget);
    expect(find.byType(LumioMark), findsWidgets);
  });

  testWidgets('a first run lands on onboarding, not the interface',
      (WidgetTester tester) async {
    await showOnboarding(tester);

    final AppLocalizations l10n = l10nOf(tester);
    expect(find.text(l10n.onboardingTitle1), findsOneWidget);
    expect(find.byType(HomeShell), findsNothing);
    // The later pages are built lazily, so they are not in the tree yet.
    expect(find.text(l10n.onboardingTitle3), findsNothing);
  });

  testWidgets('onboarding advances through all three pages',
      (WidgetTester tester) async {
    await showOnboarding(tester);
    final AppLocalizations l10n = l10nOf(tester);

    expect(find.text(l10n.onboardingTitle1), findsOneWidget);
    expect(find.text(l10n.actionNext), findsOneWidget);

    await tester.tap(find.text(l10n.actionNext));
    await tester.pumpAndSettle();
    expect(find.text(l10n.onboardingTitle2), findsOneWidget);

    await tester.tap(find.text(l10n.actionNext));
    await tester.pumpAndSettle();
    expect(find.text(l10n.onboardingTitle3), findsOneWidget);

    // The call to action becomes the terminal one on the last page.
    expect(find.text(l10n.actionStart), findsOneWidget);
  });

  testWidgets('onboarding survives small screens and landscape without overflow',
      (WidgetTester tester) async {
    for (final Size size in <Size>[
      const Size(320, 568),
      const Size(568, 320),
      const Size(412, 915),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await showOnboarding(tester);
      expect(tester.takeException(), isNull, reason: 'overflow at $size');
    }
  });

  testWidgets('the main interface carries the Lumio logo',
      (WidgetTester tester) async {
    await tester.pumpWidget(LumioApp(localeProvider: LocaleProvider()));
    await tester.pumpAndSettle();

    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.byType(LumioLogo), findsOneWidget);
    expect(find.text('Lumio'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}