import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:matterleast/notifications/notice_format.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:matterleast/notifications/notify_rules.dart';

final _t0 = DateTime.utc(2026, 3, 1, 12);

NoticeMessage _message(String text, int minute, {String sender = 'u-bob'}) =>
    NoticeMessage(
      senderId: sender,
      senderName: sender == 'u-bob' ? 'Bob' : 'Cleo',
      text: text,
      at: _t0.add(Duration(minutes: minute)),
    );

ConversationNotice _notice({
  String channel = 'town',
  NotifyKind kind = NotifyKind.direct,
  bool group = true,
  List<NoticeMessage>? messages,
  Uint8List? largeIcon,
}) {
  final list = messages ?? [_message('first', 1), _message('second', 2)];
  return ConversationNotice(
    serverUrl: 'https://chat.example.test',
    key: ConversationKey(channel),
    kind: kind,
    title: 'Town Square',
    group: group,
    messages: list,
    newestPostId: 'p-newest',
    newestAt: list.last.at,
    largeIcon: largeIcon,
  );
}

Uint8List _png(int width, int height) => img.encodePng(
  img.Image(width: width, height: height, numChannels: 4)
    ..clear(img.ColorRgba8(200, 40, 40, 255)),
);

AndroidNotificationDetails _details(
  ConversationNotice notice, {
  DateTime? now,
}) => Notifier.detailsOf(notice, now: now ?? _t0.add(const Duration(hours: 1)));

/// How Android's shade orders notifications of one app: by importance, then
/// priority, then the time they are dated, newest first.
List<String> _shadeOrder(Map<String, AndroidNotificationDetails> shown) {
  final importance = {
    for (final c in [
      NoticeChannels.direct,
      NoticeChannels.thread,
      NoticeChannels.other,
    ])
      c.id: c.importance.value,
  };
  final entries = shown.entries.toList()
    ..sort((a, b) {
      final (x, y) = (a.value, b.value);
      return switch (importance[y.channelId]!.compareTo(
        importance[x.channelId]!,
      )) {
        0 => switch (y.priority.value.compareTo(x.priority.value)) {
          0 => y.when!.compareTo(x.when!),
          final c => c,
        },
        final c => c,
      };
    });
  return [for (final e in entries) e.key];
}

void main() {
  group('heading', () {
    test('a direct message is headed by its sender alone', () {
      expect(
        noticeHeading(channelType: 'D', name: 'Bob Stone', thread: false),
        (title: 'Bob Stone', group: false),
      );
    });

    test('a channel or group message is headed by its name', () {
      expect(
        noticeHeading(channelType: 'O', name: 'Town Square', thread: false),
        (title: 'Town Square', group: true),
      );
      expect(
        noticeHeading(channelType: 'G', name: 'bob, cleo', thread: false),
        (title: 'bob, cleo', group: true),
      );
    });

    test('a collapsed-thread reply names where the thread is', () {
      expect(noticeHeading(channelType: 'P', name: 'Garden', thread: true), (
        title: 'Reply in Garden',
        group: true,
      ));
      expect(noticeHeading(channelType: 'D', name: 'Bob Stone', thread: true), (
        title: 'Reply in Direct Message',
        group: true,
      ));
    });

    test('server and team are named only when given', () {
      expect(noticeSubText(), isNull);
      expect(noticeSubText(serverName: 'Home'), 'Home');
      expect(noticeSubText(teamName: 'Crew'), 'Crew');
      expect(
        noticeSubText(serverName: 'Home', teamName: 'Crew'),
        'Home · Crew',
      );
    });
  });

  group('desktop toast', () {
    test('a direct message: the sender above, the message below', () {
      expect(
        toastText(title: 'Bob Stone', group: false, sender: 'Bob', text: 'hi'),
        (title: 'Bob Stone', body: 'hi'),
      );
    });

    test('a channel names the sender in the body and its server', () {
      expect(
        toastText(
          title: 'Town Square',
          group: true,
          sender: 'Bob Stone',
          text: 'lunch?',
          subText: 'Home · Crew',
        ),
        (title: 'Town Square · Home · Crew', body: 'Bob Stone: lunch?'),
      );
    });
  });

  group('details', () {
    test('messages stay oldest first, dated by their posts', () {
      final details = _details(
        _notice(
          messages: [
            _message('one', 1),
            _message('two', 5, sender: 'u-cleo'),
            _message('three', 9),
          ],
        ),
      );
      final style = details.styleInformation! as MessagingStyleInformation;
      expect(style.messages!.map((m) => m.text), ['one', 'two', 'three']);
      expect(style.messages!.map((m) => m.timestamp), [
        _t0.add(const Duration(minutes: 1)),
        _t0.add(const Duration(minutes: 5)),
        _t0.add(const Duration(minutes: 9)),
      ]);
      expect(style.messages!.map((m) => m.person!.name), [
        'Bob',
        'Cleo',
        'Bob',
      ]);
      expect(
        details.when,
        _t0.add(const Duration(minutes: 9)).millisecondsSinceEpoch,
      );
      expect(details.showWhen, isTrue);
    });

    test('a channel shows its name over the senders', () {
      final details = _details(_notice());
      final style = details.styleInformation! as MessagingStyleInformation;
      expect(style.conversationTitle, 'Town Square');
      expect(style.groupConversation, isTrue);
      expect(details.largeIcon, isNull);
    });

    test('a direct message shows the sender with their picture', () {
      final picture = _png(8, 8);
      final details = _details(_notice(group: false, largeIcon: picture));
      final style = details.styleInformation! as MessagingStyleInformation;
      expect(style.conversationTitle, isNull);
      expect(style.groupConversation, isFalse);
      expect((details.largeIcon! as ByteArrayAndroidBitmap).data, picture);
    });

    test('the newest conversation comes first, whatever its kind', () {
      NoticeMessage at(int minute) => _message('hi', minute);
      final order = _shadeOrder({
        'direct, oldest': _details(_notice(channel: 'dm', messages: [at(1)])),
        'thread': _details(
          _notice(channel: 't', kind: NotifyKind.thread, messages: [at(2)]),
        ),
        'channel, newest': _details(
          _notice(channel: 'c', kind: NotifyKind.other, messages: [at(3)]),
        ),
      });
      expect(order, ['channel, newest', 'thread', 'direct, oldest']);
    });

    test('a server clock ahead of the phone does not date it later', () {
      final now = _t0.add(const Duration(minutes: 2));
      final details = _details(
        _notice(messages: [_message('ahead', 3)]),
        now: now,
      );
      expect(details.when, now.millisecondsSinceEpoch);
    });

    test('reply and mark as read are offered', () {
      final details = _details(_notice());
      expect(details.actions!.map((a) => a.id), [
        NoticeActions.reply,
        NoticeActions.read,
      ]);
      expect(details.actions!.first.inputs, isNotEmpty);
    });
  });

  group('avatar', () {
    test('comes out round and at the asked size', () {
      final round = img.decodePng(roundAvatar(_png(300, 200), size: 64)!)!;
      expect((round.width, round.height), (64, 64));
      expect(round.getPixel(0, 0).a, 0);
      expect(round.getPixel(63, 63).a, 0);
      expect(round.getPixel(32, 32).a, 255);
      expect(round.getPixel(32, 32).r, 200);
    });

    test('is left out when the bytes are no image', () {
      expect(roundAvatar(Uint8List.fromList([1, 2, 3, 4])), isNull);
    });
  });
}
