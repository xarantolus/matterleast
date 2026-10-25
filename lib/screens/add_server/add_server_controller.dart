import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/servers/entries.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_server_controller.freezed.dart';
part 'add_server_controller.g.dart';

@freezed
abstract class AddServerState with _$AddServerState {
  const factory AddServerState({
    @Default(false) bool checking,
    String? urlError,
    String? nameError,
  }) = _AddServerState;
}

/// A checked server and the name it will be listed under, ready for login.
class LoginTarget {
  const LoginTarget({
    required this.server,
    required this.displayName,
    this.ssoScheme,
  });

  final ProbedServer server;
  final String displayName;
  final String? ssoScheme;
}

@riverpod
class AddServerController extends _$AddServerController {
  @override
  AddServerState build() => const AddServerState();

  Future<LoginTarget?> connect({
    required String url,
    required String name,
  }) async {
    if (state.checking) return null;
    state = const AddServerState(checking: true);
    try {
      final server = await ref.read(serverProbeProvider).probe(url);
      final rows = await ref.read(appDatabaseProvider).allServers();
      if (!ref.mounted) return null;
      final check = checkNewServer(
        server: server,
        typedName: name,
        existing: [for (final row in rows) serverEntryOf(row)],
      );
      state = AddServerState(
        urlError: check.urlError,
        nameError: check.nameError,
      );
      return check.target;
    } on ProbeFailure catch (e) {
      if (ref.mounted) state = AddServerState(urlError: e.message);
      return null;
    }
  }
}

typedef NewServerCheck = ({
  LoginTarget? target,
  String? urlError,
  String? nameError,
});

/// Whether a checked server can go on to login: not already signed in under
/// any address, and with a name no other signed-in server uses.
NewServerCheck checkNewServer({
  required ProbedServer server,
  required String typedName,
  required List<ServerEntry> existing,
}) {
  final id = server.options.diagnosticId;
  final same = existing.where((e) => e.diagnosticId == id).firstOrNull;
  if (same != null && same.signedIn) {
    return (
      target: null,
      urlError:
          'You are already signed in to this server as '
          '“${same.displayName}”.',
      nameError: null,
    );
  }
  final taken = [
    for (final e in existing)
      if (e.signedIn && e.diagnosticId != id) e.displayName,
  ];
  final name = typedName.trim();
  if (taken.contains(name)) {
    return (
      target: null,
      urlError: null,
      nameError: 'Another server already has this name.',
    );
  }
  return (
    target: LoginTarget(
      server: server,
      displayName: name.isNotEmpty
          ? name
          : defaultDisplayName(server.options.siteName, server.url, taken),
      ssoScheme: same?.ssoScheme,
    ),
    urlError: null,
    nameError: null,
  );
}
