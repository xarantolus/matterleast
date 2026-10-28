import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/screens/you/profile_providers.dart';

/// Sets the presence [status] on every signed-in server, as the tray menu
/// asks; a server that refuses is logged and skipped.
Future<void> setStatusEverywhere(
  ProviderContainer container,
  String status,
) async {
  final servers = await container.read(serversProvider.future);
  await Future.wait([
    for (final s in servers)
      if (s.signedIn) _set(container, s.url, status),
  ]);
}

Future<void> _set(
  ProviderContainer container,
  String url,
  String status,
) async {
  try {
    final actions = await container.read(profileActionsProvider(url).future);
    await actions.setStatus(status);
  } on Object catch (e) {
    Log.warn('desktop', 'Setting the status from the tray failed', e);
  }
}
