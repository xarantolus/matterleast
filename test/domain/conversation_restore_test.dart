import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/conversation_restore.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/domain/quick_switch.dart';

const url = 'https://chat.example.test';

SwitchItem channel(
  String id, {
  SwitchKind kind = SwitchKind.channel,
  String title = 'General',
  String? teamId = 't1',
}) => SwitchItem(
  serverUrl: url,
  kind: kind,
  id: id,
  title: title,
  teamId: teamId,
);

const inChannel = SavedConversation(
  url: url,
  channelId: 'c1',
  title: 'General',
  teamId: 't1',
);
const inThread = SavedConversation(
  url: url,
  channelId: 'c1',
  title: 'General',
  teamId: 't1',
  rootId: 'p1',
);

List<ConversationTarget> restore(
  SavedConversation? saved, {
  bool intent = false,
  Set<String> servers = const {url},
  Map<String, SwitchItem>? channels,
}) => conversationsToRestore(
  saved: saved,
  launchedByIntent: intent,
  signedInUrls: servers,
  channels: channels ?? {'c1': channel('c1', title: 'Renamed')},
);

void main() {
  group('what is saved', () {
    test('the thread on top, else the channel, else nothing', () {
      expect(conversationToSave(Panes.none), isNull);
      expect(
        conversationToSave(
          const Panes(
            channel: ChannelTarget(url: url, channelId: 'c1', title: 'General'),
          ),
        ),
        const SavedConversation(url: url, channelId: 'c1', title: 'General'),
      );
      expect(
        conversationToSave(
          const Panes(
            channel: ChannelTarget(url: url, channelId: 'c1', title: 'General'),
            thread: ThreadTarget(
              url: url,
              channelId: 'c1',
              rootId: 'p1',
              channelName: 'General',
            ),
          ),
        )?.rootId,
        'p1',
      );
    });

    test('survives the settings encoding', () {
      expect(SavedConversation.fromJson(inThread.toJson()), inThread);
    });
  });

  group('what reopens', () {
    test('a channel opens, under its current name', () {
      expect(restore(inChannel), [
        const ChannelTarget(
          url: url,
          channelId: 'c1',
          title: 'Renamed',
          teamId: 't1',
        ),
      ]);
    });

    test('a thread opens over its channel', () {
      final stack = restore(inThread);
      expect(stack, hasLength(2));
      expect(stack.first, isA<ChannelTarget>());
      expect((stack.last as ThreadTarget).rootId, 'p1');
    });

    test('nothing saved, nothing opens', () {
      expect(restore(null), isEmpty);
    });

    test('a notification, link or share wins', () {
      expect(restore(inChannel, intent: true), isEmpty);
    });

    test('a server that signed out leaves the list', () {
      expect(restore(inChannel, servers: const {}), isEmpty);
    });

    test('a channel that is gone, left, archived or joinable leaves '
        'the list', () {
      expect(restore(inChannel, channels: const {}), isEmpty);
      for (final kind in [SwitchKind.archived, SwitchKind.joinable]) {
        expect(
          restore(inChannel, channels: {'c1': channel('c1', kind: kind)}),
          isEmpty,
          reason: kind.name,
        );
      }
    });

    test('a direct message opens', () {
      expect(
        restore(
          inChannel,
          channels: {
            'c1': channel('c1', kind: SwitchKind.direct, teamId: null),
          },
        ).single,
        isA<ChannelTarget>().having((t) => t.teamId, 'team', 't1'),
      );
    });
  });
}
