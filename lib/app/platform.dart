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

/// Android's own services: the stay-connected service, Data Saver,
/// conversation shortcuts and the rotation setting. Off on iOS, which is
/// otherwise a phone like Android.
bool get hasAndroidServices => defaultTargetPlatform == TargetPlatform.android;

/// iOS Low Data Mode is set per network, Wi-Fi included; Android's Data
/// Saver only restricts metered networks.
bool get dataSaverCoversWifi => defaultTargetPlatform == TargetPlatform.iOS;

/// The phone's name for its data saving mode.
String get dataSaverName => defaultTargetPlatform == TargetPlatform.iOS
    ? 'Low Data Mode'
    : 'Data Saver';

/// The earliest the background check runs after it is scheduled. iOS takes
/// this, not a frequency, for every run; WorkManager on Android spaces the
/// runs itself.
Duration? get periodicCheckDelay => defaultTargetPlatform == TargetPlatform.iOS
    ? const Duration(minutes: 15)
    : null;

/// How long a background check may take before it stops: iOS gives a
/// refresh task about 30 seconds and ends an app that takes longer.
Duration? get backgroundCheckLimit =>
    defaultTargetPlatform == TargetPlatform.iOS
    ? const Duration(seconds: 25)
    : null;

/// The phone's system by name, for sentences about its settings.
String get phoneSystem =>
    defaultTargetPlatform == TargetPlatform.iOS ? 'iOS' : 'Android';

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
