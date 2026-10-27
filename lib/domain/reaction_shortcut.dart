/// A message of just `+:emoji:` or `-:emoji:`, which reacts to the newest
/// message instead of being sent, as in the official apps.
typedef ReactionShortcut = ({bool add, String emojiName});

final _shortcut = RegExp(r'^([+-]):([^:\s]+):\s*$');

/// Pure: the shortcut [message] asks for, or null when it is ordinary text.
ReactionShortcut? reactionShortcut(String message) {
  final match = _shortcut.firstMatch(message.trim());
  if (match == null) return null;
  return (add: match[1] == '+', emojiName: match[2]!);
}
