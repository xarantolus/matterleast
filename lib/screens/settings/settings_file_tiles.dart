import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/settings_transfer.dart';
import 'package:matterleast/domain/settings_file.dart';
import 'package:matterleast/notifications/stay_connected.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

const _maxFileBytes = 1024 * 1024;

/// Export and import of the app's preferences and server list.
class SettingsFileTiles extends ConsumerWidget {
  const SettingsFileTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.upload_file),
          title: const Text('Export settings'),
          subtitle: const Text('Servers and preferences, without passwords'),
          onTap: () => _guard(context, () => _export(ref)),
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Import settings'),
          subtitle: const Text('From a file exported by Matterleast'),
          onTap: () => importSettings(context, ref),
        ),
      ],
    );
  }
}

/// Picks a settings file and, after the user confirms, applies it.
Future<void> importSettings(BuildContext context, WidgetRef ref) =>
    _guard(context, () => _import(context, ref));

Future<void> _guard(BuildContext context, Future<void> Function() run) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await run();
  } on SettingsFileException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } on FileSystemException {
    messenger.showSnackBar(
      const SnackBar(content: Text("Couldn't read the file.")),
    );
  }
}

Future<bool?> _stayConnected() async =>
    hasAndroidServices ? StayConnected.enabled() : null;

Future<void> _export(WidgetRef ref) async {
  final transfer = SettingsTransfer(ref.read(appDatabaseProvider));
  final file = await transfer.export(stayConnected: await _stayConnected());
  final bytes = Uint8List.fromList(utf8.encode(encodeSettingsFile(file)));
  final name = settingsFileName(DateTime.now());
  if (isDesktop) {
    await FilePicker.saveFile(
      dialogTitle: 'Export settings',
      fileName: name,
      bytes: bytes,
      mimeType: 'application/json',
    );
    return;
  }
  final path = p.join((await getTemporaryDirectory()).path, name);
  await File(path).writeAsBytes(bytes);
  await SharePlus.instance.share(
    ShareParams(files: [XFile(path, mimeType: 'application/json')]),
  );
}

Future<void> _import(BuildContext context, WidgetRef ref) async {
  final picked = await FilePicker.pickFiles(dialogTitle: 'Import settings');
  if (picked.isEmpty) return;
  final source = picked.first.xFile;
  if (await source.length() > _maxFileBytes) {
    throw const SettingsFileException(
      'This is not a Matterleast settings file.',
    );
  }
  final file = parseSettingsFile(await source.readAsString());
  final transfer = SettingsTransfer(ref.read(appDatabaseProvider));
  final plan = await transfer.plan(file, stayConnected: await _stayConnected());
  if (!context.mounted) return;
  if (plan.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Nothing to change.')));
    return;
  }
  if (!await confirm(
    context,
    title: 'Import settings',
    body: importSummary(plan),
    action: 'Import',
  )) {
    return;
  }
  await transfer.apply(plan);
  if (plan.stayConnected case final on?) {
    await setStayConnected(ref.read(notifierProvider), on);
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Settings imported.')));
  }
}
