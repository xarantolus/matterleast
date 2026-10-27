import 'package:flutter/foundation.dart';

/// Windows and Linux: a window with a mouse and a keyboard, and none of the
/// phone's services (WorkManager, quick actions, shares, the stay-connected
/// service). Read at each use, so tests switch it with
/// [debugDefaultTargetPlatformOverride].
bool get isDesktop => switch (defaultTargetPlatform) {
  TargetPlatform.windows || TargetPlatform.linux => true,
  _ => false,
};

/// The app icon as a Flutter asset, for the tray and notifications on
/// desktop.
const appIconAsset = 'assets/icon/legacy.png';

/// The tray icon with a dot, while there are unread mentions or direct
/// messages; made by tool/make-badges.sh.
const trayUnreadAsset = 'assets/icon/tray_unread.png';
