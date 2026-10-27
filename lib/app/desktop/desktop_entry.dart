import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:matterleast/domain/desktop_entry.dart';
import 'package:matterleast/log.dart';

/// Adds the app to the Linux app menu and makes it the handler of the
/// mmauth:// links single sign-on returns through, like Telegram Desktop
/// does when run from an unpacked folder. Only release builds do it, so a
/// development run never touches the developer's menu. Never throws.
Future<void> registerDesktopEntry({
  Map<String, String>? environment,
  String? executable,
}) async {
  if (!Platform.isLinux || !kReleaseMode) return;
  try {
    final env = environment ?? Platform.environment;
    final exe = executable ?? Platform.resolvedExecutable;
    final data = _dataHome(env);
    if (data == null) return;
    final applications = Directory('$data/applications');
    final file = File('${applications.path}/matterleast.desktop');
    final icon = File('${File(exe).parent.path}/matterleast.png');
    final content = desktopEntryToWrite(
      environment: env,
      executable: exe,
      iconPath: icon.existsSync() ? icon.path : null,
      existing: file.existsSync() ? file.readAsStringSync() : null,
    );
    if (content != null) {
      await applications.create(recursive: true);
      await file.writeAsString(content);
      await _run('update-desktop-database', [applications.path]);
    }
    final current = await Process.run('xdg-mime', [
      'query',
      'default',
      'x-scheme-handler/mmauth',
    ]);
    if (current.stdout.toString().trim() != 'matterleast.desktop') {
      await _run('xdg-mime', [
        'default',
        'matterleast.desktop',
        'x-scheme-handler/mmauth',
      ]);
    }
  } on Object catch (e) {
    Log.warn('desktop', 'Adding the launcher entry failed', e);
  }
}

String? _dataHome(Map<String, String> env) {
  final xdg = env['XDG_DATA_HOME'];
  if (xdg != null && xdg.startsWith('/')) return xdg;
  final home = env['HOME'];
  return home == null || home.isEmpty ? null : '$home/.local/share';
}

Future<void> _run(String command, List<String> args) async {
  try {
    await Process.run(command, args);
  } on ProcessException {
    Log.warn('desktop', '$command is not available');
  }
}
