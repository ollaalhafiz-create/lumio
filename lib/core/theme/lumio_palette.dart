import 'package:flutter/material.dart';

/// The Lumio colour system.
///
/// These are fixed brand tokens rather than generated tonal palettes, so every
/// screen draws from one recognisable set. Each hue has a role:
///
/// * green  – the brand, and "you are making progress"
/// * aqua   – interactive and informational
/// * gold   – achievements, rewards, streaks
/// * coral  – challenges and important actions
/// * purple – special sections and creativity
///
/// Foreground pairs were picked so body text clears WCAG AA (4.5:1) on the
/// surface it sits on; see the contrast notes beside the declarations.
abstract final class LumioPalette {
  // ---------------------------------------------------------------- neutrals
  /// Primary text colour. 17.9:1 on white.
  static const Color ink = Color(0xFF0E1A14);

  /// Secondary text (captions, helper copy). 7.3:1 on white.
  static const Color inkMuted = Color(0xFF4A5C52);

  /// App background: a barely-there green tint so the app never reads as flat
  /// grey. 17.1:1 against [ink].
  static const Color background = Color(0xFFF6FBF8);

  /// Cards and sheets.
  static const Color surface = Color(0xFFFFFFFF);

  /// A second surface level for nested blocks.
  static const Color surfaceMuted = Color(0xFFF1F7F3);

  /// Hairlines and card borders.
  static const Color outline = Color(0xFFDCE9E1);

  // ------------------------------------------------------------------ greens
  /// Brand green. 4.5:1 against white, so it can carry white button labels.
  static const Color green = Color(0xFF00893F);

  /// Darker end of the brand gradient.
  static const Color greenDeep = Color(0xFF006B31);

  /// Bright mid-tone used inside gradients and progress fills.
  static const Color greenBright = Color(0xFF12C063);

  /// Fresh mint for decorative highlights. 9.3:1 against [ink].
  static const Color greenMint = Color(0xFF34D399);

  /// Very light green for tinted panels.
  static const Color greenTint = Color(0xFFE8F8EE);

  // -------------------------------------------------------------------- aqua
  /// Interactive aqua. 5.4:1 against white.
  static const Color aqua = Color(0xFF0E7490);

  /// Bright cyan, the top end of the aqua gradient.
  static const Color cyan = Color(0xFF22D3EE);

  /// Teal used to bridge aqua and green.
  static const Color teal = Color(0xFF14B8A6);

  /// Very light aqua for tinted panels.
  static const Color aquaTint = Color(0xFFE4F7FA);

  // -------------------------------------------------------------------- gold
  /// Rewards and achievements.
  static const Color gold = Color(0xFFFBBF24);

  /// Bright gold for gradients.
  static const Color goldBright = Color(0xFFFACC15);

  /// Deep gold for text and icon accents on light backgrounds.
  static const Color goldDeep = Color(0xFFB4740A);

  /// Very light gold for reward tiles.
  static const Color goldTint = Color(0xFFFFF6DC);

  // ------------------------------------------------------------------- coral
  /// Challenges and important actions. 4.7:1 against white.
  static const Color coral = Color(0xFFCE4423);

  /// Bright coral/orange for gradients and decorative fills.
  static const Color coralBright = Color(0xFFFF7A59);

  /// Very light coral for tinted panels.
  static const Color coralTint = Color(0xFFFFEDE6);

  // ------------------------------------------------------------------ purple
  /// Special sections and creativity. 5.7:1 against white.
  static const Color purple = Color(0xFF7C3AED);

  /// Soft purple for gradients and decorative fills.
  static const Color purpleSoft = Color(0xFFA78BFA);

  /// Very light purple for tinted panels.
  static const Color purpleTint = Color(0xFFF1ECFE);

  // --------------------------------------------------------------- gradients
  /// Brand gradient: fresh green into mint.
  static const LinearGradient brandGradient = LinearGradient(
    colors: <Color>[greenBright, green, teal],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// Aqua gradient for interactive surfaces.
  static const LinearGradient aquaGradient = LinearGradient(
    colors: <Color>[cyan, aqua],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// Gold gradient for rewards.
  static const LinearGradient goldGradient = LinearGradient(
    colors: <Color>[goldBright, gold, coralBright],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// Coral gradient for challenges and primary calls to action.
  static const LinearGradient coralGradient = LinearGradient(
    colors: <Color>[coralBright, coral],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// Purple gradient for special sections.
  static const LinearGradient purpleGradient = LinearGradient(
    colors: <Color>[purpleSoft, purple],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// Soft backdrop wash for the app background.
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: <Color>[Color(0xFFFFFFFF), background, Color(0xFFEFF9F5)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  // --------------------------------------------------- dark-theme gradients
  /// Darkest surface, used as the dark-mode scaffold background.
  static const Color backgroundDark = Color(0xFF0C1511);

  /// Mid dark surface for nested blocks.
  static const Color surfaceDark = Color(0xFF15231C);

  /// Hairline colour on dark surfaces.
  static const Color outlineDark = Color(0xFF27392F);

  /// Dark backdrop wash.
  static const LinearGradient backgroundGradientDark = LinearGradient(
    colors: <Color>[Color(0xFF101E17), backgroundDark, Color(0xFF0A1A13)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// Brand gradient lifted for dark surfaces.
  static const LinearGradient brandGradientDark = LinearGradient(
    colors: <Color>[Color(0xFF6EE7A8), Color(0xFF3ED98A), Color(0xFF5EEAD4)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// Aqua gradient lifted for dark surfaces.
  static const LinearGradient aquaGradientDark = LinearGradient(
    colors: <Color>[Color(0xFF67E8F9), Color(0xFF3FD0EE)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// Gold gradient lifted for dark surfaces.
  static const LinearGradient goldGradientDark = LinearGradient(
    colors: <Color>[Color(0xFFFFE17A), Color(0xFFFFC53D), Color(0xFFFFA182)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// Coral gradient lifted for dark surfaces.
  static const LinearGradient coralGradientDark = LinearGradient(
    colors: <Color>[Color(0xFFFFA182), Color(0xFFFF8A65)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  /// Purple gradient lifted for dark surfaces.
  static const LinearGradient purpleGradientDark = LinearGradient(
    colors: <Color>[Color(0xFFCFC0FF), Color(0xFFB79BFF)],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );
}

/// The accent colours and gradients that Material's [ColorScheme] has no slot
/// for, exposed to widgets through [ThemeData.extensions].
///
/// Gamified pieces of the UI (streaks, rewards, challenges, creativity) need a
/// consistent colour per role. Keeping them here rather than hard-coding hex
/// values in each widget is what stops the app drifting into a random palette.
@immutable
class LumioAccents extends ThemeExtension<LumioAccents> {
  const LumioAccents({
    required this.brand,
    required this.brandBright,
    required this.brandMint,
    required this.brandTint,
    required this.aqua,
    required this.cyan,
    required this.teal,
    required this.aquaTint,
    required this.gold,
    required this.goldBright,
    required this.goldDeep,
    required this.goldTint,
    required this.coral,
    required this.coralBright,
    required this.coralTint,
    required this.purple,
    required this.purpleSoft,
    required this.purpleTint,
    required this.ink,
    required this.inkMuted,
    required this.brandGradient,
    required this.aquaGradient,
    required this.goldGradient,
    required this.coralGradient,
    required this.purpleGradient,
    required this.backgroundGradient,
  });

  final Color brand;
  final Color brandBright;
  final Color brandMint;
  final Color brandTint;
  final Color aqua;
  final Color cyan;
  final Color teal;
  final Color aquaTint;
  final Color gold;
  final Color goldBright;
  final Color goldDeep;
  final Color goldTint;
  final Color coral;
  final Color coralBright;
  final Color coralTint;
  final Color purple;
  final Color purpleSoft;
  final Color purpleTint;
  final Color ink;
  final Color inkMuted;
  final LinearGradient brandGradient;
  final LinearGradient aquaGradient;
  final LinearGradient goldGradient;
  final LinearGradient coralGradient;
  final LinearGradient purpleGradient;
  final LinearGradient backgroundGradient;

  /// The light-theme accents.
  factory LumioAccents.light() => const LumioAccents(
        brand: LumioPalette.green,
        brandBright: LumioPalette.greenBright,
        brandMint: LumioPalette.greenMint,
        brandTint: LumioPalette.greenTint,
        aqua: LumioPalette.aqua,
        cyan: LumioPalette.cyan,
        teal: LumioPalette.teal,
        aquaTint: LumioPalette.aquaTint,
        gold: LumioPalette.gold,
        goldBright: LumioPalette.goldBright,
        goldDeep: LumioPalette.goldDeep,
        goldTint: LumioPalette.goldTint,
        coral: LumioPalette.coral,
        coralBright: LumioPalette.coralBright,
        coralTint: LumioPalette.coralTint,
        purple: LumioPalette.purple,
        purpleSoft: LumioPalette.purpleSoft,
        purpleTint: LumioPalette.purpleTint,
        ink: LumioPalette.ink,
        inkMuted: LumioPalette.inkMuted,
        brandGradient: LumioPalette.brandGradient,
        aquaGradient: LumioPalette.aquaGradient,
        goldGradient: LumioPalette.goldGradient,
        coralGradient: LumioPalette.coralGradient,
        purpleGradient: LumioPalette.purpleGradient,
        backgroundGradient: LumioPalette.backgroundGradient,
      );

  /// The dark-theme accents: the same hues lifted so they stay legible on dark
  /// surfaces rather than turning muddy.
  factory LumioAccents.dark() => const LumioAccents(
        brand: Color(0xFF3ED98A),
        brandBright: Color(0xFF6EE7A8),
        brandMint: Color(0xFF7CF0BE),
        brandTint: Color(0xFF14301F),
        aqua: Color(0xFF3FD0EE),
        cyan: Color(0xFF67E8F9),
        teal: Color(0xFF5EEAD4),
        aquaTint: Color(0xFF0F2A33),
        gold: Color(0xFFFFD24D),
        goldBright: Color(0xFFFFE17A),
        goldDeep: Color(0xFFFFC53D),
        goldTint: Color(0xFF33280C),
        coral: Color(0xFFFF8A65),
        coralBright: Color(0xFFFFA182),
        coralTint: Color(0xFF3A1B12),
        purple: Color(0xFFB79BFF),
        purpleSoft: Color(0xFFCFC0FF),
        purpleTint: Color(0xFF251542),
        ink: Color(0xFFF2F8F4),
        inkMuted: Color(0xFFB6C7BE),
        brandGradient: LumioPalette.brandGradientDark,
        aquaGradient: LumioPalette.aquaGradientDark,
        goldGradient: LumioPalette.goldGradientDark,
        coralGradient: LumioPalette.coralGradientDark,
        purpleGradient: LumioPalette.purpleGradientDark,
        backgroundGradient: LumioPalette.backgroundGradientDark,
      );

  @override
  LumioAccents copyWith({
    Color? brand,
    Color? brandBright,
    Color? brandMint,
    Color? brandTint,
    Color? aqua,
    Color? cyan,
    Color? teal,
    Color? aquaTint,
    Color? gold,
    Color? goldBright,
    Color? goldDeep,
    Color? goldTint,
    Color? coral,
    Color? coralBright,
    Color? coralTint,
    Color? purple,
    Color? purpleSoft,
    Color? purpleTint,
    Color? ink,
    Color? inkMuted,
    LinearGradient? brandGradient,
    LinearGradient? aquaGradient,
    LinearGradient? goldGradient,
    LinearGradient? coralGradient,
    LinearGradient? purpleGradient,
    LinearGradient? backgroundGradient,
  }) {
    return LumioAccents(
      brand: brand ?? this.brand,
      brandBright: brandBright ?? this.brandBright,
      brandMint: brandMint ?? this.brandMint,
      brandTint: brandTint ?? this.brandTint,
      aqua: aqua ?? this.aqua,
      cyan: cyan ?? this.cyan,
      teal: teal ?? this.teal,
      aquaTint: aquaTint ?? this.aquaTint,
      gold: gold ?? this.gold,
      goldBright: goldBright ?? this.goldBright,
      goldDeep: goldDeep ?? this.goldDeep,
      goldTint: goldTint ?? this.goldTint,
      coral: coral ?? this.coral,
      coralBright: coralBright ?? this.coralBright,
      coralTint: coralTint ?? this.coralTint,
      purple: purple ?? this.purple,
      purpleSoft: purpleSoft ?? this.purpleSoft,
      purpleTint: purpleTint ?? this.purpleTint,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      brandGradient: brandGradient ?? this.brandGradient,
      aquaGradient: aquaGradient ?? this.aquaGradient,
      goldGradient: goldGradient ?? this.goldGradient,
      coralGradient: coralGradient ?? this.coralGradient,
      purpleGradient: purpleGradient ?? this.purpleGradient,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
    );
  }

  @override
  LumioAccents lerp(LumioAccents? other, double t) {
    if (other == null) return this;
    Color blend(Color a, Color b) => Color.lerp(a, b, t)!;
    LinearGradient blendGradient(LinearGradient a, LinearGradient b) =>
        LinearGradient.lerp(a, b, t)!;
    return LumioAccents(
      brand: blend(brand, other.brand),
      brandBright: blend(brandBright, other.brandBright),
      brandMint: blend(brandMint, other.brandMint),
      brandTint: blend(brandTint, other.brandTint),
      aqua: blend(aqua, other.aqua),
      cyan: blend(cyan, other.cyan),
      teal: blend(teal, other.teal),
      aquaTint: blend(aquaTint, other.aquaTint),
      gold: blend(gold, other.gold),
      goldBright: blend(goldBright, other.goldBright),
      goldDeep: blend(goldDeep, other.goldDeep),
      goldTint: blend(goldTint, other.goldTint),
      coral: blend(coral, other.coral),
      coralBright: blend(coralBright, other.coralBright),
      coralTint: blend(coralTint, other.coralTint),
      purple: blend(purple, other.purple),
      purpleSoft: blend(purpleSoft, other.purpleSoft),
      purpleTint: blend(purpleTint, other.purpleTint),
      ink: blend(ink, other.ink),
      inkMuted: blend(inkMuted, other.inkMuted),
      brandGradient: blendGradient(brandGradient, other.brandGradient),
      aquaGradient: blendGradient(aquaGradient, other.aquaGradient),
      goldGradient: blendGradient(goldGradient, other.goldGradient),
      coralGradient: blendGradient(coralGradient, other.coralGradient),
      purpleGradient: blendGradient(purpleGradient, other.purpleGradient),
      backgroundGradient:
          blendGradient(backgroundGradient, other.backgroundGradient),
    );
  }
}

/// Convenience accessor for [LumioAccents].
///
/// ```dart
/// context.lumio.coral
/// ```
extension LumioAccentsContext on BuildContext {
  LumioAccents get lumio =>
      Theme.of(this).extension<LumioAccents>() ?? LumioAccents.light();
}