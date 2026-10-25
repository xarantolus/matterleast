import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';

void main() {
  test('a new server is named after its site unless that name is taken', () {
    final url = Uri.parse('http://10.0.2.2:8067');
    expect(defaultDisplayName('Team Chat', url, []), 'Team Chat');
    expect(
      defaultDisplayName('Mattermost', url, ['Mattermost']),
      '10.0.2.2:8067',
    );
    expect(
      defaultDisplayName(' ', Uri.parse('https://chat.example.test'), []),
      'chat.example.test',
    );
  });

  test('initials take the first letters of two words', () {
    expect(initialsOf('Team Chat'), 'TC');
    expect(initialsOf('alice'), 'AL');
    expect(initialsOf('chat.example.test'), 'CE');
    expect(initialsOf(''), '?');
  });
}
