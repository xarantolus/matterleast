import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/notifications/app_visibility.dart';

void main() {
  const name = 'matterleast.test_peer';

  tearDown(() => IsolateNameServer.removePortNameMapping(name));

  test('a peer that answers counts as there', () async {
    final peer = ReceivePort()..listen(AppVisibility.answerPing);
    addTearDown(peer.close);
    IsolateNameServer.registerPortWithName(peer.sendPort, name);

    expect(await AppVisibility.answers(name), isTrue);
    expect(IsolateNameServer.lookupPortByName(name), isNotNull);
  });

  test('a name left behind by a dead peer is forgotten', () async {
    final dead = ReceivePort()..close();
    IsolateNameServer.registerPortWithName(dead.sendPort, name);

    expect(
      await AppVisibility.answers(name, wait: const Duration(milliseconds: 50)),
      isFalse,
    );
    expect(IsolateNameServer.lookupPortByName(name), isNull);
  });

  test(
    'the shown UI answers, and a swiped-away one no longer counts',
    () async {
      await AppVisibility.shown();
      expect(await AppVisibility.stillVisible(), isTrue);

      AppVisibility.forgetUi();
      expect(AppVisibility.visible, isFalse);
      expect(await AppVisibility.stillVisible(), isFalse);
      AppVisibility.hidden();
    },
  );
}
