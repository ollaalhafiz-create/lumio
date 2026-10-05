import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/brand/lumio_components.dart';
import '../../core/brand/lumio_logo.dart';
import '../../core/localization/l10n_extension.dart';
import '../../core/theme/lumio_palette.dart';
import '../../l10n/gen/app_localizations.dart';

/// The three-screen introduction shown once, before the main interface.
///
/// Everything the user sees before the app proper — the native splash, the
/// Flutter splash and these screens — shares one composition: the Lumio Spark,
/// a very light backdrop, and the brand accent. Skipping or finishing records
/// that it has been seen so the next launch goes straight to the interface.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});

  /// Shared-preferences key recording that onboarding has been completed.
  static const String prefsKey = 'app.onboardingSeen';

  /// Called once the user skips or finishes the last page.
  final VoidCallback onFinished;

  /// `true` when the user has already been through onboarding.
  static Future<bool> hasSeen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsKey) ?? false;
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages - 1;

  static const int _pages = 3;

  Future<void> _finish() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingScreen.prefsKey, true);
    if (mounted) widget.onFinished();
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final LumioAccents accents = context.lumio;

    final List<_OnboardingPage> pages = <_OnboardingPage>[
      _OnboardingPage(
        title: l10n.onboardingTitle1,
        body: l10n.onboardingBody1,
        art: _LearnArt(accents: accents),
      ),
      _OnboardingPage(
        title: l10n.onboardingTitle2,
        body: l10n.onboardingBody2,
        art: _AiArt(accents: accents),
      ),
      _OnboardingPage(
        title: l10n.onboardingTitle3,
        body: l10n.onboardingBody3,
        art: _GrowArt(accents: accents),
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: accents.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                child: Row(
                  children: <Widget>[
                    LumioMark(size: 30),
                    const Spacer(),
                    TextButton(
                      onPressed: _finish,
                      child: Text(l10n.actionSkip),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (int value) => setState(() => _index = value),
                  itemBuilder: (BuildContext context, int i) {
                    final _OnboardingPage page = pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // The art is scaled down rather than allowed to
                          // overflow, so short screens stay intact.
                          Expanded(
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: SizedBox(
                                  width: 264,
                                  height: 216,
                                  child: page.art,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page.body,
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: accents.inkMuted,
                                    ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              LumioPageDots(count: pages.length, index: _index),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _next,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        _isLast ? l10n.actionStart : l10n.actionNext,
                        key: ValueKey<bool>(_isLast),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({required this.title, required this.body, required this.art});

  final String title;
  final String body;
  final Widget art;
}

/// "Learn": a small stack of lesson cards with the mark floating above them.
class _LearnArt extends StatelessWidget {
  const _LearnArt({required this.accents});

  final LumioAccents accents;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _ArtCard(width: 190, height: 46, accents: accents, tint: accents.brandTint),
                const SizedBox(height: 12),
                _ArtCard(width: 214, height: 46, accents: accents, tint: accents.aquaTint),
                const SizedBox(height: 12),
                _ArtCard(width: 176, height: 46, accents: accents, tint: accents.goldTint),
              ],
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0.62, -0.78),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: accents.ink.withValues(alpha: 0.10),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: LumioMark(size: 40),
          ),
        ),
      ],
    );
  }
}

/// "AI Study": the mark on a soft purple field, ringed by small sparkles.
class _AiArt extends StatelessWidget {
  const _AiArt({required this.accents});

  final LumioAccents accents;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: 176,
          height: 176,
          decoration: BoxDecoration(
            gradient: accents.purpleGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                shape: BoxShape.circle,
              ),
              child: LumioMark(
                size: 52,
                longRayColor: accents.purple,
                shortRayColor: accents.cyan,
              ),
            ),
          ),
        ),
        _Sparkle(align: const Alignment(-0.95, -0.55), size: 22, color: accents.gold),
        _Sparkle(align: const Alignment(0.92, -0.62), size: 16, color: accents.cyan),
        _Sparkle(align: const Alignment(0.98, 0.5), size: 20, color: accents.coralBright),
        _Sparkle(align: const Alignment(-0.9, 0.58), size: 14, color: accents.brandMint),
      ],
    );
  }
}

/// "Grow": rising bars in the brand gradient, capped by the mark.
class _GrowArt extends StatelessWidget {
  const _GrowArt({required this.accents});

  final LumioAccents accents;

  @override
  Widget build(BuildContext context) {
    const List<double> heights = <double>[42, 66, 90, 118];

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                for (int i = 0; i < heights.length; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 7),
                    width: 30,
                    height: heights[i],
                    decoration: BoxDecoration(
                      gradient: i == heights.length - 1
                          ? accents.goldGradient
                          : accents.brandGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0.55, -0.92),
          child: LumioMark(size: 34),
        ),
      ],
    );
  }
}

class _ArtCard extends StatelessWidget {
  const _ArtCard({
    required this.width,
    required this.height,
    required this.accents,
    required this.tint,
  });

  final double width;
  final double height;
  final LumioAccents accents;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tint),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accents.ink.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          width: 54,
          height: 10,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

/// A four-point sparkle, matching the geometry of the brand mark.
class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.align, required this.size, required this.color});

  final Alignment align;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: align,
      child: CustomPaint(
        size: Size.square(size),
        painter: _SparklePainter(color),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint paint = Paint()..color = color;

    // Two thin diamonds crossing: a four-point star with concave edges.
    final Path vertical = Path()
      ..moveTo(w / 2, 0)
      ..quadraticBezierTo(w * 0.62, h * 0.38, w, h / 2)
      ..quadraticBezierTo(w * 0.62, h * 0.62, w / 2, h)
      ..quadraticBezierTo(w * 0.38, h * 0.62, 0, h / 2)
      ..quadraticBezierTo(w * 0.38, h * 0.38, w / 2, 0);
    canvas.drawPath(vertical, paint);
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => oldDelegate.color != color;
}