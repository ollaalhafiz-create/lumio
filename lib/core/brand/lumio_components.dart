import 'package:flutter/material.dart';

import '../theme/lumio_palette.dart';

/// A white, softly bordered card with a lifted shadow.
///
/// The building block for every panel in the app, so cards across different
/// screens stay visually identical instead of drifting apart.
class LumioSurfaceCard extends StatelessWidget {
  const LumioSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 20,
    this.gradient,
    this.borderColor,
    this.elevation = 0,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Optional fill. Leave unset for the plain white surface.
  final Gradient? gradient;
  final Color? borderColor;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final LumioAccents accents = context.lumio;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? Theme.of(context).colorScheme.surface : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? accents.brand.withValues(alpha: 0.10)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accents.ink.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Scales its child down slightly while pressed.
///
/// The single micro-interaction used for tappable cards, so every pressable
/// surface in the app acknowledges the touch the same way.
class LumioPressScale extends StatefulWidget {
  const LumioPressScale({super.key, required this.child, this.onTap, this.scale = 0.96});

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<LumioPressScale> createState() => _LumioPressScaleState();
}

class _LumioPressScaleState extends State<LumioPressScale> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// The page indicator used by onboarding: a stretchy pill for the active page
/// and dots for the rest.
class LumioPageDots extends StatelessWidget {
  const LumioPageDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final LumioAccents accents = context.lumio;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: i == index ? 26 : 8,
            decoration: BoxDecoration(
              gradient: i == index ? accents.brandGradient : null,
              color: i == index ? null : accents.brand.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}