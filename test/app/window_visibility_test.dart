import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/app/desktop/window_visibility.dart';

class _Spinner extends StatefulWidget {
  const _Spinner();
  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  testWidgets(
    'a repeating animation stops drawing frames while the window has no focus',
    (tester) async {
      final visible = ValueNotifier(true);
      await tester.pumpWidget(
        TickersWhile(active: visible, child: const _Spinner()),
      );
      expect(tester.binding.hasScheduledFrame, isTrue);

      visible.value = false;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.binding.hasScheduledFrame, isFalse);

      visible.value = true;
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isTrue);
    },
  );
}
