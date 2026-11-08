import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/ui/file_icon.dart';

double _luminance(Color c) => c.computeLuminance();

void main() {
  test('white text on every file type tile reads at 4.5:1', () {
    for (final ext in [
      'pdf',
      'docx',
      'xlsx',
      'pptx',
      'zip',
      'mp3',
      'txt',
      'bin',
      '',
    ]) {
      final ratio = 1.05 / (_luminance(fileTypeColor(ext)) + 0.05);
      expect(ratio, greaterThanOrEqualTo(4.5), reason: ext);
    }
  });
}
