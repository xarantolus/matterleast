import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/screens/channel/typing_line.dart';

void main() {
  Future<({double gap, double line})> measure(
    WidgetTester tester,
    TargetPlatform platform, {
    double scale = 1,
  }) async {
    debugDefaultTargetPlatformOverride = platform;
    late double gap;
    late double line;
    await tester.pumpWidget(
      MaterialApp(
        theme: MatterleastApp.lightTheme,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: Builder(
            builder: (context) {
              gap = conversationBottomGap(context);
              line = typingLineHeight(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    debugDefaultTargetPlatformOverride = null;
    return (gap: gap, line: line);
  }

  testWidgets('the gap is smaller on desktop and holds the typing line', (
    tester,
  ) async {
    final phone = await measure(tester, TargetPlatform.android);
    final desktop = await measure(tester, TargetPlatform.linux);
    expect(desktop.gap, lessThan(phone.gap));
    expect(desktop.gap, greaterThan(desktop.line));
    expect(phone.gap, greaterThan(phone.line));
  });

  testWidgets('a larger text size makes room for a taller typing line', (
    tester,
  ) async {
    final normal = await measure(tester, TargetPlatform.linux);
    final large = await measure(tester, TargetPlatform.linux, scale: 2);
    expect(large.line, greaterThan(normal.line));
    expect(large.gap, greaterThan(large.line));
  });
}
