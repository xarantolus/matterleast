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

/// Whether the room address the plugin gave may carry our room token: always
/// over TLS, and unencrypted only when the server itself is plain http.
bool liveKitUrlAllowed(String roomUrl, String serverUrl) {
  final room = Uri.tryParse(roomUrl.trim());
  if (room == null || !room.hasAuthority || room.host.isEmpty) return false;
  return switch (room.scheme.toLowerCase()) {
    'wss' || 'https' => true,
    'ws' ||
    'http' => Uri.tryParse(serverUrl.trim())?.scheme.toLowerCase() == 'http',
    _ => false,
  };
}

/// Whether [identity] is the recording bot, which is in the room but not a
/// person. Matched by its server-minted user id, never by an attribute a
/// participant sets on itself; with no [botUserId] nobody is the bot.
bool isCallBot(String identity, String botUserId) =>
    botUserId.isNotEmpty && parseCallIdentity(identity).userId == botUserId;

/// The text to show for a peer's reaction, or null when it is malformed:
/// peers send these straight to us, so names and characters are capped.
String? acceptedReaction({String? name, String? literal}) {
  if ((name?.length ?? 0) > 128 || (literal?.length ?? 0) > 32) return null;
  final text = (name ?? '').isNotEmpty ? name : literal;
  return text == null || text.isEmpty ? null : text;
}
