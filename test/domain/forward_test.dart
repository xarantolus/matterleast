import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/domain/edit_history.dart';
import 'package:matterleast/domain/forward.dart';

void main() {
  test('a permalink has the server, team and post', () {
    expect(
      postPermalink('https://chat.example.test/', 'crew', 'abc'),
      'https://chat.example.test/crew/pl/abc',
    );
  });

  test('a forward is the comment, then the link on its own line', () {
    const link = 'https://chat.example.test/crew/pl/abc';
    expect(forwardText('  Look  ', link), 'Look\n$link');
    expect(forwardText('', link), link);
    expect(forwardText(' \n ', link), link);
  });

  test("only someone else's sent message can be reported where it is on", () {
    bool report({
      bool enabled = true,
      bool mine = false,
      bool system = false,
      bool unsent = false,
      bool ephemeral = false,
    }) => canReport(
      enabled: enabled,
      mine: mine,
      system: system,
      unsent: unsent,
      ephemeral: ephemeral,
    );
    expect(report(), isTrue);
    expect(report(enabled: false), isFalse);
    expect(report(mine: true), isFalse);
    expect(report(system: true), isFalse);
    expect(report(unsent: true), isFalse);
    expect(report(ephemeral: true), isFalse);
  });

  test('edit versions keep the server order and skip incomplete entries', () {
    final versions = editVersions([
      api.Post.fromJson({'id': 'b', 'edit_at': 2000, 'message': 'two'}),
      api.Post.fromJson({'edit_at': 1500, 'message': 'no id'}),
      api.Post.fromJson({'id': 'a', 'create_at': 1000, 'message': 'one'}),
      api.Post.fromJson({'id': 'c', 'message': 'no time'}),
    ]);
    expect([for (final v in versions) v.id], ['b', 'a']);
    expect(
      versions.last.at,
      DateTime.fromMillisecondsSinceEpoch(1000, isUtc: true),
    );
  });
}
