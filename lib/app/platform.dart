import 'package:flutter/foundation.dart';

/// Windows and Linux: a window with a mouse and a keyboard, and none of the
/// phone's services (WorkManager, quick actions, shares, the stay-connected
/// service). Read at each use, so tests switch it with
/// [debugDefaultTargetPlatformOverride].
bool get isDesktop => switch (defaultTargetPlatform) {
  TargetPlatform.windows || TargetPlatform.linux => true,
  _ => false,
};

/// Windows blocks each window resize until a frame of the new size arrives,
/// up to a timeout when the app isn't drawing yet, so there the app starts
/// before the desktop shell sizes the window; the shell then shows it.
bool get appBeforeShell => defaultTargetPlatform == TargetPlatform.windows;

/// "tap" on a phone, "click" with a mouse; [capital] for a sentence start.
String tapWord({bool capital = false}) => switch ((isDesktop, capital)) {
  (true, true) => 'Click',
  (true, false) => 'click',
  (false, true) => 'Tap',
  (false, false) => 'tap',
};

/// "phone" or "computer", for sentences.
String get deviceWord => isDesktop ? 'computer' : 'phone';

/// The app icon as a Flutter asset, for the tray and notifications on
/// desktop.
const appIconAsset = 'assets/icon/legacy.png';

/// The tray icon with a red dot, while there are unread mentions or direct
/// messages; made by tool/make-badges.sh.
const trayMentionAsset = 'assets/icon/tray_mention.png';

/// The tray icon with a blue dot, while only other messages are unread.
const trayUnreadAsset = 'assets/icon/tray_unread.png';
