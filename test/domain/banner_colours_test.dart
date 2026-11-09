import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/server_theme.dart';

const _bg = Color(0xFF1C1C1C);
const _fg = Color(0xFFFFFFFF);

({Color background, Color foreground}) colours(String? bg, String? fg) =>
    bannerColours(bg, fg, fallbackBg: _bg, fallbackFg: _fg);

void main() {
  test("the server's colours are used when they read", () {
    final c = colours('#f2a52b', '#000000');
    expect(c.background, const Color(0xFFF2A52B));
    expect(c.foreground, const Color(0xFF000000));
  });

  test('missing or broken colours fall back to the theme', () {
    expect(colours(null, null).background, _bg);
    expect(colours('orange', 'blue').background, _bg);
    expect(colours('#12345', null).foreground, _fg);
  });

  test('a text colour that does not read is replaced by black or white', () {
    final c = colours('#ffff00', '#ffffaa');
    expect(c.background, const Color(0xFFFFFF00));
    expect(c.foreground, const Color(0xFF000000));
  });

  test('a missing text colour is chosen to read on the background', () {
    expect(colours('#fff', null).foreground, const Color(0xFF000000));
  });

  test('every pair reads at 4.5:1', () {
    for (final bg in ['#ffffff', '#000000', '#808080', '#f2a52b', '#1c58d9']) {
      for (final fg in [null, '#ffffff', '#000000', '#7f7f7f']) {
        final c = colours(bg, fg);
        expect(
          contrastRatio(c.foreground, c.background),
          greaterThanOrEqualTo(minContrast),
          reason: '$fg on $bg',
        );
      }
    }
  });
}
