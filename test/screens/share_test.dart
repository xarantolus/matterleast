import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/screens/share/share_screen.dart';
import 'package:path/path.dart' as p;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() {
  const cache = '/data/user/0/app/cache';

  // Resolves `..` like the file system would; a link in the cache folder
  // that points at the app's files resolves to its target.
  String? resolve(String path) => switch (p.normalize(path)) {
    '$cache/innocent.png' => '/data/user/0/app/files/app.sqlite',
    final normal => normal,
  };

  SharedContent? share(List<SharedMediaFile> media) =>
      sharedContentOf(media, cacheDir: cache, resolve: resolve);

  test('shared text and files become one message with attachments', () {
    final shared = share([
      SharedMediaFile(path: 'Low tide at six.', type: SharedMediaType.text),
      SharedMediaFile(path: '$cache/board.png', type: SharedMediaType.image),
      SharedMediaFile(path: '$cache/notes.pdf', type: SharedMediaType.file),
    ]);
    expect(shared?.text, 'Low tide at six.');
    expect(shared?.files, ['$cache/board.png', '$cache/notes.pdf']);
    expect(shared?.refused, isEmpty);
  });

  test('files outside the cache folder are refused and named', () {
    final shared = share([
      SharedMediaFile(
        path: '/data/user/0/app/files/server-chat.sqlite',
        type: SharedMediaType.file,
      ),
      SharedMediaFile(
        path: '$cache/../files/app.sqlite',
        type: SharedMediaType.file,
      ),
      SharedMediaFile(path: '$cache/innocent.png', type: SharedMediaType.image),
      SharedMediaFile(
        path: '/storage/emulated/0/Download/plan.pdf',
        type: SharedMediaType.file,
      ),
    ]);
    expect(shared?.files, isEmpty);
    expect(shared?.refused, [
      'server-chat.sqlite',
      'app.sqlite',
      'innocent.png',
      'plan.pdf',
    ]);
  });

  test('a file that is gone is refused', () {
    final shared = sharedContentOf(
      [SharedMediaFile(path: '$cache/gone.png', type: SharedMediaType.image)],
      cacheDir: cache,
      resolve: (_) => null,
    );
    expect(shared?.refused, ['gone.png']);
  });

  test('files over the server limit are left out', () {
    final sizes = {'$cache/a.png': 900, '$cache/b.mp4': 2000, '$cache/c': null};
    expect(filesWithinLimit(sizes, 1000), ['$cache/a.png', '$cache/c']);
    expect(filesWithinLimit(sizes, null), sizes.keys);
  });

  test('a link opened in the app is not a share', () {
    expect(
      share([
        SharedMediaFile(
          path: 'matterleast://chat.example.test/crew/channels/boats',
          type: SharedMediaType.url,
        ),
      ]),
      isNull,
    );
    expect(share(const []), isNull);
  });
}
