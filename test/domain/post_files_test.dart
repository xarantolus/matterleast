import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/post_details.dart';
import 'package:matterleast/domain/post_files.dart';

void main() {
  group('files in a post', () {
    test('attached files are read in order, deleted ones left out', () {
      final details = PostDetails.decode(
        null,
        '{"files":['
        '{"id":"a","name":"Shot.PNG","extension":"PNG","mime_type":"image/png",'
        '"size":2048,"width":640,"height":480,"has_preview_image":true,'
        '"mini_preview":"AAEC"},'
        '{"id":"b","name":"gone.txt","delete_at":1700000000000},'
        '{"id":"c","name":"notes.pdf","extension":"pdf"}]}',
      );
      expect([for (final f in details.files) f.id], ['a', 'c']);
      final shot = details.files.first;
      expect(shot.kind, FileKind.image);
      expect((shot.width, shot.height, shot.hasPreview), (640, 480, true));
      expect(shot.miniPreview, [0, 1, 2]);
      expect(details.files.last.kind, FileKind.pdf);
    });

    test('kinds come from the extension first, then the type', () {
      FileKind kind(String ext, [String mime = '']) =>
          fileKindOf(extension: ext, mimeType: mime);
      expect(kind('gif'), FileKind.gif);
      expect(kind('', 'image/gif'), FileKind.gif);
      expect(kind('jpeg'), FileKind.image);
      expect(kind('mp4'), FileKind.video);
      expect(kind('', 'video/webm'), FileKind.video);
      expect(kind('dart'), FileKind.text);
      expect(kind('', 'text/plain'), FileKind.text);
      expect(kind('svg', 'image/svg+xml'), FileKind.other);
      expect(kind('zip', 'application/zip'), FileKind.other);
    });

    test('sizes read like people write them', () {
      expect(formatBytes(38), '38 B');
      expect(formatBytes(1536), '1.5 KB');
      expect(formatBytes(20000), '20 KB');
      expect(formatBytes(3 * 1024 * 1024), '3.0 MB');
    });

    test('a grid shows four at most and counts the rest', () {
      expect(mediaGridRows(1).rows, [
        [0],
      ]);
      expect(mediaGridRows(3).rows, [
        [0],
        [1, 2],
      ]);
      final five = mediaGridRows(5);
      expect(five.rows.expand((r) => r), [0, 1, 2, 3]);
      expect(five.hidden, 1);
    });

    test('the original replaces the preview only when zoomed past it', () {
      const big = PostFile(id: 'a', name: 'a', width: 4000, hasPreview: true);
      const small = PostFile(id: 'b', name: 'b', width: 800, hasPreview: true);
      bool needs(PostFile f, double scale) => needsOriginal(
        file: f,
        scale: scale,
        shownWidth: 400,
        pixelRatio: 2.5,
      );
      expect(needs(big, 1), isFalse);
      expect(needs(big, 2.5), isTrue);
      expect(needs(small, 5), isFalse);
    });
  });
}
