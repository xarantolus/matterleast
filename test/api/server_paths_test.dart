import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/server_paths.dart';

void main() {
  final server = Uri.parse('https://chat.example.test');
  final sub = Uri.parse('https://chat.example.test/team');

  bool carries(String url, [Uri? on]) =>
      carriesToken(Uri.parse(url), on ?? server);

  test('the API and plugin routes of the server carry the token', () {
    expect(carries('https://chat.example.test/api/v4/users/me'), isTrue);
    expect(carries('https://chat.example.test/plugins/x/file'), isTrue);
    expect(carries('https://chat.example.test/team/api/v4/users', sub), isTrue);
  });

  test('other hosts and other paths do not', () {
    expect(carries('https://other.test/api/v4/users/me'), isFalse);
    expect(carries('https://chat.example.test/static/a.png'), isFalse);
    expect(carries('https://chat.example.test/team/api/v4/x'), isFalse);
  });

  test('dot segments are resolved before the path is checked', () {
    expect(carries('https://chat.example.test/api/v4/../../static/a'), isFalse);
    expect(carries('https://chat.example.test/api/v4/%2e%2e/x/y'), isFalse);
    expect(carries('https://chat.example.test/static/../api/v4/users'), isTrue);
    expect(carries('https://chat.example.test/team/../api/v4/x', sub), isFalse);
    expect(
      carries('https://chat.example.test/team/api/v4/./users', sub),
      isTrue,
    );
  });
}
