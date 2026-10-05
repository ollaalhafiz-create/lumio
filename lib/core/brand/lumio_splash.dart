import 'package:flutter/material.dart';

import '../theme/lumio_palette.dart';
import 'lumio_logo.dart';

/// The in-app Lumio splash.
///
/// The native Android splash already shows the mark on a flat brand backdrop
/// (see `res/drawable/launch_background.xml`), so this screen deliberately
/// repeats that exact composition: same mark, same background. The handover
/// between the native window and Flutter's first frame is therefore invisible,
/// and only the wordmark fades in here.
///
/// The entrance animation is finite — it completes and stops, so it never
/// keeps a frame scheduled.
class LumioSplash extends StatefulWidget {
  const LumioSplash({super.key, this.markSize = 76});

  final double markSize;

  @override
  State<LumioSplash> createState() => _LumioSplashState();
}

class _LumioSplashState extends State<LumioSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.7, curve: Curves.easeOut),
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 0.86,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LumioAccents accents = context.lumio;

    return Scaffold(
      // Matches @color/lumio_splash_background on the native side.
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(gradient: accents.backgroundGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  LumioMark(size: widget.markSize),
                  const SizedBox(height: 18),
                  Text(
                    'Lumio',
                    style: TextStyle(
                      fontFamily: AppThemeFont.family,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      fontVariations: const <FontVariation>[
                        FontVariation('wght', 800),
                      ],
                      letterSpacing: -0.5,
                      color: accents.ink,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}