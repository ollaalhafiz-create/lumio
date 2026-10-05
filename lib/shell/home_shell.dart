import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';

import '../core/localization/l10n_extension.dart';

/// Root shell with bottom navigation.
///
/// Screens are contributed by the UI layer; this widget owns only the
/// navigation scaffold so that shell behaviour stays in one place.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    final List<Widget> screens = <Widget>[
      const _Placeholder(name: 'Home'),
      const _Placeholder(name: 'Quizzes'),
      const _Placeholder(name: 'Challenges'),
      const _Placeholder(name: 'Progress'),
      const _Placeholder(name: 'Settings'),
    ];

    final List<String> labels = <String>[
      l10n.navHome,
      l10n.navQuizzes,
      l10n.navChallenges,
      l10n.navProgress,
      l10n.navSettings,
    ];

    final List<IconData> icons = <IconData>[
      Icons.home_outlined,
      Icons.quiz_outlined,
      Icons.flag_outlined,
      Icons.insights_outlined,
      Icons.settings_outlined,
    ];

    final List<IconData> selectedIcons = <IconData>[
      Icons.home,
      Icons.quiz,
      Icons.flag,
      Icons.insights,
      Icons.settings,
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int value) => setState(() => _index = value),
        destinations: <Widget>[
          for (int i = 0; i < labels.length; i++)
            NavigationDestination(
              icon: Icon(icons[i]),
              selectedIcon: Icon(selectedIcons[i]),
              label: labels[i],
            ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$name — ${context.l10n.loading}'),
    );
  }
}