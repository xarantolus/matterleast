import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

/// The colours of a Mattermost theme preference the app uses.
class MattermostTheme {
  const MattermostTheme({
    required this.sidebarHeaderBg,
    required this.sidebarHeaderTextColor,
    required this.centerChannelBg,
    required this.centerChannelColor,
    required this.buttonBg,
    required this.buttonColor,
  });

  static const denim = MattermostTheme(
    sidebarHeaderBg: Color(0xFF192A4D),
    sidebarHeaderTextColor: Color(0xFFFFFFFF),
    centerChannelBg: Color(0xFFFFFFFF),
    centerChannelColor: Color(0xFF3F4350),
    buttonBg: Color(0xFF1C58D9),
    buttonColor: Color(0xFFFFFFFF),
  );

  static const onyx = MattermostTheme(
    sidebarHeaderBg: Color(0xFF24272D),
    sidebarHeaderTextColor: Color(0xFFFFFFFF),
    centerChannelBg: Color(0xFF191B1F),
    centerChannelColor: Color(0xFFE3E4E8),
    buttonBg: Color(0xFF4A7CE8),
    buttonColor: Color(0xFFFFFFFF),
  );

  /// Reads a stored theme preference; missing or unreadable colours come
  /// from Denim. Null when [raw] is not a JSON object.
  static MattermostTheme? parse(String? raw) {
    if (raw == null) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, Object?>) return null;
    final json = decoded;
    Color pick(String key, Color fallback) =>
        parseCssColor(json[key]) ?? fallback;
    const d = denim;
    return MattermostTheme(
      sidebarHeaderBg: pick('sidebarHeaderBg', d.sidebarHeaderBg),
      sidebarHeaderTextColor: pick(
        'sidebarHeaderTextColor',
        d.sidebarHeaderTextColor,
      ),
      centerChannelBg: pick('centerChannelBg', d.centerChannelBg),
      centerChannelColor: pick('centerChannelColor', d.centerChannelColor),
      buttonBg: pick('buttonBg', d.buttonBg),
      buttonColor: pick('buttonColor', d.buttonColor),
    );
  }

  final Color sidebarHeaderBg;
  final Color sidebarHeaderTextColor;
  final Color centerChannelBg;
  final Color centerChannelColor;
  final Color buttonBg;
  final Color buttonColor;
}

/// The theme for a team: its own preference, else any theme the user saved,
/// else Denim or Onyx to match the phone. [themes] maps preference names
/// (team ids, or empty) to stored values.
MattermostTheme themeForTeam(
  Map<String, String> themes,
  String? teamId, {
  required bool dark,
}) {
  final raw = themes[teamId] ?? themes[''] ?? themes.values.firstOrNull;
  return MattermostTheme.parse(raw) ??
      (dark ? MattermostTheme.onyx : MattermostTheme.denim);
}

/// `#rgb`, `#rrggbb` or `rgb(r,g,b)`/`rgba(...)` as Mattermost stores them.
Color? parseCssColor(Object? value) {
  if (value is! String) return null;
  final text = value.trim().toLowerCase();
  final hex = RegExp(r'^#([0-9a-f]{3}|[0-9a-f]{6})$').firstMatch(text);
  if (hex != null) {
    var digits = hex.group(1)!;
    if (digits.length == 3) {
      digits = digits.split('').map((c) => '$c$c').join();
    }
    return Color(0xFF000000 | int.parse(digits, radix: 16));
  }
  final rgb = RegExp(r'^rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)')
      .firstMatch(text);
  if (rgb != null) {
    int channel(int i) => int.parse(rgb.group(i)!).clamp(0, 255);
    return Color.fromARGB(255, channel(1), channel(2), channel(3));
  }
  return null;
}

/// WCAG contrast ratio of two opaque colours.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

const minContrast = 4.5;

/// [preferred] when it reads on [background], else black or white,
/// whichever reads better.
Color readableOn(Color background, Color preferred) {
  if (contrastRatio(preferred, background) >= minContrast) return preferred;
  const white = Color(0xFFFFFFFF);
  const black = Color(0xFF000000);
  return contrastRatio(white, background) >= contrastRatio(black, background)
      ? white
      : black;
}

/// [colour] moved towards black or white, keeping its hue, until it reads
/// on [background].
Color adjustToRead(Color colour, Color background) {
  if (contrastRatio(colour, background) >= minContrast) return colour;
  final target = background.computeLuminance() > 0.5
      ? const Color(0xFF000000)
      : const Color(0xFFFFFFFF);
  for (var t = 0.05; t < 1; t += 0.05) {
    final moved = Color.lerp(colour, target, t)!;
    if (contrastRatio(moved, background) >= minContrast) return moved;
  }
  return target;
}

/// The colours the app takes from a Mattermost theme, each pair readable.
class ServerPalette {
  factory ServerPalette.of(MattermostTheme theme) {
    final dark = theme.centerChannelBg.computeLuminance() < 0.2;
    final page = theme.centerChannelBg;
    return ServerPalette._(
      dark: dark,
      bar: theme.sidebarHeaderBg,
      onBar: readableOn(theme.sidebarHeaderBg, theme.sidebarHeaderTextColor),
      primary: theme.buttonBg,
      onPrimary: readableOn(theme.buttonBg, theme.buttonColor),
      page: page,
      text: readableOn(page, theme.centerChannelColor),
      accent: adjustToRead(theme.buttonBg, page),
    );
  }

  const ServerPalette._({
    required this.dark,
    required this.bar,
    required this.onBar,
    required this.primary,
    required this.onPrimary,
    required this.page,
    required this.text,
    required this.accent,
  });

  final bool dark;
  final Color bar;
  final Color onBar;
  final Color primary;
  final Color onPrimary;
  final Color page;
  final Color text;

  /// [primary] made readable as text on [page].
  final Color accent;

  @override
  bool operator ==(Object other) =>
      other is ServerPalette &&
      other.dark == dark &&
      other.bar == bar &&
      other.onBar == onBar &&
      other.primary == primary &&
      other.onPrimary == onPrimary &&
      other.page == page &&
      other.text == text &&
      other.accent == accent;

  @override
  int get hashCode =>
      Object.hash(dark, bar, onBar, primary, onPrimary, page, text, accent);
}
