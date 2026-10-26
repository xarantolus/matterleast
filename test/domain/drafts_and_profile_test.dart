import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/drafts.dart';
import 'package:matterleast/domain/people.dart';
import 'package:matterleast/domain/profile_locks.dart';
import 'package:matterleast/domain/server_features.dart';

ChannelInput _channel(String id, String type, String name, String display) => (
  id: id,
  type: type,
  name: name,
  displayName: display,
  archived: false,
  createAt: null,
  lastPostAt: null,
  lastRootPostAt: null,
  totalMsgCount: 0,
  totalMsgCountRoot: 0,
  msgCount: 0,
  msgCountRoot: 0,
  mentionCount: 0,
  mentionCountRoot: 0,
  muted: false,
  lastViewedAt: null,
);

DraftInput _draft(
  String channelId,
  String message, {
  String rootId = '',
  int files = 0,
  int minute = 0,
}) => (
  channelId: channelId,
  rootId: rootId,
  message: message,
  files: files,
  updatedAt: DateTime.utc(2026, 4, 2, 9, minute),
);

void main() {
  group('drafts list', () {
    final channels = {
      'c1': _channel('c1', 'O', 'garden', 'Garden'),
      'd1': _channel('d1', 'D', 'me__pat', 'pat'),
    };
    final people = <String, PersonInput>{
      'pat': (
        username: 'pat',
        firstName: 'Pat',
        lastName: 'Lee',
        nickname: '',
        status: 'online',
      ),
    };
    List<DraftItem> build(List<DraftInput> drafts) => buildDraftList(
      drafts,
      channels: channels,
      myId: 'me',
      people: people,
      nameFormat: NameFormat.fullName,
    );

    test('newest first, named by channel or person, with a one-line '
        'preview', () {
      final items = build([
        _draft('c1', '**Water** the _plants_', minute: 1),
        _draft('d1', 'see you', rootId: 'root1', minute: 5),
      ]);
      expect(items.map((d) => d.title), ['Pat Lee', '#Garden']);
      expect(items.first.rootId, 'root1');
      expect(items.first.userId, 'pat');
      expect(items.last.preview, 'Water the plants');
    });

    test('a draft of only files says how many', () {
      expect(build([_draft('c1', '', files: 2)]).single.preview, '2 files');
    });

    test('empty drafts and those of channels left are not listed', () {
      expect(build([_draft('c1', '  '), _draft('gone', 'hello')]), isEmpty);
    });
  });

  group('profile locks', () {
    test('a password user may change everything', () {
      final locks = profileLocks('', ldap: {}, saml: {});
      expect([
        locks.firstName,
        locks.lastName,
        locks.nickname,
        locks.position,
        locks.username,
        locks.picture,
        locks.password,
      ], everyElement(isFalse));
    });

    test('LDAP locks the fields the directory fills, and the username', () {
      final locks = profileLocks(
        'ldap',
        ldap: {ProfileField.firstName, ProfileField.picture},
        saml: {ProfileField.lastName},
      );
      expect(locks.firstName, isTrue);
      expect(locks.lastName, isFalse);
      expect(locks.picture, isTrue);
      expect(locks.username, isTrue);
      expect(locks.password, isTrue);
      expect(locks.source, 'LDAP');
    });

    test('GitLab keeps the names; the picture stays the user own', () {
      final locks = profileLocks(
        'gitlab',
        ldap: {ProfileField.picture},
        saml: {},
      );
      expect(locks.firstName, isTrue);
      expect(locks.lastName, isTrue);
      expect(locks.nickname, isFalse);
      expect(locks.picture, isFalse);
    });
  });
}
