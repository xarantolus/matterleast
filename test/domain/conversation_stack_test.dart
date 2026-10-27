import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/conversation_stack.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/domain/quick_switch.dart';

const _url = 'https://chat.example.test';

ChannelTarget _channel(String id, {String? highlight}) => ChannelTarget(
  url: _url,
  channelId: id,
  title: id,
  highlightPostId: highlight,
);

ThreadTarget _thread(String channel, String root, {String? highlight}) =>
    ThreadTarget(
      url: _url,
      channelId: channel,
      rootId: root,
      channelName: channel,
      highlightPostId: highlight,
    );

void main() {
  final cases =
      <(String, List<ConversationTarget>, ConversationTarget, StackStep)>[
        (
          'nothing open: it opens on top',
          [],
          _channel('a'),
          const StackStep.push(),
        ),
        (
          'the channel is open (under its info pages): back to it',
          [_channel('a')],
          _channel('a', highlight: 'p1'),
          const StackStep.returnTo(0),
        ),
        (
          'the channel is under its thread: back to the channel',
          [_channel('a'), _thread('a', 'r1')],
          _channel('a', highlight: 'p1'),
          const StackStep.returnTo(0),
        ),
        (
          'the same thread is open: back to it',
          [_channel('a'), _thread('a', 'r1')],
          _thread('a', 'r1', highlight: 'p2'),
          const StackStep.returnTo(1),
        ),
        (
          'a thread of the open channel opens over it',
          [_channel('a')],
          _thread('a', 'r1'),
          const StackStep.pushOver(0),
        ),
        (
          'another thread of the channel takes the open thread\'s place',
          [_channel('a'), _thread('a', 'r1')],
          _thread('a', 'r2'),
          const StackStep.pushOver(0),
        ),
        (
          'another channel takes the place of what is open',
          [_channel('a'), _thread('a', 'r1')],
          _channel('b'),
          const StackStep.replace(0),
        ),
        (
          'a thread elsewhere takes the place of what is open',
          [_channel('a')],
          _thread('b', 'r1'),
          const StackStep.replace(0),
        ),
        (
          'the channel of an open thread replaces it',
          [_thread('a', 'r1')],
          _channel('a'),
          const StackStep.replace(0),
        ),
        (
          'the same channel on another server is another channel',
          [_channel('a')],
          const ChannelTarget(
            url: 'https://other.example.test',
            channelId: 'a',
            title: 'a',
          ),
          const StackStep.replace(0),
        ),
      ];
  for (final (name, open, target, step) in cases) {
    test(name, () => expect(stackStepFor(open, target), step));
  }

  final fromOutside =
      <(String, List<ConversationTarget>, ConversationTarget, StackStep)>[
        (
          'nothing open: it opens over the list, not over a page',
          [],
          _channel('a'),
          const StackStep.overList(),
        ),
        (
          'a thread of the open channel keeps the channel under it',
          [_channel('a')],
          _thread('a', 'r1'),
          const StackStep.pushOver(0),
        ),
        (
          'another thread of the open channel keeps the channel too',
          [_channel('a'), _thread('a', 'r1')],
          _thread('a', 'r2'),
          const StackStep.pushOver(0),
        ),
        (
          'the open channel stays as it is',
          [_channel('a'), _thread('a', 'r1')],
          _channel('a', highlight: 'p1'),
          const StackStep.returnTo(0),
        ),
        (
          'another channel opens over the list',
          [_channel('a'), _thread('a', 'r1')],
          _channel('b'),
          const StackStep.overList(),
        ),
        (
          'a thread elsewhere opens over the list',
          [_channel('a')],
          _thread('b', 'r1'),
          const StackStep.overList(),
        ),
      ];
  group('from outside the app', () {
    for (final (name, open, target, step) in fromOutside) {
      test(
        name,
        () => expect(stackStepFor(open, target, fromOutside: true), step),
      );
    }
  });

  group('a channel gone from under an open conversation', () {
    SwitchItem item(SwitchKind kind) =>
        SwitchItem(serverUrl: _url, kind: kind, id: 'a', title: 'a');
    final cases = <(String, SwitchItem?, bool, ChannelGone?)>[
      ('still in it', item(SwitchKind.channel), false, null),
      ('a direct message stays', item(SwitchKind.direct), false, null),
      ('no longer listed: removed', null, true, ChannelGone.removed),
      (
        'only joinable now: removed',
        item(SwitchKind.joinable),
        true,
        ChannelGone.removed,
      ),
      (
        'archived and archived hidden',
        item(SwitchKind.archived),
        false,
        ChannelGone.archived,
      ),
      (
        'archived but archived shown: stays',
        item(SwitchKind.archived),
        true,
        null,
      ),
    ];
    for (final (name, channel, archivedShown, gone) in cases) {
      test(
        name,
        () => expect(channelGone(channel, archivedShown: archivedShown), gone),
      );
    }
  });
}
