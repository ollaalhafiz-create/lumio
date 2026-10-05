import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lumio/core/localization/locale_provider.dart';
import 'package:lumio/l10n/gen/app_localizations.dart';
import 'package:lumio/main.dart';

void main() {
  testWidgets('boots in Arabic and renders RTL navigation',
      (WidgetTester tester) async {
    final LocaleProvider provider = LocaleProvider();
    await tester.pumpWidget(LumioApp(localeProvider: provider));
    await tester.pumpAndSettle();

    final AppLocalizations l10n =
        AppLocalizations.of(tester.element(find.byType(NavigationBar)));

    expect(find.text(l10n.navHome), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(NavigationBar))),
      TextDirection.rtl,
    );
  });
}
