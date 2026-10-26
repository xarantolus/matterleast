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

    /// The check failed on the certificate, so trusting a CA may help.
    @Default(false) bool untrustedCertificate,
  }) = _AddServerState;
}

/// A checked server and the name it will be listed under, ready for login.
class LoginTarget {
  const LoginTarget({
    required this.server,
    required this.displayName,
    this.ssoScheme,
    this.replaces,
    this.confirmReplace = false,
  });

  final ProbedServer server;
  final String displayName;
  final String? ssoScheme;

  /// The entry with the same DiagnosticId under another address, which
  /// signing in removes.
  final ServerEntry? replaces;

  /// Whether the user must agree first: the old address doesn't lead here,
  /// so this may be another server claiming the old one's id.
  final bool confirmReplace;
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
      final probe = ref.read(serverProbeProvider);
      final server = await probe.probe(url);
      final rows = await ref.read(appDatabaseProvider).allServers();
      final existing = [for (final row in rows) serverEntryOf(row)];
      final previous = existing
          .where(
            (e) =>
                e.diagnosticId == server.options.diagnosticId &&
                e.url != server.url.toString(),
          )
          .firstOrNull;
      Uri? previousLandsOn;
      if (previous != null && !previous.signedIn) {
        try {
          previousLandsOn = (await probe.probe(previous.url)).url;
        } on ProbeFailure {
          previousLandsOn = null;
        }
      }
      if (!ref.mounted) return null;
      final check = checkNewServer(
        server: server,
        typedName: name,
        existing: existing,
        previousLandsOn: previousLandsOn,
      );
      state = AddServerState(
        urlError: check.urlError,
        nameError: check.nameError,
      );
      return check.target;
    } on ProbeFailure catch (e) {
      if (ref.mounted) {
        state = AddServerState(
          urlError: e.message,
          untrustedCertificate: e.untrustedCertificate,
        );
      }
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
/// any address, and with a name no other signed-in server uses. An entry
/// with the same DiagnosticId under another address is replaced; the user
/// is asked first unless that address, probed again, [previousLandsOn] the
/// new one (the server moved).
NewServerCheck checkNewServer({
  required ProbedServer server,
  required String typedName,
  required List<ServerEntry> existing,
  Uri? previousLandsOn,
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
  final moved = same != null && same.url != server.url.toString() ? same : null;
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
      replaces: moved,
      confirmReplace: moved != null && previousLandsOn != server.url,
    ),
    urlError: null,
    nameError: null,
  );
}
