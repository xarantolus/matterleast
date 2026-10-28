import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/app/theme_providers.dart';
import 'package:matterleast/app/wallpaper_colours.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/server_theme.dart';
import 'package:matterleast/screens/settings/settings_providers.dart';
import 'package:matterleast/ui/page_tabs.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/window_strip.dart';

/// Mattermost's built-in themes as the server stores them.
const _presets = {
  'Denim': {
    'sidebarHeaderBg': '#192a4d',
    'sidebarHeaderTextColor': '#ffffff',
    'centerChannelBg': '#ffffff',
    'centerChannelColor': '#3f4350',
    'buttonBg': '#1c58d9',
    'buttonColor': '#ffffff',
  },
  'Sapphire': {
    'sidebarHeaderBg': '#123b91',
    'sidebarHeaderTextColor': '#ffffff',
    'centerChannelBg': '#ffffff',
    'centerChannelColor': '#3f4350',
    'buttonBg': '#1c58d9',
    'buttonColor': '#ffffff',
  },
  'Quartz': {
    'sidebarHeaderBg': '#ebecef',
    'sidebarHeaderTextColor': '#1f2228',
    'centerChannelBg': '#ffffff',
    'centerChannelColor': '#3f4350',
    'buttonBg': '#1c58d9',
    'buttonColor': '#ffffff',
  },
  'Indigo': {
    'sidebarHeaderBg': '#182339',
    'sidebarHeaderTextColor': '#ffffff',
    'centerChannelBg': '#111827',
    'centerChannelColor': '#dddfe4',
    'buttonBg': '#4a7ce8',
    'buttonColor': '#ffffff',
  },
  'Onyx': {
    'sidebarHeaderBg': '#24272d',
    'sidebarHeaderTextColor': '#ffffff',
    'centerChannelBg': '#191b1f',
    'centerChannelColor': '#e3e4e8',
    'buttonBg': '#4a7ce8',
    'buttonColor': '#ffffff',
  },
  // Invented custom themes that break one rule each.
  'mid-grey page with white text': {
    'sidebarHeaderBg': '#8a8a8a',
    'sidebarHeaderTextColor': '#ffffff',
    'centerChannelBg': '#8a8a8a',
    'centerChannelColor': '#ffffff',
    'buttonBg': '#9a9a9a',
    'buttonColor': '#ffffff',
  },
  'pale accents on a dark page': {
    'sidebarHeaderBg': '#e0e0ff',
    'sidebarHeaderTextColor': '#ffffff',
    'centerChannelBg': '#2b2b40',
    'centerChannelColor': '#3a3a55',
    'buttonBg': '#ffd1dc',
    'buttonColor': '#ffffff',
  },
  'neon on black': {
    'sidebarHeaderBg': '#ff00ff',
    'sidebarHeaderTextColor': '#00ff00',
    'centerChannelBg': '#000000',
    'centerChannelColor': '#00ff00',
    'buttonBg': '#0000ff',
    'buttonColor': '#000000',
  },
  'washed out on white': {
    'sidebarHeaderBg': '#ffffff',
    'sidebarHeaderTextColor': '#eeeeee',
    'centerChannelBg': '#ffffff',
    'centerChannelColor': '#eeeeee',
    'buttonBg': '#ffff00',
    'buttonColor': '#ffffff',
  },
};

ServerPalette _palette(Map<String, String> colours) =>
    ServerPalette.of(MattermostTheme.parse(jsonEncode(colours))!);

/// Every theme the app can show: the brand, each server theme and
/// wallpaper colours from a few seeds, in light and dark.
Map<String, ThemeData> _allThemes() {
  final recorded = jsonDecode(
    File('test/fixtures/api/theme_preferences.json').readAsStringSync(),
  ) as List<Object?>;
  final stored = {
    for (final p in recorded)
      if (p case {'name': final String name, 'value': final String value})
        name: value,
  };
  const seeds = {
    'violet': Color(0xFF6750A4),
    'pale yellow': Color(0xFFF2C94C),
    'bright green': Color(0xFF00E676),
    'red': Color(0xFFB3261E),
    'grey': Color(0xFF8A8A8A),
  };
  return {
    'brand light': MatterleastApp.lightTheme,
    'brand dark': MatterleastApp.darkTheme,
    for (final MapEntry(:key, :value) in _presets.entries)
      'server $key': buildServerTheme(_palette(value)),
    'server recorded yellow': buildServerTheme(
      ServerPalette.of(
        themeForTeam(stored, 'tm000000000000000000000t01', dark: false),
      ),
    ),
    for (final MapEntry(:key, :value) in seeds.entries)
      for (final brightness in Brightness.values)
        'wallpaper $key ${brightness.name}': buildWallpaperTheme(
          WallpaperColours.fromSeed(value),
          brightness,
        ),
  };
}

/// The pairs Material and the app draw small text with, beyond the tokens.
Map<String, (Color, Color)> _schemePairs(ThemeData theme) {
  final s = theme.colorScheme;
  final t = theme.extension<AppTokens>()!;
  final strip = windowStripColours(theme);
  return {
    'app bar text on the bar': (
      theme.appBarTheme.foregroundColor!,
      theme.appBarTheme.backgroundColor!,
    ),
    'button text on primary': (s.onPrimary, s.primary),
    'primary as text on the page (focused field label)': (s.primary, t.page),
    'primary as text on a panel': (s.primary, t.panel),
    'error on the page (New messages, field errors)': (s.error, t.page),
    'URGENT label on error': (s.onError, s.error),
    'text on a menu': (s.onSurface, s.surfaceContainer),
    'text on a sheet': (s.onSurface, s.surfaceContainerLow),
    'muted on a sheet': (s.onSurfaceVariant, s.surfaceContainerLow),
    'text on a dialog': (s.onSurface, s.surfaceContainerHigh),
    'muted on a dialog': (s.onSurfaceVariant, s.surfaceContainerHigh),
    'text on the highest container': (s.onSurface, s.surfaceContainerHighest),
    'tonal button text': (s.onSecondaryContainer, s.secondaryContainer),
    'primary container text': (s.onPrimaryContainer, s.primaryContainer),
    'snack bar text': (s.onInverseSurface, s.inverseSurface),
    'text on the highlighted row': (t.text, t.accentWash),
    'muted on the highlighted row': (t.muted, t.accentWash),
    'desktop window strip text': (strip.text, strip.fill),
    'close button under the pointer': (Colors.white, closeHoverColour),
  };
}

void main() {
  final themes = _allThemes();

  for (final MapEntry(key: name, value: theme) in themes.entries) {
    test('every small-text pair clears 4.5:1 in $name', () {
      final tokens = theme.extension<AppTokens>()!;
      final pairs = {...tokens.textPairs, ..._schemePairs(theme)};
      for (final MapEntry(:key, value: (fg, bg)) in pairs.entries) {
        expect(
          contrast(fg, bg),
          greaterThanOrEqualTo(4.5),
          reason: '$key: $fg on $bg',
        );
      }
    });
  }

  for (final MapEntry(key: name, value: theme) in themes.entries) {
    test('the desktop window strip is darker than the app bar in $name', () {
      final bar = theme.appBarTheme.backgroundColor!;
      expect(
        windowStripColours(theme).fill.computeLuminance(),
        lessThan(bar.computeLuminance()),
      );
    });
  }

  for (final name in [
    'brand light',
    'brand dark',
    'server Denim',
    'server Quartz',
    'server Onyx',
    'server recorded yellow',
    'server washed out on white',
    'wallpaper violet light',
    'wallpaper pale yellow dark',
  ]) {
    testWidgets('app bar actions read on the bar in $name, Save even when '
        'disabled', (tester) async {
      final theme = themes[name]!;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(
                leading: const BackButton(),
                title: const Text('Edit profile'),
                actions: [
                  SearchAnchor(
                    builder: (_, _) => IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                    ),
                    suggestionsBuilder: (_, _) => const [],
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
                  TextButton(
                    style: context.barButtonStyle,
                    onPressed: () {},
                    child: const Text('Create'),
                  ),
                  TextButton(
                    style: context.barButtonStyle,
                    onPressed: null,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      final bar = theme.appBarTheme.backgroundColor!;
      Color drawn(Finder finder) => drawnColour(tester, finder);
      for (final finder in [
        find.byIcon(Icons.search),
        find.byIcon(Icons.add),
        find.byIcon(Icons.arrow_back),
        find.text('Edit profile'),
        find.text('Create'),
      ]) {
        expect(
          contrast(drawn(finder), bar),
          greaterThanOrEqualTo(4.5),
          reason: '$finder',
        );
      }
      final disabled = Color.alphaBlend(drawn(find.text('Save')), bar);
      expect(contrast(disabled, bar), greaterThanOrEqualTo(3));
      expect(
        contrast(disabled, bar),
        lessThan(contrast(drawn(find.text('Create')), bar)),
        reason: 'a disabled action looks different from an enabled one',
      );
    });
  }

  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('tabs at the top of a page read on the page in $name', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(title: const Text('Threads')),
              body: const PageTabs(
                tabs: [
                  Tab(text: 'All'),
                  Tab(text: 'Unread'),
                ],
              ),
            ),
          ),
        ),
      );
      final page = theme.scaffoldBackgroundColor;
      for (final label in ['All', 'Unread']) {
        final drawn = Color.alphaBlend(
          drawnColour(tester, find.text(label)),
          page,
        );
        expect(contrast(drawn, page), greaterThanOrEqualTo(4.5), reason: label);
      }
    });
  }

  for (final name in [
    'brand dark',
    'server recorded yellow',
    'server pale accents on a dark page',
    'wallpaper bright green light',
  ]) {
    testWidgets('a focused field and a filled button read in $name', (
      tester,
    ) async {
      final theme = themes[name]!;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Column(
              children: [
                const TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Purpose',
                    border: OutlineInputBorder(),
                  ),
                ),
                FilledButton(onPressed: () {}, child: const Text('Send')),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        contrast(
          drawnColour(tester, find.text('Purpose')),
          theme.scaffoldBackgroundColor,
        ),
        greaterThanOrEqualTo(4.5),
        reason: 'the floating label of a focused field',
      );
      final fill = tester
          .widget<Material>(
            find.descendant(
              of: find.byType(FilledButton),
              matching: find.byType(Material),
            ),
          )
          .color!;
      expect(
        contrast(drawnColour(tester, find.text('Send')), fill),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(fill, theme.scaffoldBackgroundColor),
        greaterThanOrEqualTo(3),
      );
    });
  }

  for (final MapEntry(key: name, value: theme) in themes.entries) {
    testWidgets('selected chips read and disabled controls stay visible in '
        '$name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Column(
              children: [
                FilterChip(
                  selected: true,
                  label: const Text('Unread'),
                  onSelected: (_) {},
                ),
                FilterChip(
                  selected: true,
                  showCheckmark: false,
                  selectedColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  label: const Text('Mine'),
                  onSelected: (_) {},
                ),
                const TextButton(onPressed: null, child: Text('Off')),
                const IconButton(onPressed: null, icon: Icon(Icons.send)),
              ],
            ),
          ),
        ),
      );
      Color chipFill(String label) {
        final chip = tester.widget<FilterChip>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(FilterChip),
          ),
        );
        return chip.selectedColor ??
            theme.chipTheme.selectedColor ??
            theme.colorScheme.secondaryContainer;
      }

      final page = theme.scaffoldBackgroundColor;
      for (final label in ['Unread', 'Mine']) {
        final fill = Color.alphaBlend(chipFill(label), page);
        expect(
          contrast(
            Color.alphaBlend(drawnColour(tester, find.text(label)), fill),
            fill,
          ),
          greaterThanOrEqualTo(4.5),
          reason: 'selected chip $label',
        );
      }
      // Disabled controls are exempt from 4.5:1 but must still be seen.
      final off = Color.alphaBlend(drawnColour(tester, find.text('Off')), page);
      expect(contrast(off, page), greaterThanOrEqualTo(1.8), reason: 'Off');
      final icon = tester.widget<IconTheme>(
        find
            .ancestor(
              of: find.byIcon(Icons.send),
              matching: find.byType(IconTheme),
            )
            .first,
      );
      final send = Color.alphaBlend(icon.data.color!, page);
      expect(contrast(send, page), greaterThanOrEqualTo(1.8), reason: 'Send');
    });
  }

  test('presence dots stand out from the page (3:1)', () {
    for (final MapEntry(key: name, value: theme) in themes.entries) {
      final t = theme.extension<AppTokens>()!;
      for (final (label, dot) in [
        ('online', t.online),
        ('away', t.away),
        ('busy', t.busy),
      ]) {
        expect(
          contrast(dot, t.page),
          greaterThanOrEqualTo(3),
          reason: '$label in $name',
        );
      }
    }
  });

  group('server theme', () {
    test('a pale header gets dark text and a pale button colour darkens '
        'until it reads on the page', () {
      final theme = themes['server recorded yellow']!;
      expect(theme.brightness, Brightness.light);
      expect(theme.appBarTheme.backgroundColor, const Color(0xFFF2C94C));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFFFFDF7));
      expect(theme.appBarTheme.foregroundColor, isNot(Colors.white));
      const pale = Color(0xFF7FB3FF);
      final primary = theme.colorScheme.primary;
      expect(primary.computeLuminance(), lessThan(pale.computeLuminance()));
      expect(primary.b, greaterThan(primary.r), reason: 'still blue');
    });

    test('a theme that already reads keeps its colours', () {
      final denim = themes['server Denim']!;
      expect(denim.appBarTheme.backgroundColor, const Color(0xFF192A4D));
      expect(denim.appBarTheme.foregroundColor, Colors.white);
      expect(denim.colorScheme.primary, const Color(0xFF1C58D9));
      expect(denim.colorScheme.onPrimary, Colors.white);
    });

    test('sheets and menus take the page colour, not the button hue', () {
      final theme = themes['server recorded yellow']!;
      final page = theme.scaffoldBackgroundColor;
      final sheet = theme.colorScheme.surfaceContainerLow;
      expect(contrast(sheet, page), lessThan(1.1));
      // Yellowish like the page, not blue like the buttons.
      expect(sheet.r, greaterThan(sheet.b));
    });

    test('Indigo and Onyx are dark, Denim, Sapphire and Quartz light', () {
      for (final dark in ['Indigo', 'Onyx']) {
        expect(themes['server $dark']!.brightness, Brightness.dark);
      }
      for (final light in ['Denim', 'Sapphire', 'Quartz']) {
        expect(themes['server $light']!.brightness, Brightness.light);
      }
    });

    test('no saved theme falls back to Denim, or Onyx in dark mode', () {
      expect(
        ServerPalette.of(themeForTeam(const {}, null, dark: false)),
        _palette(_presets['Denim']!),
      );
      expect(
        ServerPalette.of(themeForTeam(const {}, null, dark: true)),
        _palette(_presets['Onyx']!),
      );
    });
  });

  group('wallpaper colours', () {
    test('Android\'s tones become the scheme, tone 40 the light primary', () {
      final colours = WallpaperColours.fromSeed(const Color(0xFF6750A4));
      expect(colours.tones, hasLength(65));
      final light = buildWallpaperTheme(colours, Brightness.light);
      expect(light.colorScheme.primary, Color(colours.tones[4]));
      expect(light.appBarTheme.backgroundColor, Color(colours.tones[4]));
      expect(
        light.colorScheme.primary,
        isNot(MatterleastApp.lightTheme.colorScheme.primary),
      );
      expect(
        buildWallpaperTheme(colours, Brightness.dark).brightness,
        Brightness.dark,
      );
      expect(() => WallpaperColours([1, 2, 3]), throwsFormatException);
    });

    Future<AppThemes?> themesFor(
      ThemeSource source,
      WallpaperColours? wallpaper,
    ) async {
      const url = 'https://chat.example.test';
      final container = ProviderContainer(
        overrides: [
          settingsServerProvider.overrideWithValue(
            const ServerEntry(
              url: url,
              displayName: 'Example',
              siteName: null,
              serverVersion: null,
              diagnosticId: null,
              lastActiveAt: null,
              ssoScheme: null,
            ),
          ),
          themeModeProvider(url).overrideWith((ref) => Stream.value(source)),
          wallpaperPaletteProvider.overrideWith(
            () => _FixedWallpaper(wallpaper),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(appThemesProvider, (_, _) {});
      return container.read(appThemesProvider.future);
    }

    test('the wallpaper theme follows the wallpaper', () async {
      final colours = WallpaperColours.fromSeed(const Color(0xFFB3261E));
      final themes = await themesFor(ThemeSource.wallpaper, colours);
      expect(
        themes?.light.colorScheme.primary,
        colours.scheme(Brightness.light).primary,
      );
      expect(
        themes?.dark.colorScheme.primary,
        colours.scheme(Brightness.dark).primary,
      );
    });

    test('a phone without wallpaper colours keeps the brand', () async {
      expect(await themesFor(ThemeSource.wallpaper, null), isNull);
      expect(
        await themesFor(
          ThemeSource.brand,
          WallpaperColours.fromSeed(const Color(0xFFB3261E)),
        ),
        isNull,
      );
    });
  });

  test('pages use the predictive back transition on Android', () {
    for (final theme in themes.values) {
      expect(
        theme.pageTransitionsTheme.builders[TargetPlatform.android],
        isA<PredictiveBackPageTransitionsBuilder>(),
      );
    }
  });
}

class _FixedWallpaper extends WallpaperPalette {
  _FixedWallpaper(this.colours);

  final WallpaperColours? colours;

  @override
  Future<WallpaperColours?> build() async => colours;
}

/// The colour the text or icon under [finder] is painted in.
Color drawnColour(WidgetTester tester, Finder finder) => tester
    .widget<RichText>(
      find.descendant(
        of: finder,
        matching: find.byType(RichText),
        matchRoot: true,
      ),
    )
    .text
    .style!
    .color!;

/// WCAG relative contrast between two opaque colours.
double contrast(Color a, Color b) {
  final high = max(a.computeLuminance(), b.computeLuminance());
  final low = min(a.computeLuminance(), b.computeLuminance());
  return (high + 0.05) / (low + 0.05);
}
