import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/desktop_window.dart';

void main() {
  group('closing the window', () {
    test('hides it to the tray when there is one', () {
      expect(closeAction(closeToTray: true, hasTray: true), CloseAction.hide);
    });

    test('only minimises it without a tray, so it stays reachable', () {
      expect(
        closeAction(closeToTray: true, hasTray: false),
        CloseAction.minimize,
      );
    });

    test('quits when the user switched close to tray off', () {
      expect(closeAction(closeToTray: false, hasTray: true), CloseAction.quit);
      expect(closeAction(closeToTray: false, hasTray: false), CloseAction.quit);
    });

    test('goes to the tray unless the user changes it', () {
      expect(Settings.closeToTray.read(const {}), isTrue);
    });
  });

  group('the window placement', () {
    const placement = WindowPlacement(
      x: 120,
      y: 80,
      width: 1100,
      height: 700,
      maximized: true,
    );

    test('comes back as it was saved', () {
      final stored = {
        Settings.windowPlacement.key: Settings.windowPlacement.encode(
          placement,
        ),
      };
      expect(Settings.windowPlacement.read(stored), placement);
    });

    test('is unknown before the first move and after a broken save', () {
      expect(Settings.windowPlacement.read(const {}), isNull);
      expect(
        Settings.windowPlacement.read({
          Settings.windowPlacement.key: '{"width": "wide"}',
        }),
        isNull,
      );
    });

    const screen = Rect.fromLTWH(0, 0, 1920, 1080);

    test('keeps its place on a display that is still there', () {
      expect(placementOnScreen(placement, [screen]), placement);
    });

    test('centres when its display is gone', () {
      final moved = placementOnScreen(placement.copyWith(x: 2200, y: 100), [
        screen,
      ]);
      expect((moved.x, moved.y), (null, null));
      expect((moved.width, moved.height), (1100, 700));
    });

    test(
      'is never smaller than the wide layout or larger than the display',
      () {
        final small = placementOnScreen(
          const WindowPlacement(x: 0, y: 0, width: 400, height: 300),
          [screen],
        );
        expect((small.width, small.height), (940, 500));
        final large = placementOnScreen(
          const WindowPlacement(x: 0, y: 0, width: 4000, height: 3000),
          [screen],
        );
        expect((large.width, large.height), (1920, 1080));
      },
    );

    test('remembers the bounds from before maximising', () {
      const normal = WindowPlacement(x: 120, y: 80, width: 1100, height: 700);
      final maximised = placementAfterChange(
        normal,
        bounds: screen,
        maximized: true,
      );
      expect(maximised, normal.copyWith(maximized: true));
      expect(
        placementAfterChange(
          maximised,
          bounds: const Rect.fromLTWH(10, 20, 1000, 600),
          maximized: false,
        ),
        const WindowPlacement(x: 10, y: 20, width: 1000, height: 600),
      );
    });
  });

  group('the window title', () {
    test('names the conversation, its team and the unread count', () {
      expect(
        windowTitle(
          conversation: 'Town Square',
          team: 'Lighthouse Crew',
          unread: 3,
        ),
        '(3) Town Square · Lighthouse Crew – Matterleast',
      );
    });

    test('leaves out what there is none of', () {
      expect(windowTitle(), 'Matterleast');
      expect(windowTitle(unread: 0), 'Matterleast');
      expect(windowTitle(unread: 12), '(12) Matterleast');
      expect(
        windowTitle(conversation: 'Town Square', unread: 0),
        'Town Square – Matterleast',
      );
      expect(
        windowTitle(conversation: 'alice', team: ''),
        'alice – Matterleast',
      );
    });
  });
}
