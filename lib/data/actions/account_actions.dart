import 'dart:convert';
import 'dart:typed_data';

import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/servers/server_session.dart';

/// What the server hands out to set up two-factor authentication.
class MfaSecret {
  const MfaSecret({required this.secret, required this.qrImage});

  final String secret;

  /// The QR code as a PNG; null when the server sent none.
  final Uint8List? qrImage;
}

/// The signed-in account's security on one server: sessions, two-factor
/// authentication and the terms of service.
class AccountActions {
  AccountActions(this.session);

  final ServerSession session;

  Future<api.User> me() =>
      session.api.call(() => session.api.client.users.getUser(userId: 'me'));

  Future<List<api.Session>> sessions() => session.api.call(
    () => session.api.client.users.getSessions(userId: 'me'),
  );

  Future<void> revokeSession(String id) => session.api.call(
    () => session.api.client.users.revokeSession(
      userId: 'me',
      body: api.ApiV4UsersUserIdSessionsRevokeRequestBody(sessionId: id),
    ),
  );

  Future<MfaSecret> generateMfa() async {
    final made = await session.api.call(
      () => session.api.client.users.generateMfaSecret(userId: 'me'),
    );
    return MfaSecret(secret: made.secret ?? '', qrImage: _png(made.qrCode));
  }

  static Uint8List? _png(String? base64) {
    if (base64 == null || base64.isEmpty) return null;
    try {
      return base64Decode(base64);
    } on FormatException {
      return null;
    }
  }

  Future<void> setMfa({required bool activate, String? code}) =>
      session.api.call(
        () => session.api.client.users.updateUserMfa(
          userId: 'me',
          body: api.ApiV4UsersUserIdMfaRequestBody(
            activate: activate,
            code: code,
          ),
        ),
      );

  /// The terms the user has to answer, or null when the server has none:
  /// an endpoint it doesn't have turns the feature off.
  Future<api.TermsOfService?> currentTerms() async {
    try {
      final terms = await session.api.call(
        () => session.api.client.termsOfService.getTermsOfService(),
      );
      return (terms.id ?? '').isEmpty ? null : terms;
    } on ServerError catch (e) {
      if (e.isNotFound || e.statusCode == 501) return null;
      rethrow;
    }
  }

  Future<void> answerTerms(String termsId, {required bool accepted}) =>
      session.api.call(
        () => session.api.client.users.registerTermsOfServiceAction(
          userId: 'me',
          body: api.ApiV4UsersUserIdTermsOfServiceRequestBody(
            termsOfServiceId: termsId,
            accepted: accepted,
          ),
        ),
      );
}
