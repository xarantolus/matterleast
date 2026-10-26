import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/channel_mentions.dart';
import 'package:matterleast/domain/permissions.dart';

const _member = {
  Permission.createPost,
  Permission.editPost,
  Permission.deletePost,
  Permission.addReaction,
  Permission.useChannelMentions,
};
const _admin = {
  ..._member,
  Permission.editOthersPosts,
  Permission.deleteOthersPosts,
};

ChannelPermissions _channel(
  Set<String> granted, {
  bool archived = false,
  bool readOnly = false,
}) => channelPermissions(
  archived: archived,
  readOnly: readOnly,
  granted: granted,
);

final _posted = DateTime.utc(2026, 5, 1, 12);

MessageRights _rights(
  ChannelPermissions channel, {
  bool mine = true,
  Duration? limit,
  DateTime? now,
  int reactions = 0,
}) => messageRights(
  channel,
  mine: mine,
  system: false,
  fromWebhook: false,
  createAt: _posted,
  now: now ?? _posted.add(const Duration(minutes: 1)),
  editTimeLimit: limit,
  distinctReactions: reactions,
);

void main() {
  test('a member edits and deletes only their own messages', () {
    final channel = _channel(_member);
    expect(channel.block, isNull);
    final own = _rights(channel);
    expect(own.edit, isTrue);
    expect(own.delete, isTrue);
    final others = _rights(channel, mine: false);
    expect(others.edit, isFalse);
    expect(others.delete, isFalse);
    expect(others.markUnread, isTrue);
  });

  test("an admin may edit and delete other people's messages", () {
    final others = _rights(_channel(_admin), mine: false);
    expect(others.edit, isTrue);
    expect(others.delete, isTrue);
  });

  test('editing ends when the server edit window has passed', () {
    final channel = _channel(_member);
    const limit = Duration(minutes: 5);
    expect(_rights(channel, limit: limit).edit, isTrue);
    final late = _rights(
      channel,
      limit: limit,
      now: _posted.add(const Duration(minutes: 6)),
    );
    expect(late.edit, isFalse);
    expect(late.delete, isTrue);
  });

  test('archived channels allow only reading', () {
    final channel = _channel(_admin, archived: true);
    expect(channel.block, PostingBlock.archived);
    final r = _rights(channel, mine: false);
    expect([
      r.react,
      r.reply,
      r.pin,
      r.edit,
      r.delete,
      r.markUnread,
    ], everyElement(isFalse));
  });

  test('a read-only channel shows no write actions but can be marked '
      'unread', () {
    final channel = _channel(_member, readOnly: true);
    expect(channel.block, PostingBlock.readOnly);
    final r = _rights(channel, mine: false);
    expect([r.react, r.reply, r.pin, r.edit, r.delete], everyElement(isFalse));
    expect(r.markUnread, isTrue);
  });

  test('without create_post the composer gives way to a notice', () {
    final channel = _channel(_member.difference({Permission.createPost}));
    expect(channel.block, PostingBlock.notAllowed);
    final own = _rights(channel);
    expect(own.reply, isFalse);
    expect(own.edit, isFalse);
    expect(own.delete, isFalse);
    expect(own.react, isTrue);
    expect(own.pin, isTrue);
  });

  test('reactions stop at the server maximum of different emoji', () {
    final channel = _channel(_member);
    expect(_rights(channel, reactions: 39).react, isTrue);
    expect(_rights(channel, reactions: maxDistinctReactions).react, isFalse);
  });

  test('the default channel is read-only for everyone but system admins', () {
    bool readOnly(String name, Set<String> roles) => readOnlyChannel(
      channelName: name,
      townSquareReadOnly: true,
      roles: roles,
    );
    expect(readOnly('town-square', {'system_user'}), isTrue);
    expect(readOnly('town-square', {'system_user', 'system_admin'}), isFalse);
    expect(readOnly('off-topic', {'system_user'}), isFalse);
  });

  test('roles grant what any of them grants', () {
    expect(
      grantedBy(
        {'a', 'b', 'unknown'},
        {
          'a': {'x'},
          'b': {'y'},
        },
      ),
      {'x', 'y'},
    );
  });

  group('channel-wide mentions', () {
    String? ask(
      String text, {
      bool confirm = true,
      bool allowed = true,
      int? members = 20,
    }) => channelMentionQuestion(
      text,
      confirm: confirm,
      allowed: allowed,
      memberCount: members,
    );

    test('ask before notifying a larger channel', () {
      expect(ask('hey @channel'), contains('19 people'));
      expect(ask('@ALL look'), contains('@all or @channel'));
      expect(ask('@here anyone?'), contains('@here'));
    });

    test('send at once when the server, the rights or the size say so', () {
      expect(ask('hey @channel', confirm: false), isNull);
      expect(ask('hey @channel', allowed: false), isNull);
      expect(ask('hey @channel', members: 5), isNull);
      expect(ask('hey @channel', members: null), isNull);
    });

    test('mentions in code, emails and longer names do not count', () {
      expect(ask('`@channel`'), isNull);
      expect(ask('```\n@all\n```\n'), isNull);
      expect(ask('mail me@here.example'), isNull);
      expect(ask('@channelbot hi'), isNull);
      expect(ask('nothing to see'), isNull);
    });
  });
}
