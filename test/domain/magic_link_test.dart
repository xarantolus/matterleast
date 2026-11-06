import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/magic_link.dart';

void main() {
  final token = 'a1' * 32;

  test('the emailed link names the server and the token', () {
    final link = parseMagicLink(
      Uri.parse('https://chat.example.test/login/one_time_link?t=$token'),
    )!;
    expect(link.server, Uri.parse('https://chat.example.test'));
    expect(link.token, token);
  });

  test('a server under a sub-path and a port keep them', () {
    final link = parseMagicLink(
      Uri.parse('http://example.test:8065/mm/login/one_time_link?t=$token'),
    )!;
    expect(link.server, Uri.parse('http://example.test:8065/mm'));
  });

  test('matterleast:// stands for the same path over https', () {
    final link = parseMagicLink(
      Uri.parse('matterleast://chat.example.test/login/one_time_link?t=$token'),
    )!;
    expect(link.server, Uri.parse('https://chat.example.test'));
  });

  test('anything else is not a magic link', () {
    for (final other in [
      'https://chat.example.test/login/one_time_link',
      'https://chat.example.test/login/one_time_link?t=short',
      'https://chat.example.test/login/one_time_link?t=${token.toUpperCase()}',
      'https://chat.example.test/login?t=$token',
      'https://chat.example.test/one_time_link?t=$token',
      'ftp://chat.example.test/login/one_time_link?t=$token',
      'mmauth://callback?t=$token',
    ]) {
      expect(parseMagicLink(Uri.parse(other)), isNull, reason: other);
    }
  });
}
