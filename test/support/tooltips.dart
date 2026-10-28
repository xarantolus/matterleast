import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Looks at every icon button on screen: the icons of those without a
/// tooltip, which have no name for a screen reader or the mouse.
List<String> untitledIconButtons(WidgetTester tester) => [
  for (final button in tester.widgetList<IconButton>(find.byType(IconButton)))
    if (button.tooltip == null || button.tooltip!.isEmpty)
      '${button.icon.runtimeType}',
];
