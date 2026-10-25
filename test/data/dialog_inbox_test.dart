import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/websocket/dialog.dart';
import 'package:matterleast/data/live/dialogs.dart';

void main() {
  test('a dialog that arrives before the command answer still opens', () {
    final inbox = DialogInbox();
    final shown = <OpenDialog>[];
    inbox.dialogs.listen(shown.add);
    inbox.offer(const OpenDialog(triggerId: 'trigger-1'));
    inbox.expect('trigger-1');
    return Future<void>.delayed(Duration.zero, () {
      expect(shown.map((d) => d.triggerId), ['trigger-1']);
    });
  });

  test("a dialog for another device's command does not open", () {
    final inbox = DialogInbox();
    final shown = <OpenDialog>[];
    inbox.dialogs.listen(shown.add);
    inbox.expect('mine');
    inbox.offer(const OpenDialog(triggerId: 'theirs'));
    return Future<void>.delayed(Duration.zero, () => expect(shown, isEmpty));
  });
}
