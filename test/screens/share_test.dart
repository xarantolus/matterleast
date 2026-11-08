import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/screens/share/share_screen.dart';
import 'package:path/path.dart' as p;
import 'package:share_intake/share_intake.dart';

void main() {
  const cache = '/data/user/0/app/cache';
  const share = '$cache/share/0b9d3c4e-5f60-4a71-8b92-a3b4c5d6e7f8';

  // Resolves `..` like the file system would; a link in the share folder
  // that points at the app's files resolves to its target.
  String? resolve(String path) => switch (p.normalize(path)) {
    '$share/innocent.png' => '/data/user/0/app/files/app.sqlite',
    final normal => normal,
  };

  SharedContent? content(IncomingShare shared) =>
      sharedContentOf(shared, cacheDir: cache, resolve: resolve);

  SharedFile file(String path) =>
      SharedFile(path: path, name: p.basename(path));

  test('shared text and files become one message with attachments', () {
    final shared = content(
      IncomingShare(
        text: 'Low tide at six.',
        files: [file('$share/board.png'), file('$share/notes.pdf')],
      ),
    );
    expect(shared?.text, 'Low tide at six.');
    expect(shared?.files, ['$share/board.png', '$share/notes.pdf']);
    expect(shared?.refused, isEmpty);
  });

  test('files outside a share folder are refused and named', () {
    final shared = content(
      IncomingShare(
        files: [
          file('/data/user/0/app/files/server-chat.sqlite'),
          file('$share/../../../files/app.sqlite'),
          file('$share/innocent.png'),
          file('$cache/loose.png'),
          file('/storage/emulated/0/Download/plan.pdf'),
        ],
      ),
    );
    expect(shared?.files, isEmpty);
    expect(shared?.refused, [
      'server-chat.sqlite',
      'app.sqlite',
      'innocent.png',
      'loose.png',
      'plan.pdf',
    ]);
  });

  test('files the phone could not copy are named', () {
    final shared = content(const IncomingShare(refused: ['Holiday.mov']));
    expect(shared?.files, isEmpty);
    expect(shared?.refused, ['Holiday.mov']);
  });

  test('a file that is gone is refused', () {
    final shared = sharedContentOf(
      IncomingShare(files: [file('$share/gone.png')]),
      cacheDir: cache,
      resolve: (_) => null,
    );
    expect(shared?.refused, ['gone.png']);
  });

  test('files over the server limit are left out', () {
    final sizes = {'$share/a.png': 900, '$share/b.mp4': 2000, '$share/c': null};
    expect(filesWithinLimit(sizes, 1000), ['$share/a.png', '$share/c']);
    expect(filesWithinLimit(sizes, null), sizes.keys);
  });

  test('an empty share shows nothing', () {
    expect(content(const IncomingShare(text: '  ')), isNull);
  });

  test('platform calls become share events, skipping what is malformed', () {
    final event = ShareIntake.eventOf('shared', {
      'text': 'Low tide',
      'files': [
        {'path': '$share/a.png', 'name': 'a.png', 'mime': 'image/png'},
        {'path': 7},
        'nonsense',
      ],
      'refused': ['b.mov', 3],
      'target': 'chat',
    });
    if (event is! ShareArrived) fail('not a share: $event');
    final shared = event.share;
    expect(shared.text, 'Low tide');
    expect(shared.files.single.mime, 'image/png');
    expect(shared.refused, ['b.mov']);
    expect(shared.target, 'chat');
    expect(
      ShareIntake.eventOf('progress', {'done': 10, 'total': -1}),
      isA<ShareProgress>().having((e) => e.total, 'total', isNull),
    );
    expect(ShareIntake.eventOf('unknown', null), isNull);
  });
}
