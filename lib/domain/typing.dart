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
