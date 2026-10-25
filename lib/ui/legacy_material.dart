import 'package:flutter/material.dart' as legacy;
import 'package:material_ui/material_ui.dart';

/// Gives widgets from packages still built on `package:flutter/material`
/// the theme, localizations and `Material` they look up there, matching
/// the app's colours.
class LegacyMaterial extends StatelessWidget {
  const LegacyMaterial({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Localizations.override(
      context: context,
      delegates: const [legacy.DefaultMaterialLocalizations.delegate],
      child: legacy.Theme(
        data: legacy.ThemeData(
          colorScheme: legacy.ColorScheme.fromSeed(
            seedColor: theme.colorScheme.primary,
            brightness: theme.brightness,
          ),
        ),
        child: legacy.Material(
          type: legacy.MaterialType.transparency,
          child: child,
        ),
      ),
    );
  }
}
