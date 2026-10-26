import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/markdown/links.dart';

void main() {
  final server = Uri.parse('https://chat.example.test');

  test('a server-relative link resolves against the server', () {
    expect(
      classifyLink('/crew/channels/design', server),
      LinkTarget.uri(
        Uri.parse('https://chat.example.test/crew/channels/design'),
      ),
    );
  });

  test('a link without a scheme opens as http', () {
    expect(
      classifyLink('example.test/path', server),
      LinkTarget.uri(Uri.parse('http://example.test/path')),
    );
  });

  test('unknown schemes open nothing', () {
    expect(
      classifyLink('javascript:alert(1)', server),
      const LinkTarget.none(),
    );
  });

  test('links that would reach into the phone open nothing, in any case', () {
    for (final url in [
      'JAVASCRIPT:alert(1)',
      'intent://scan/#Intent;scheme=zxing;end',
      'file:///data/data/app/databases/server.sqlite',
      'content://com.example.provider/secret',
      'data:text/html,<b>hi</b>',
    ]) {
      expect(classifyLink(url, server), const LinkTarget.none(), reason: url);
    }
  });

  test('web, mail and phone links open, whatever the case of the scheme', () {
    for (final url in [
      'HTTPS://example.test/a',
      'mailto:crew@example.test',
      'tel:+4930123456',
    ]) {
      expect(classifyLink(url, server), isA<UriLink>(), reason: url);
    }
  });

  test('a link to another host without a scheme is not the server', () {
    final target = classifyLink('//other.example.test/x', server);
    expect(target, isA<UriLink>());
    expect((target as UriLink).uri.host, 'other.example.test');
  });
}
