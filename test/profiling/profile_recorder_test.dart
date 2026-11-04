import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/profiling/profile_recorder.dart';

void main() {
  testWidgets('outside profile builds nothing is recorded', (tester) async {
    final dispatcher = tester.binding.platformDispatcher;
    final before = dispatcher.onReportTimings;

    await ProfileRecorder.start();

    expect(dispatcher.onReportTimings, same(before));
  });
}
