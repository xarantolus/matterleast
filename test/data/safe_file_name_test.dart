import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/files/file_handoff.dart';

void main() {
  final cases = {
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
    'x&calc&.txt': 'x_calc_.txt',
    '%PATH%^a;b.txt': '_PATH__a_b.txt',
    'gpj.${String.fromCharCode(0x202e)}txt': 'gpj._txt',
    'iso${String.fromCharCode(0x2066)}late.txt': 'iso_late.txt',
    '': 'id1.png',
    '..': 'id1.png',
    '...': 'id1.png',
  };
  for (final entry in cases.entries) {
    test('"${entry.key}" becomes "${entry.value}"', () {
      expect(safeFileName(entry.key, 'id1', 'png'), entry.value);
    });
  }

  group('programs are never opened', () {
    for (final name in ['setup.EXE', 'a.bat', 'x.lnk', 'x.ps1', 'a.b.hta']) {
      test('$name on Windows', () {
        expect(isProgramFile(name, windows: true), isTrue);
      });
    }
    for (final name in ['run.sh', 'x.AppImage', 'a.desktop', 'i.run']) {
      test('$name on Linux', () {
        expect(isProgramFile(name, windows: false), isTrue);
      });
    }
    test('documents and pictures are', () {
      for (final windows in [true, false]) {
        for (final name in ['a.pdf', 'p.png', 'exe', 'notes.txt.sh.txt']) {
          expect(isProgramFile(name, windows: windows), isFalse);
        }
      }
    });
    test('each platform has its own list', () {
      expect(isProgramFile('a.sh', windows: true), isFalse);
      expect(isProgramFile('a.exe', windows: false), isFalse);
    });
  });

  test('an empty name without an extension falls back to the id', () {
    expect(safeFileName('', 'id1', ''), 'id1');
  });

  test('a long name is cut but keeps its extension', () {
    final result = safeFileName('${'a' * 300}.pdf', 'id1', 'pdf');
    expect(result.length, 120);
    expect(result, endsWith('.pdf'));
  });
}
