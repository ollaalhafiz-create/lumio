import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/brand/lumio_splash.dart';
import '../../shell/home_shell.dart';
import 'onboarding_screen.dart';

/// The branded entry sequence: the Flutter splash, then onboarding on first
/// run, then the app itself.
///
/// This is a plain widget swap rather than a route push, so there is no
/// back-navigation entry that would return the user to onboarding.
///
/// Splitting it out of `LumioApp` keeps the intro out of the way of tests and
/// of any other entry point that wants to land straight on the interface.
class LumioIntroFlow extends StatefulWidget {
  const LumioIntroFlow({super.key, required this.showOnboarding});

  /// Whether this is a first run and onboarding should be shown.
  final bool showOnboarding;

  /// How long the Flutter splash stays up. The work it covers is already done
  /// before this runs, so this is purely a minimum brand beat.
  static const Duration minimumSplash = Duration(milliseconds: 700);

  @override
  State<LumioIntroFlow> createState() => _LumioIntroFlowState();
}

enum _Stage { splash, onboarding, app }

class _LumioIntroFlowState extends State<LumioIntroFlow> {
  Timer? _timer;
  _Stage _stage = _Stage.splash;

  @override
  void initState() {
    super.initState();
    _timer = Timer(LumioIntroFlow.minimumSplash, () {
      if (!mounted) return;
      setState(() {
        _stage = widget.showOnboarding ? _Stage.onboarding : _Stage.app;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget screen = switch (_stage) {
      _Stage.splash => const LumioSplash(),
      _Stage.onboarding =>
        OnboardingScreen(onFinished: () => setState(() => _stage = _Stage.app)),
      _Stage.app => const HomeShell(),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: KeyedSubtree(
        key: ValueKey<_Stage>(_stage),
        child: screen,
      ),
    );
  }
}