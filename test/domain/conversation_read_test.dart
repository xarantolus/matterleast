import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/conversation_read.dart';

void main() {
  final cases = <(String, bool, bool, bool, bool, bool)>[
    // name, atNewest, inFront, pending, ready, expected
    ('newest in view, in front, something new', true, true, true, true, true),
    ('scrolled up', false, true, true, true, false),
    ('window in the background', true, false, true, true, false),
    ('nothing new since the last mark', true, true, false, true, false),
    ('opening refresh still running', true, true, true, false, false),
  ];
  for (final (name, newest, front, pending, ready, expected) in cases) {
    test(name, () {
      expect(
        shouldMarkRead(
          atNewest: newest,
          inFront: front,
          pending: pending,
          ready: ready,
        ),
        expected,
      );
    });
  }
}
