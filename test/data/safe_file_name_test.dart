import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/files/file_handoff.dart';

void main() {
  const cases = {
    'photo.png': 'photo.png',
    'a/b\\c.txt': 'a_b_c.txt',
    'what?: *"<>|.txt': 'what__ _____.txt',
    'tab\tname\n.txt': 'tab_name_.txt',
    'report.': 'report',
    'report. . ': 'report',
    '  spaced.txt  ': 'spaced.txt',
    'CON': '_CON',
    'nul.txt': '_nul.txt',
    'Com1.tar.gz': '_Com1.tar.gz',
    'LPT9': '_LPT9',
    'console.txt': 'console.txt',
    'com10': 'com10',
    '': 'id1.png',
    '..': 'id1.png',
    '...': 'id1.png',
  };
  for (final entry in cases.entries) {
    test('"${entry.key}" becomes "${entry.value}"', () {
      expect(safeFileName(entry.key, 'id1', 'png'), entry.value);
    });
  }

  test('an empty name without an extension falls back to the id', () {
    expect(safeFileName('', 'id1', ''), 'id1');
  });

  test('a long name is cut but keeps its extension', () {
    final result = safeFileName('${'a' * 300}.pdf', 'id1', 'pdf');
    expect(result.length, 120);
    expect(result, endsWith('.pdf'));
  });
}
