import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/emoji_rules.dart';
import 'package:matterleast/domain/permissions.dart';

void main() {
  group('a new emoji name', () {
    String? problem(String name, {Set<String> taken = const {}}) =>
        emojiNameProblem(name, taken: taken.contains);

    test('accepts letters, digits, - _ and +, capitals too', () {
      for (final ok in [
        'party',
        'PartyBlob',
        'a',
        'ship-it',
        'x_1',
        '+1ish',
        'a' * 64,
      ]) {
        expect(problem(ok), isNull, reason: ok);
      }
    });

    test('refuses what the server refuses', () {
      for (final bad in [
        '',
        'a' * 65,
        'two words',
        'dot.name',
        'colon:',
        'ünï',
      ]) {
        expect(problem(bad), isNotNull, reason: bad);
      }
    });

    test('refuses a name already used', () {
      expect(problem('party', taken: {'party'}), isNotNull);
      expect(problem('parties', taken: {'party'}), isNull);
      // The server keeps names in lowercase.
      expect(problem('Party', taken: {'party'}), isNotNull);
    });
  });

  group('an emoji image', () {
    test('is a small PNG, JPEG or GIF', () {
      for (final name in ['a.png', 'a.JPG', 'a.jpeg', 'a.gif', 'x.y.png']) {
        expect(emojiImageProblem(fileName: name, bytes: 1000), isNull);
      }
      expect(
        emojiImageProblem(fileName: 'a.png', bytes: maxEmojiImageBytes),
        isNull,
      );
    });

    test('refuses other types and big files', () {
      for (final name in ['a.webp', 'a.pdf', 'png', '']) {
        expect(emojiImageProblem(fileName: name, bytes: 1000), isNotNull);
      }
      expect(
        emojiImageProblem(fileName: 'a.png', bytes: maxEmojiImageBytes + 1),
        isNotNull,
      );
    });
  });

  test('the suggested name is a valid one from the file name', () {
    expect(suggestedEmojiName('Party Blob (2).PNG'), 'party_blob_2');
    expect(suggestedEmojiName('ship-it.gif'), 'ship-it');
    expect(suggestedEmojiName('${'a' * 80}.png'), 'a' * 64);
    expect(suggestedEmojiName('.png'), isNot(contains('.')));
  });

  group('rights', () {
    final granted = {
      'system_user': {Permission.createEmojis, Permission.deleteEmojis},
      'system_admin': {Permission.deleteOthersEmojis},
    };

    test('follow the roles', () {
      Can can(String roles) =>
          haveISystemPermission(systemRoles: roles, granted: granted);
      final user = emojiRights(enabled: true, can: can('system_user'));
      expect(user, (create: true, deleteOwn: true, deleteOthers: false));
      final admin = emojiRights(
        enabled: true,
        can: can('system_user system_admin'),
      );
      expect(admin.deleteOthers, isTrue);
    });

    test('are none when the server has custom emoji off', () {
      expect(
        emojiRights(
          enabled: false,
          can: haveISystemPermission(
            systemRoles: 'system_user',
            granted: granted,
          ),
        ),
        noEmojiRights,
      );
    });

    test('deleting needs the right for whose emoji it is', () {
      const own = (create: false, deleteOwn: true, deleteOthers: false);
      expect(mayDeleteEmoji(own, creatorId: 'me', me: 'me'), isTrue);
      expect(mayDeleteEmoji(own, creatorId: 'you', me: 'me'), isFalse);
    });
  });

  test('the server is asked only for a typed term with few local matches', () {
    expect(asksServerForEmoji('p', 0), isFalse);
    expect(asksServerForEmoji('pa', 0), isTrue);
    expect(asksServerForEmoji('pa', serverSearchBelow), isFalse);
  });
}
