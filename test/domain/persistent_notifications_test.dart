import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/persistent_notifications.dart';

void main() {
  const offered = (
    maxRecipients: 5,
    interval: Duration(minutes: 5),
    forGuests: false,
  );

  test('guests get it only where the server lets them', () {
    expect(persistentNotificationsFor(offered, guest: false), offered);
    expect(persistentNotificationsFor(offered, guest: true), isNull);
    const open = (
      maxRecipients: 5,
      interval: Duration(minutes: 5),
      forGuests: true,
    );
    expect(persistentNotificationsFor(open, guest: true), open);
    expect(persistentNotificationsFor(null, guest: false), isNull);
  });

  test('the note says how often, in the singular for one minute', () {
    expect(
      persistentNotificationsNote(const Duration(minutes: 10)),
      'Recipients are notified every 10 minutes until they acknowledge or '
      'reply.',
    );
    expect(
      persistentNotificationsNote(const Duration(minutes: 1)),
      'Recipients are notified every minute until they acknowledge or reply.',
    );
  });
}
