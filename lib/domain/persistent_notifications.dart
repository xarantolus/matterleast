import 'package:matterleast/domain/server_features.dart';

/// Pure: what the server offers, or null when it offers nothing to this
/// person; guests only where the server lets them.
PersistentNotifications? persistentNotificationsFor(
  PersistentNotifications? offered, {
  required bool guest,
}) => offered != null && (!guest || offered.forGuests) ? offered : null;

/// Pure: how often recipients are notified, as one sentence.
String persistentNotificationsNote(Duration interval) {
  final minutes = interval.inMinutes;
  return 'Recipients are notified '
      '${minutes == 1 ? 'every minute' : 'every $minutes minutes'} '
      'until they acknowledge or reply.';
}
