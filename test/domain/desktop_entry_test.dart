import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/desktop_entry.dart';

void main() {
  const exe = '/opt/Matter least/matterleast';
  const icon = '/opt/Matter least/matterleast.png';

  String? decide({
    Map<String, String> env = const {},
    String executable = exe,
    String? existing,
  }) => desktopEntryToWrite(
    environment: env,
    executable: executable,
    iconPath: icon,
    existing: existing,
  );

  final written = decide()!;

  test('a first start writes the entry for this binary', () {
    expect(written, contains('Exec="$exe" %u\n'));
    expect(written, contains('Icon=$icon\n'));
    expect(written, contains('MimeType=x-scheme-handler/mmauth;\n'));
  });

  test('an entry that already points here is left alone', () {
    expect(decide(existing: written), isNull);
  });

  test('a moved folder rewrites the entry', () {
    final moved = decide(
      executable: '/home/u/new/matterleast',
      existing: written,
    );
    expect(moved, contains('Exec="/home/u/new/matterleast" %u\n'));
  });

  test('a Flatpak or an AppImage writes nothing', () {
    expect(decide(env: {'FLATPAK_ID': 'x'}), isNull);
    expect(decide(env: {'APPIMAGE': '/tmp/x.AppImage'}), isNull);
  });

  test('a path a launcher entry cannot quote writes nothing', () {
    expect(decide(executable: '/opt/a"b/matterleast'), isNull);
    expect(decide(executable: 'matterleast'), isNull);
  });

  test('without the bundled icon the entry names the themed icon', () {
    final plain = desktopEntryToWrite(
      environment: const {},
      executable: exe,
      iconPath: null,
      existing: null,
    );
    expect(plain, contains('Icon=io.github.xarantolus.matterleast\n'));
  });
}
