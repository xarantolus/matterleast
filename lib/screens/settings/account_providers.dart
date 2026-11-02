import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/account_actions.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/domain/account_security.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_providers.g.dart';

@riverpod
Future<AccountActions> accountActions(Ref ref, String url) async =>
    (await ref.watch(serverSessionProvider(url).future)).account;

/// The account as the server has it now, for what the stored copy lacks.
@Riverpod(retry: noRetry)
Future<api.User> accountMe(Ref ref, String url) async =>
    (await ref.watch(accountActionsProvider(url).future)).me();

/// Whether the account can manage two-factor authentication here.
@riverpod
Future<bool> mfaAvailable(Ref ref, String url) async {
  final offers = await ref.watch(
    featuresProvider(url).selectAsync((f) => f.multifactor),
  );
  if (!offers) return false;
  final db = (await ref.watch(serverSessionProvider(url).future)).db;
  return mfaManageable(
    serverOffers: offers,
    authService: await db.syncText(SyncKeys.currentUserAuthService) ?? '',
  );
}

/// The terms to show the user, or null when none are due. Looks again when
/// the server's config arrives or changes.
@Riverpod(retry: noRetry)
Future<api.TermsOfService?> termsToAccept(Ref ref, String url) async {
  final termsId = await ref.watch(
    featuresProvider(url).selectAsync((f) => f.termsId),
  );
  if (termsId == null) return null;
  final actions = await ref.watch(accountActionsProvider(url).future);
  final me = await actions.me();
  if (!termsDue(termsId: termsId, acceptedId: me.termsOfServiceId)) return null;
  return actions.currentTerms();
}

/// The account's sessions, newest activity first.
@Riverpod(retry: noRetry)
class ActiveSessions extends _$ActiveSessions {
  @override
  Future<List<SessionRow>> build(String url) async {
    final actions = await ref.watch(accountActionsProvider(url).future);
    final sessions = [
      for (final s in await actions.sessions())
        if ((s.id ?? '').isNotEmpty) s,
    ];
    final current = currentSessionId([
      for (final s in sessions) (id: s.id!, lastActive: s.lastActivityAt),
    ]);
    final rows = [
      for (final s in sessions)
        SessionRow(
          id: s.id!,
          device: sessionDeviceName(
            platform: _prop(s, 'platform'),
            os: _prop(s, 'os'),
            browser: _prop(s, 'browser'),
          ),
          lastActive: s.lastActivityAt,
          created: s.createAt,
          current: s.id == current,
        ),
    ];
    return rows..sort((a, b) {
      final x = a.lastActive, y = b.lastActive;
      if (x == null || y == null) return x == null ? (y == null ? 0 : 1) : -1;
      return y.compareTo(x);
    });
  }

  static String? _prop(api.Session s, String key) => switch (s.props?[key]) {
    final String value => value,
    _ => null,
  };

  /// Ends [id] on the server and lists again.
  Future<void> revoke(String id) async {
    await (await ref.read(accountActionsProvider(url).future))
        .revokeSession(id);
    ref.invalidateSelf();
    await future;
  }
}
