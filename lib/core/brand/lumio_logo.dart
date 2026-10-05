import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/lumio_palette.dart';

/// Paints the Lumio Spark: the brand mark.
///
/// The mark is eight round-capped rays radiating from a single point —
/// four long brand-green rays on the diagonals and four short cyan rays on
/// the axes. It is drawn from the same proportions as the Android launcher
/// icon (`res/drawable/ic_lumio_mark.xml`), so the two never drift apart.
///
/// Everything is vector, so it stays crisp from a 16px launcher badge up to a
/// full-screen splash without any bitmap assets.
class LumioMarkPainter extends CustomPainter {
  const LumioMarkPainter({
    this.longRayColor = LumioPalette.green,
    this.shortRayColor = LumioPalette.cyan,
    this.monochrome,
  });

  /// Colour of the four long rays on the diagonals.
  final Color longRayColor;

  /// Colour of the four short rays on the axes.
  final Color shortRayColor;

  /// When set, every ray uses this single colour. Used for monochrome
  /// launcher icons and for contexts that must not rely on colour.
  final Color? monochrome;

  // Proportions, as a fraction of the mark's shortest side. These match the
  // launcher vector drawable exactly.
  static const double _stroke = 0.1050;
  static const double _longRay = 0.2350;
  static const double _shortRay = 0.1450;
  static const double _firstAngle = 45.0;
  static const double _step = 45.0;

  @override
  void paint(Canvas canvas, Size size) {
    final double side = size.shortestSide;
    if (side <= 0) {
      return;
    }

    final double centre = side / 2;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = side * _stroke;

    for (int i = 0; i < 8; i++) {
      final double angle = (_firstAngle + i * _step) * math.pi / 180;
      final bool isLong = i.isEven;
      final double length = side * (isLong ? _longRay : _shortRay);
      paint.color = monochrome ?? (isLong ? longRayColor : shortRayColor);
      canvas.drawLine(
        Offset(centre, centre),
        Offset(centre + math.cos(angle) * length, centre + math.sin(angle) * length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(LumioMarkPainter oldDelegate) {
    return oldDelegate.longRayColor != longRayColor ||
        oldDelegate.shortRayColor != shortRayColor ||
        oldDelegate.monochrome != monochrome;
  }
}

/// The Lumio symbol on its own, sized in logical pixels.
class LumioMark extends StatelessWidget {
  const LumioMark({
    super.key,
    this.size = 48,
    this.longRayColor = LumioPalette.green,
    this.shortRayColor = LumioPalette.cyan,
    this.monochrome,
    this.semanticsLabel,
  });

  final double size;
  final Color longRayColor;
  final Color shortRayColor;
  final Color? monochrome;

  /// Announced by screen readers when set; the mark is otherwise decorative.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final Widget mark = CustomPaint(
      size: Size.square(size),
      painter: LumioMarkPainter(
        longRayColor: longRayColor,
        shortRayColor: shortRayColor,
        monochrome: monochrome,
      ),
    );
    if (semanticsLabel == null) {
      return mark;
    }
    return Semantics(
      label: semanticsLabel,
      image: true,
      child: mark,
    );
  }
}

/// The full Lumio lockup: the symbol beside the wordmark.
///
/// The wordmark uses the bundled Cairo variable font at weight 800, which
/// keeps Arabic and Latin shapes correct instead of synthetically emboldened.
class LumioLogo extends StatelessWidget {
  const LumioLogo({
    super.key,
    this.markSize = 40,
    this.fontSize,
    this.gap = 12,
    this.color,
    this.markLongRayColor = LumioPalette.green,
    this.markShortRayColor = LumioPalette.cyan,
    this.showWordmark = true,
  });

  final double markSize;
  final double? fontSize;
  final double gap;

  /// Wordmark colour. Defaults to the theme's high-contrast ink.
  final Color? color;
  final Color markLongRayColor;
  final Color markShortRayColor;

  /// Set to `false` for centred layouts where the symbol stands alone.
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color ink = color ?? theme.colorScheme.onSurface;

    final Widget mark = LumioMark(
      size: markSize,
      longRayColor: markLongRayColor,
      shortRayColor: markShortRayColor,
    );

    if (!showWordmark) {
      return mark;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        mark,
        SizedBox(width: gap),
        Text(
          'Lumio',
          style: TextStyle(
            fontFamily: AppThemeFont.family,
            fontSize: fontSize ?? markSize * 0.62,
            fontWeight: FontWeight.w800,
            fontVariations: const <FontVariation>[FontVariation('wght', 800)],
            color: ink,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

/// The bundled font family, exposed here so brand widgets do not need to reach
/// into the theme file.
abstract final class AppThemeFont {
  static const String family = 'Cairo';
}