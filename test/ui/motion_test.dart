import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/ui/motion.dart';

void main() {
  const duration = Duration(milliseconds: 200);

  Future<Duration> read(WidgetTester tester, bool disabled) async {
    late Duration result;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: disabled),
        child: Builder(
          builder: (context) {
            result = motion(context, duration);
            return const SizedBox();
          },
        ),
      ),
    );
    return result;
  }

  testWidgets('animations run for their duration by default', (tester) async {
    expect(await read(tester, false), duration);
  });

  testWidgets('reduced motion removes the duration', (tester) async {
    expect(await read(tester, true), Duration.zero);
  });
}
