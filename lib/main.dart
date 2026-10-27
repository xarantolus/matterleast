import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/desktop/desktop_shell.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  final container = ProviderContainer();
  if (isDesktop) {
    WidgetsFlutterBinding.ensureInitialized();
    // The image caches' index is sqflite, which has no desktop plugin; this
    // runs it on the sqlite3 library the app ships anyway.
    databaseFactory = databaseFactoryFfi;
    await DesktopShell.start(container.read(settingsStoreProvider));
  }
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MatterleastApp(),
    ),
  );
}
