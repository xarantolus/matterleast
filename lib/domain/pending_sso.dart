import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/domain/sso_callback.dart';

part 'pending_sso.freezed.dart';
part 'pending_sso.g.dart';

/// A browser sign-in that was started and not finished, kept so the callback
/// can finish it when Android killed the app while the user was in the
/// browser. It holds the sign-in's challenge secrets and no session.
@freezed
abstract class PendingSso with _$PendingSso {
  const factory PendingSso({
    required String serverUrl,
    required String displayName,
    required String state,
    required String verifier,
    required DateTime startedAt,
    String? ssoScheme,
    String? replaces,
  }) = _PendingSso;

  const PendingSso._();

  factory PendingSso.fromJson(Map<String, Object?> json) =>
      _$PendingSsoFromJson(json);

  String get scheme => ssoScheme ?? defaultSsoScheme;

  /// Whether a callback may still finish it, [timeout] after it started.
  bool isFresh(DateTime now, Duration timeout) {
    final age = now.difference(startedAt);
    return !age.isNegative && age < timeout;
  }

  SsoChallenge get challenge => SsoChallenge(
    state: state,
    verifier: verifier,
    challenge: s256Challenge(verifier),
  );
}
