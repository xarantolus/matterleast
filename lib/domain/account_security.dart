import 'package:matterleast/domain/time_labels.dart';

/// Pure: whether the terms must be shown: the server asks for [termsId] and
/// the user has not accepted exactly that version.
bool termsDue({required String? termsId, required String? acceptedId}) =>
    termsId != null && termsId.isNotEmpty && acceptedId != termsId;

/// Pure: whether the user can manage two-factor authentication here: the
/// server offers it and the account signs in with a password, not through
/// a single sign-on provider that does its own.
bool mfaManageable({required bool serverOffers, required String authService}) =>
    serverOffers && authService.isEmpty;

/// One of the account's sessions as the list shows it.
class SessionRow {
  const SessionRow({
    required this.id,
    required this.device,
    required this.lastActive,
    required this.created,
    required this.current,
  });

  final String id;
  final String device;
  final DateTime? lastActive;
  final DateTime? created;
  final bool current;
}

/// Sessions closer in activity than this can't tell which one is asking.
const sessionTieWindow = Duration(seconds: 5);

/// Pure: the id of the session making the request, which the server never
/// reveals: the one active most recently, since asking for the list just
/// made it so. Null when another is active about as recently.
String? currentSessionId(List<({String id, DateTime? lastActive})> sessions) {
  final dated = [
    for (final s in sessions)
      if (s.lastActive != null) (id: s.id, at: s.lastActive!),
  ]..sort((a, b) => b.at.compareTo(a.at));
  if (dated.isEmpty) return null;
  if (dated.length > 1 &&
      dated.first.at.difference(dated[1].at) < sessionTieWindow) {
    return null;
  }
  return dated.first.id;
}

/// Pure: a name for the device behind a session from what the server
/// recorded at sign-in.
String sessionDeviceName({String? platform, String? os, String? browser}) {
  String? clean(String? v) {
    final t = v?.trim();
    return t == null || t.isEmpty || t.toLowerCase().startsWith('unknown')
        ? null
        : t;
  }

  final parts = [clean(browser), clean(os) ?? clean(platform)].nonNulls;
  return parts.isEmpty ? 'Unknown device' : parts.join(' on ');
}

/// Pure: when the session was signed in, by calendar date.
String sessionStartLabel(DateTime? at, DateTime now) =>
    at == null ? '' : 'Signed in ${dateLabel(at, now)}';

/// Pure: when the session was last used, by calendar date.
String sessionActivityLabel(
  DateTime? at,
  DateTime now, {
  required bool use24,
}) => at == null
    ? 'Last activity unknown'
    : 'Last active ${whenLabel(at, now, use24: use24)}';
