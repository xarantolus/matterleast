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
}
