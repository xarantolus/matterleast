import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/ui/post_tile.dart';

import '../support/pump_app.dart';

class _Clock extends Today {
  _Clock(this.start);

  final DateTime start;

  @override
  DateTime build() => start;

  void turnTo(DateTime day) => state = day;
}

void main() {
  testWidgets('a day separator reads Yesterday once midnight has passed', (
    tester,
  ) async {
    final clock = _Clock(DateTime(2026, 10, 26));
    await pumpApp(
      tester,
      Scaffold(body: DaySeparatorTile(day: DateTime(2026, 10, 26))),
      overrides: [todayProvider.overrideWith(() => clock)],
    );
    expect(find.text('TODAY'), findsOneWidget);

    clock.turnTo(DateTime(2026, 10, 27));
    await tester.pump();
    expect(find.text('YESTERDAY'), findsOneWidget);
  });
}
