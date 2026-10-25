import 'package:material_ui/material_ui.dart';

abstract final class Spacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Colours and text styles used on surfaces. [accent] is for text and icons
/// drawn *on* a surface; the theme's `primary` is a fill that white sits on.
/// Each pair in [textPairs] is checked for 4.5:1 contrast in the theme test.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.page,
    required this.text,
    required this.muted,
    required this.hairline,
    required this.divider,
    required this.accent,
    required this.accentWash,
    required this.codeBackground,
    required this.panel,
    required this.unread,
    required this.online,
    required this.away,
    required this.busy,
  });

  final Color page;
  final Color text;
  final Color muted;
  final Color hairline;
  final Color divider;
  final Color accent;
  final Color accentWash;
  final Color codeBackground;

  /// Tonal fill of a tappable bar or card sitting on the page.
  final Color panel;

  /// Dot and bold text of an unread channel.
  final Color unread;

  /// Presence dots.
  final Color online;
  final Color away;
  final Color busy;

  static const light = AppTokens(
    page: Color(0xFFF8FAF9),
    text: Color(0xFF191C1B),
    muted: Color(0xFF585F5D),
    hairline: Color(0xFFD6DBD9),
    divider: Color(0xFFA9B1AE),
    accent: Color(0xFF00695C),
    accentWash: Color(0xFFD9F1EC),
    codeBackground: Color(0xFFEDF1EF),
    panel: Color(0xFFE3E9E6),
    unread: Color(0xFF191C1B),
    online: Color(0xFF2E7D32),
    away: Color(0xFFB26A00),
    busy: Color(0xFFC62828),
  );

  static const dark = AppTokens(
    page: Color(0xFF131514),
    text: Color(0xFFE6EAE8),
    muted: Color(0xFFA5ADAA),
    hairline: Color(0xFF323735),
    divider: Color(0xFF5F6764),
    accent: Color(0xFF5FD3C4),
    accentWash: Color(0xFF17332F),
    codeBackground: Color(0xFF1D201F),
    panel: Color(0xFF262B29),
    unread: Color(0xFFE6EAE8),
    online: Color(0xFF66BB6A),
    away: Color(0xFFFFB74D),
    busy: Color(0xFFEF5350),
  );

  /// Every foreground/background pair that carries small text.
  Map<String, (Color, Color)> get textPairs => {
    'text on page': (text, page),
    'muted on page': (muted, page),
    'accent on page': (accent, page),
    'accent on wash': (accent, accentWash),
    'text on code': (text, codeBackground),
    'muted on code': (muted, codeBackground),
    'accent on panel': (accent, panel),
    'muted on panel': (muted, panel),
    'page on muted (muted mention count)': (page, muted),
  };

  TextStyle get smallCaps => TextStyle(
    fontSize: 11.5,
    height: 1.3,
    letterSpacing: 1.1,
    fontWeight: FontWeight.w600,
    color: muted,
  );

  @override
  AppTokens copyWith({
    Color? page,
    Color? text,
    Color? muted,
    Color? hairline,
    Color? divider,
    Color? accent,
    Color? accentWash,
    Color? codeBackground,
    Color? panel,
    Color? unread,
    Color? online,
    Color? away,
    Color? busy,
  }) {
    return AppTokens(
      page: page ?? this.page,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      hairline: hairline ?? this.hairline,
      divider: divider ?? this.divider,
      accent: accent ?? this.accent,
      accentWash: accentWash ?? this.accentWash,
      codeBackground: codeBackground ?? this.codeBackground,
      panel: panel ?? this.panel,
      unread: unread ?? this.unread,
      online: online ?? this.online,
      away: away ?? this.away,
      busy: busy ?? this.busy,
    );
  }

  @override
  AppTokens lerp(AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      page: Color.lerp(page, other.page, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentWash: Color.lerp(accentWash, other.accentWash, t)!,
      codeBackground: Color.lerp(codeBackground, other.codeBackground, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      unread: Color.lerp(unread, other.unread, t)!,
      online: Color.lerp(online, other.online, t)!,
      away: Color.lerp(away, other.away, t)!,
      busy: Color.lerp(busy, other.busy, t)!,
    );
  }
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
