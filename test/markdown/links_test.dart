import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/markdown/links.dart';

void main() {
  final server = Uri.parse('https://chat.example.test');
  const id = 'abcdefghijklmnopqrstuvwxyz';

  test('a permalink to this server jumps in the app', () {
    expect(
      classifyLink('https://chat.example.test/crew/pl/$id', server),
      const LinkTarget.permalink('crew', id),
    );
  });

  test('a relative permalink resolves against the server', () {
    expect(
      classifyLink('/crew/pl/$id', server),
      const LinkTarget.permalink('crew', id),
    );
  });

  test('a channel link to this server opens the channel', () {
    expect(
      classifyLink('https://chat.example.test/crew/channels/design', server),
      const LinkTarget.channel('crew', 'design'),
    );
  });

  test('the same path on another host opens outside', () {
    expect(
      classifyLink('https://other.example.test/crew/pl/$id', server),
      isA<ExternalLink>(),
    );
  });

  test('a link without a scheme opens as http', () {
    expect(
      classifyLink('example.test/path', server),
      LinkTarget.external(Uri.parse('http://example.test/path')),
    );
  });

  test('unknown schemes open nothing', () {
    expect(
      classifyLink('javascript:alert(1)', server),
      const LinkTarget.none(),
    );
  });
}
