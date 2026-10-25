/// Pure: whether to tell the channel the user is writing now. Not more
/// often than the server's interval, not in channels so big the server
/// stops notifying, and not when the server turned it off.
bool shouldSendTyping({
  required DateTime now,
  required DateTime? lastSent,
  required Duration interval,
  required bool enabled,
  int? memberCount,
  int? maxNotificationsPerChannel,
}) {
  if (!enabled) return false;
  if (memberCount != null &&
      maxNotificationsPerChannel != null &&
      memberCount >= maxNotificationsPerChannel) {
    return false;
  }
  return lastSent == null || now.difference(lastSent) >= interval;
}

/// Pure: the line telling who is writing, or null when nobody is.
String? typingText(List<String> names) => switch (names) {
  [] => null,
  [final a] => '$a is typing…',
  [final a, final b] => '$a and $b are typing…',
  [final a, final b, ...] => '$a, $b and ${names.length - 2} more are typing…',
};
