import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/search/search_providers.dart';

/// A signed-in server at [url].
ServerEntry testServerEntry(
  String url, {
  String name = 'Test',
  String? serverVersion,
}) => ServerEntry(
  url: url,
  displayName: name,
  siteName: null,
  serverVersion: serverVersion,
  diagnosticId: null,
  lastActiveAt: DateTime(2026),
  ssoScheme: null,
);

/// The servers the app is signed in to.
Override serversOverride(List<ServerEntry> entries) =>
    serversProvider.overrideWith((ref) {
      ref.keepAlive();
      return Stream.value(entries);
    });

/// The channels, direct messages and threads the switcher lists for [url].
Override switchItemsOverride(String url, List<SwitchItem> items) =>
    switchItemsProvider(url).overrideWith((ref) {
      ref.keepAlive();
      return Stream.value(items);
    });
