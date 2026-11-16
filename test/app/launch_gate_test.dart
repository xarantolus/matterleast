import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/network_state.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/launch_gate.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/domain/server_entry.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('a failed start shows what went wrong and Retry brings the '
      'app up', (tester) async {
    var failing = true;
    await pumpApp(
      tester,
      const LaunchGate(),
      overrides: [
        serversProvider.overrideWith(
          (ref) => failing
              ? Stream<List<ServerEntry>>.error(
                  StateError('database is locked'),
                )
              : Stream.value(const <ServerEntry>[]),
        ),
        autoLoadProvider(DataKind.linkPicture).overrideWith((ref) => true),
        networkStateProvider.overrideWith(
          (ref) => NetworkState(Stream.value([ConnectivityResult.wifi])),
        ),
      ],
    );
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('database is locked'), findsOneWidget);

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Retry'), findsNothing);
    expect(find.textContaining('database is locked'), findsNothing);
    await closeApp(tester);
  });

  testWidgets('a start that never finishes offers Retry after the wait, '
      'not before', (tester) async {
    final never = StreamController<List<ServerEntry>>();
    addTearDown(never.close);
    await pumpApp(
      tester,
      const LaunchGate(stallAfter: Duration(seconds: 10)),
      overrides: [
        serversProvider.overrideWith((ref) => never.stream),
        autoLoadProvider(DataKind.linkPicture).overrideWith((ref) => true),
        networkStateProvider.overrideWith(
          (ref) => NetworkState(Stream.value([ConnectivityResult.wifi])),
        ),
      ],
    );
    await tester.pump(const Duration(seconds: 9));
    expect(find.text('Retry'), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Still starting…'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    never.add(const []);
    await closeApp(tester);
  });
}
