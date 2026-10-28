import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/desktop/desktop_shell.dart';
import 'package:matterleast/app/desktop/smooth_wheel.dart';
import 'package:matterleast/app/desktop/tray_status.dart';
import 'package:matterleast/app/desktop/unread_count.dart';
import 'package:matterleast/app/desktop/window_title.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/screens/gallery/settled_end_player.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  final container = ProviderContainer();
  registerFontLicence();
  if (isDesktop) {
    DesktopBinding();
    // The image caches' index is sqflite, which has no desktop plugin; this
    // runs it on the sqlite3 library the app ships anyway.
    databaseFactory = databaseFactoryFfi;
    settleVideoEnds();
    final shell = await DesktopShell.start(
      container.read(settingsStoreProvider),
      setStatus: (status) => setStatusEverywhere(container, status),
    );
    container.listen(
      unreadCountProvider,
      (_, count) => shell.showUnread(count),
      fireImmediately: true,
    );
    container.listen(
      windowTitleTextProvider,
      (_, title) => unawaited(DesktopShell.setTitle(title)),
      fireImmediately: true,
    );
  }
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MatterleastApp(),
    ),
  );
}
