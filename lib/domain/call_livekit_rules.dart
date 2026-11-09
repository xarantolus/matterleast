/// Whether the Calls plugin [version] carries media over LiveKit: from 2.0.0
/// on. A pre-release suffix is ignored, and a version we can't read means the
/// classic transport.
bool callsUseLiveKit(String? version) {
  final match = RegExp(r'^v?(\d+)\.').firstMatch((version ?? '').trim());
  final major = int.tryParse(match?.group(1) ?? '');
  return major != null && major >= 2;
}

/// LiveKit names a participant `userId___sessionId`; one that doesn't split
/// cleanly is still a usable session key.
({String userId, String sessionId}) parseCallIdentity(String identity) {
  final parts = identity.split('___');
  return parts.length == 2
      ? (userId: parts[0], sessionId: parts[1])
      : (userId: '', sessionId: identity);
}

/// Who started and who stopped speaking between two sets of sessions.
({Set<String> started, Set<String> stopped}) speakingChanges(
  Set<String> before,
  Set<String> after,
) => (started: after.difference(before), stopped: before.difference(after));

/// Why the room let us go.
enum RoomLeft { callEnded, removed, other }
