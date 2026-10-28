import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:matterleast/app/desktop/launcher_badge.dart';
import 'package:matterleast/app/desktop/taskbar.dart';
import 'package:matterleast/app/desktop/tray_host.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/desktop_window.dart';
import 'package:matterleast/domain/unread_badge.dart';
import 'package:matterleast/log.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:tray_manager/tray_manager.dart' as tray;
import 'package:window_manager/window_manager.dart';

/// Whether the user is looking at the app: it is on screen and, on a
/// desktop, its window has the focus.
bool appInFront() =>
    WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
    (!isDesktop || DesktopShell.focus.value);

/// The presences the tray menu sets, with their labels.
const trayStatuses = [
  ('online', 'Online'),
  ('away', 'Away'),
  ('dnd', 'Do not disturb'),
  ('offline', 'Offline'),
];

/// The desktop window and its tray icon. The window opens where it was
/// left; closing it hides it to the tray, or quits where there is no tray; the tray's menu brings it back or quits.
class DesktopShell with WindowListener {
  DesktopShell._(this._settings, this._host, this._placement, this._setStatus);

  final SettingsStore _settings;
  final Future<void> Function(String status) _setStatus;
  final TrayHost _host;
  final _launcher = LauncherBadge();
  WindowPlacement? _placement;
  var _closeToTray = Settings.closeToTray.defaultValue;
  StreamSubscription<bool>? _closeSetting;
  StreamSubscription<bool>? _hostChanges;
  Timer? _saveSoon;
  int? _unread;

  // Held for as long as the icon shows: a collected wrapper releases its
  // native object, and with it the icon or the click listener.
  tray.TrayIcon? _tray;
  final _menu = <Object>[];

  /// Sets the window up before the first frame, so it never shows at the
  /// wrong size first.
  static Future<DesktopShell> start(
    SettingsStore settings, {
    required Future<void> Function(String status) setStatus,
  }) async {
    await windowManager.ensureInitialized();
    final saved = await settings.read(Settings.windowPlacement);
    final placement = saved == null
        ? null
        : placementOnScreen(saved, await _displays());
    final shell = DesktopShell._(
      settings,
      await TrayHost.watch(),
      placement,
      setStatus,
    );
    await windowManager.waitUntilReadyToShow(
      WindowOptions(
        title: 'Matterleast',
        titleBarStyle: TitleBarStyle.hidden,
        minimumSize: minimumWindowSize,
        size: placement == null
            ? defaultWindowSize
            : Size(placement.width, placement.height),
        center: placement?.x == null,
      ),
    );
    if (placement case WindowPlacement(:final x?, :final y?)) {
      await windowManager.setPosition(Offset(x, y));
    }
    if (placement?.maximized ?? false) await windowManager.maximize();
    _maximized.value = await windowManager.isMaximized();
    await windowManager.setPreventClose(true);
    windowManager.addListener(shell);
    shell._closeSetting = settings
        .watch(Settings.closeToTray)
        .listen((on) => shell._closeToTray = on);
    _hasTray.value = shell._host.present;
    shell
      ..showTray()
      // An icon registers with the panel that runs when it is made, so a
      // panel started later needs a new one.
      .._hostChanges = shell._host.changes.listen((present) {
        _hasTray.value = present;
        if (present) shell.showTray();
      });
    await windowManager.show();
    await windowManager.focus();
    return shell;
  }

  static Future<List<Rect>> _displays() async {
    try {
      return [
        for (final d in await screenRetriever.getAllDisplays())
          (d.visiblePosition ?? Offset.zero) & (d.visibleSize ?? d.size),
      ];
    } on Object catch (e) {
      Log.warn('desktop', 'Reading the displays failed', e);
      return const [];
    }
  }

  Future<void> _showing = Future.value();

  /// Makes the tray icon, one at a time. Where the panel doesn't take it
  /// because another app already holds its name, the next icon gets a new
  /// one; without any, there is no tray and closing quits.
  void showTray() => _showing = _showing.then((_) => _makeTray());

  Future<void> _makeTray() async {
    for (var attempt = 0; attempt < _trayAttempts; attempt++) {
      final taken = _host.expectItem();
      _showOneTray();
      if (_tray == null || await taken) return;
      Log.warn('desktop', 'The panel did not take the tray icon');
    }
    _tray?.dispose();
    _tray = null;
    _menu.clear();
  }

  static const _trayAttempts = 4;

  void _showOneTray() {
    _tray?.dispose();
    _tray = null;
    _menu.clear();
    try {
      final icon = tray.TrayIcon.create();
      final menu = tray.Menu.create();
      if (icon == null || menu == null) return;
      tray.MenuItem? item(String label, Future<void> Function() onClick) {
        final item = tray.MenuItem.createWithLabelAndType(
          label,
          tray.MenuItemType.normal,
        );
        item?.addListener((event) {
          if (event is tray.MenuItemClickedEvent) unawaited(onClick());
        });
        if (item != null) _menu.add(item);
        return item;
      }

      final statuses = tray.Menu.create();
      final statusItem = tray.MenuItem.createWithLabelAndType(
        'Set status',
        tray.MenuItemType.submenu,
      );
      if (statuses != null && statusItem != null) {
        for (final (status, label) in trayStatuses) {
          statuses.addItem(item(label, () => _setStatus(status)));
        }
        statusItem.submenu = statuses;
        _menu
          ..add(statuses)
          ..add(statusItem);
      }

      menu
        ..addItem(item('Open Matterleast', open))
        ..addItem(statusItem)
        ..addSeparator()
        ..addItem(item('Quit', quit));
      icon
        ..icon = _trayImage()
        ..setTooltip('Matterleast')
        ..setContextMenu(menu)
        ..setContextMenuTrigger(tray.ContextMenuTrigger.rightClicked)
        ..addListener((event) {
          if (event is tray.TrayIconClickedEvent) unawaited(open());
        })
        ..setVisible(true);
      _tray = icon;
      _menu.add(menu);
    } on Object catch (e) {
      Log.warn('desktop', 'Showing the tray icon failed', e);
    }
  }

  tray.Image? _trayImage() => tray.ImageAsset.fromAsset(
    windowBadge(_unread ?? 0).dot ? trayUnreadAsset : appIconAsset,
  );

  /// Shows [count] unread mentions and direct messages on the tray icon and
  /// the taskbar button, and flashes the button when one arrives while the
  /// window is in the background. Null while the count isn't known yet.
  void showUnread(int? count) {
    if (count == null) return;
    final before = _unread;
    _unread = count;
    final badge = windowBadge(count);
    if (before == null || windowBadge(before) != badge) {
      try {
        _tray?.icon = _trayImage();
      } on Object catch (e) {
        Log.warn('desktop', 'Changing the tray icon failed', e);
      }
      unawaited(Taskbar.setOverlay(badge.overlay));
    }
    final flash = flashesTaskbar(
      before: before,
      now: count,
      focused: _focus.value,
    );
    if (before != count) {
      unawaited(_launcher.show(launcherEntry(count, urgent: flash)));
    }
    if (flash) unawaited(Taskbar.flash());
  }

  /// Puts [title] on the window, as the taskbar and Alt+Tab show it.
  static Future<void> setTitle(String title) async {
    try {
      await windowManager.setTitle(title);
    } on Object catch (e) {
      Log.warn('desktop', 'Setting the window title failed', e);
    }
  }

  /// Shows and focuses the window, wherever it went.
  static Future<void> open() async {
    if (await windowManager.isMinimized()) await windowManager.restore();
    await windowManager.show();
    await windowManager.focus();
  }

  /// Whether the window has the keyboard focus. Flutter's lifecycle doesn't
  /// follow the focus on Linux, so this comes from the window events.
  static ValueListenable<bool> get focus => _focus;
  static final _focus = ValueNotifier(true);

  /// Whether a panel shows tray icons; false only on a Linux desktop without
  /// one, where closing the window quits.
  static ValueListenable<bool> get hasTray => _hasTray;
  static final _hasTray = ValueNotifier(true);

  /// Whether the window fills the screen, for the maximise button.
  static ValueListenable<bool> get maximized => _maximized;
  static final _maximized = ValueNotifier(false);

  @override
  void onWindowFocus() => _focus.value = true;

  @override
  void onWindowBlur() => _focus.value = false;

  @override
  void onWindowMinimize() => _focus.value = false;

  @override
  void onWindowEvent(String eventName) {
    if (eventName == 'hide') _focus.value = false;
    // GTK forgets the size hints when a hidden window shows again, also
    // when a second launch shows it.
    if (eventName == 'show') {
      unawaited(windowManager.setMinimumSize(minimumWindowSize));
    }
  }

  Future<void> quit() async {
    _saveSoon?.cancel();
    await _savePlacement();
    await _closeSetting?.cancel();
    await _hostChanges?.cancel();
    windowManager.removeListener(this);
    _tray?.dispose();
    _tray = null;
    _menu.clear();
    await _host.close();
    await _launcher.close();
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }

  @override
  void onWindowClose() {
    final action = closeAction(
      closeToTray: _closeToTray,
      hasTray: _tray != null && _host.present,
    );
    unawaited(switch (action) {
      CloseAction.hide => windowManager.hide(),
      CloseAction.quit => quit(),
    });
  }

  // Linux reports only move and resize, Windows also their end.
  @override
  void onWindowMove() => _changed();

  @override
  void onWindowMoved() => _changed();

  @override
  void onWindowResize() => _changed();

  @override
  void onWindowResized() => _changed();

  @override
  void onWindowMaximize() {
    _maximized.value = true;
    _changed();
  }

  @override
  void onWindowUnmaximize() {
    _maximized.value = false;
    _changed();
  }

  void _changed() {
    _saveSoon?.cancel();
    _saveSoon = Timer(
      const Duration(milliseconds: 500),
      () => unawaited(_savePlacement()),
    );
  }

  Future<void> _savePlacement() async {
    try {
      if (await windowManager.isMinimized() ||
          !await windowManager.isVisible()) {
        return;
      }
      final next = placementAfterChange(
        _placement,
        bounds: await windowManager.getBounds(),
        maximized: await windowManager.isMaximized(),
      );
      if (next == _placement) return;
      _placement = next;
      await _settings.write(Settings.windowPlacement, next);
    } on Object catch (e) {
      Log.warn('desktop', 'Saving the window placement failed', e);
    }
  }
}
