import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/files/file_handoff.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory dir;
  late File cached;
  const file = PostFile(id: 'f1', name: 'a:b.txt', mimeType: 'text/plain');

  setUp(() {
    dir = Directory.systemTemp.createTempSync('save_as');
    cached = File(p.join(dir.path, 'cached'))..writeAsStringSync('content');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test(
    'the file is copied to the chosen path, even over placeholder bytes',
    () async {
      final target = p.join(dir.path, 'chosen.txt');
      File(target).writeAsBytesSync(const []);
      String? askedName;
      final saved = await FileHandoff.saveAs(
        cached,
        file,
        pick: (name, mime) async {
          askedName = name;
          return target;
        },
      );
      expect(saved, target);
      expect(askedName, 'a_b.txt');
      expect(File(target).readAsStringSync(), 'content');
    },
  );

  test('cancelling the dialog writes nothing', () async {
    final saved = await FileHandoff.saveAs(
      cached,
      file,
      pick: (_, _) async => null,
    );
    expect(saved, isNull);
    expect(dir.listSync(), hasLength(1));
  });
}
