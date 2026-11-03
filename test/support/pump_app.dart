import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';

/// Pumps [home] in the app's light theme, inside providers with [overrides].
Future<void> pumpApp(
  WidgetTester tester,
  Widget home, {
  List<Override> overrides = const [],
}) => tester.pumpWidget(
  ProviderScope(
    overrides: overrides,
    child: MaterialApp(theme: MatterleastApp.lightTheme, home: home),
  ),
);
