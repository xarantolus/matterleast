import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/sso_callback.dart';

void main() {
  group('callback links are kept apart from links to open', () {
    test('any non-web scheme with the callback host is a callback', () {
      expect(isSsoCallbackLink(Uri.parse('mmauth://callback?a=1')), isTrue);
      expect(isSsoCallbackLink(Uri.parse('custom://callback')), isTrue);
    });

    test('web and server links are not', () {
      expect(isSsoCallbackLink(Uri.parse('https://callback/x')), isFalse);
      expect(
        isSsoCallbackLink(Uri.parse('matterleast://chat.example.com/t/pl/1')),
        isFalse,
      );
    });
  });

  group('only the exact redirect shape finishes a sign-in', () {
    const scheme = 'mmauth';
    bool accepted(String link) => isSsoCallbackFor(Uri.parse(link), scheme);

    test('the server redirect is accepted', () {
      expect(
        accepted('mmauth://callback?MMAUTHTOKEN=t&MMCSRF=c&srv=x'),
        isTrue,
      );
      expect(
        isSsoCallbackFor(Uri.parse('MMAUTH://callback?a=1'), 'MMAuth'),
        isTrue,
      );
    });

    test('anything a hand-made link could add is refused', () {
      for (final link in [
        'mmauthbeta://callback?MMAUTHTOKEN=t',
        'mmauth://callback',
        'mmauth://callback?',
        'mmauth://callback/?MMAUTHTOKEN=t',
        'mmauth://callback/x?MMAUTHTOKEN=t',
        'mmauth://user@callback?MMAUTHTOKEN=t',
        'mmauth://callback:80?MMAUTHTOKEN=t',
        'mmauth://callback?MMAUTHTOKEN=t#x',
        'mmauth://other?MMAUTHTOKEN=t',
        'mmauth:callback?MMAUTHTOKEN=t',
      ]) {
        expect(accepted(link), isFalse, reason: link);
      }
    });
  });
}
