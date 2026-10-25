import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/json/post_extras.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/system_message.dart';

PostItem _system(String id, String type, String props, int minute) => PostItem(
  id: id,
  key: id,
  userId: 'u',
  authorName: 'admin',
  createAt: DateTime(2026, 10, 25, 10, minute),
  message: 'server text',
  type: type,
  propsJson: props,
);

void main() {
  group('wording', () {
    test('a new header says what it became', () {
      expect(
        systemMessageText(
          'system_header_change',
          const PostProps(username: 'admin', newHeader: 'Reviews on Tuesdays'),
          '',
        ),
        'admin updated the channel header to: Reviews on Tuesdays',
      );
    });

    test('a changed purpose says from what to what', () {
      expect(
        systemMessageText(
          'system_purpose_change',
          const PostProps(username: 'bob', oldPurpose: 'a', newPurpose: 'b'),
          '',
        ),
        'bob updated the channel purpose from: a to: b',
      );
    });

    test('a removed display name says what it was', () {
      expect(
        systemMessageText(
          'system_displayname_change',
          const PostProps(username: 'bob', oldDisplayname: 'Old'),
          '',
        ),
        'bob removed the channel display name (was: Old)',
      );
    });

    test('other system messages keep the server text', () {
      expect(
        systemMessageText('system_generic', const PostProps(), 'as sent'),
        'as sent',
      );
    });

    test('several people are joined with commas and "and"', () {
      expect(
        activityText(Activity.addedToChannel, [
          (subject: 'bob', actor: 'admin'),
          (subject: 'carol', actor: 'admin'),
          (subject: 'erin', actor: 'admin'),
        ]),
        'bob, carol and erin added to the channel by admin.',
      );
    });
  });

  group('combining', () {
    test('consecutive joins become one line, other kinds stay apart', () {
      final rows = buildRows(
        [
          _system('c', 'system_leave_channel', '{"username":"carol"}', 3),
          _system('b', 'system_join_channel', '{"username":"bob"}', 2),
          _system('a', 'system_join_channel', '{"username":"alice"}', 1),
        ],
        lastViewedAt: null,
        myUserId: null,
      ).whereType<MessageRow>().toList();
      expect(rows.length, 2);
      final joined = rows.firstWhere((r) => r.post.id == 'a');
      expect([for (final p in joined.combined) p.id], ['b']);
    });

    test('additions by different people stay apart', () {
      final rows = buildRows(
        [
          _system(
            'b',
            'system_add_to_channel',
            '{"username":"bob","addedUsername":"erin"}',
            2,
          ),
          _system(
            'a',
            'system_add_to_channel',
            '{"username":"admin","addedUsername":"dave"}',
            1,
          ),
        ],
        lastViewedAt: null,
        myUserId: null,
      ).whereType<MessageRow>();
      expect(rows.length, 2);
    });
  });
}
