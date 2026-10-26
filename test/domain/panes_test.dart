import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/panes.dart';

const url = 'https://chat.example.test';
const general = ChannelTarget(url: url, channelId: 'c1', title: 'General');
const random = ChannelTarget(url: url, channelId: 'c2', title: 'Random');
const generalThread = ThreadTarget(
  url: url,
  channelId: 'c1',
  rootId: 'p1',
  channelName: 'General',
);
const randomThread = ThreadTarget(
  url: url,
  channelId: 'c2',
  rootId: 'p2',
  channelName: 'Random',
);

void main() {
  test('phones and small tablets keep one pane; panes start at 840 dp, '
      'the thread pane at 1200 dp', () {
    expect(windowClassOf(411).showsPanes, isFalse);
    expect(windowClassOf(839).showsPanes, isFalse);
    expect(windowClassOf(840).showsPanes, isTrue);
    expect(windowClassOf(1199).showsThreadPane, isFalse);
    expect(windowClassOf(1200).showsThreadPane, isTrue);
  });

  group('opening', () {
    test('a channel replaces the open one and closes its thread', () {
      final panes = Panes.none.open(general).open(generalThread).open(random);
      expect(panes, const Panes(channel: random));
    });

    test('picking the open channel again keeps its thread', () {
      final panes = Panes.none.open(general).open(generalThread).open(general);
      expect(panes, const Panes(channel: general, thread: generalThread));
    });

    test('a thread of another channel brings its channel beside it', () {
      final panes = Panes.none.open(general).open(randomThread);
      expect(panes.channel?.channelId, 'c2');
      expect(panes.thread, randomThread);
    });
  });

  test('back closes the thread first, then the channel', () {
    const both = Panes(channel: general, thread: generalThread);
    expect(both.back(), const Panes(channel: general));
    expect(both.back().back().isEmpty, isTrue);
  });

  test('a large window shows the thread beside its channel; a smaller wide '
      'one shows the thread in place of the channel', () {
    const both = Panes(channel: general, thread: generalThread);
    expect(both.shownIn(WindowClass.large), (
      main: general,
      side: generalThread,
    ));
    expect(both.shownIn(WindowClass.expanded), (
      main: generalThread,
      side: null,
    ));
  });

  group('moving between routes and panes', () {
    test('the top route stays open, with its channel when a thread', () {
      expect(
        Panes.fromStack([general, generalThread, random]),
        const Panes(channel: random),
      );
      expect(
        Panes.fromStack([general, generalThread]),
        const Panes(channel: general, thread: generalThread),
      );
      expect(Panes.fromStack([random, generalThread]).channel?.channelId, 'c1');
    });

    test('panes become the channel route with the thread on top', () {
      const both = Panes(channel: general, thread: generalThread);
      expect(both.stack, [general, generalThread]);
      expect(Panes.fromStack(both.stack), both);
    });
  });
}
