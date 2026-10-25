import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/screens/share/share_screen.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() {
  test('shared text and files become one message with attachments', () {
    final shared = sharedContentOf([
      SharedMediaFile(path: 'Low tide at six.', type: SharedMediaType.text),
      SharedMediaFile(path: '/cache/board.png', type: SharedMediaType.image),
      SharedMediaFile(path: '/cache/notes.pdf', type: SharedMediaType.file),
    ]);
    expect(shared?.text, 'Low tide at six.');
    expect(shared?.files, ['/cache/board.png', '/cache/notes.pdf']);
  });

  test('a link opened in the app is not a share', () {
    expect(
      sharedContentOf([
        SharedMediaFile(
          path: 'matterleast://chat.example.test/crew/channels/boats',
          type: SharedMediaType.url,
        ),
      ]),
      isNull,
    );
    expect(sharedContentOf(const []), isNull);
  });
}
