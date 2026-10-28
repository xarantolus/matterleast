import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/server_theme.dart';

/// Tabs under an app bar, in the bar's colours; Material's defaults are
/// meant for the page and vanish on a coloured bar.
class BarTabs extends StatelessWidget implements PreferredSizeWidget {
  const BarTabs({required this.tabs, super.key});

  final List<Widget> tabs;

  @override
  Size get preferredSize => TabBar(tabs: tabs).preferredSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colour =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;
    final bar = theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;
    var unselected = colour.withValues(alpha: 0.7);
    while (unselected.a < 1 &&
        contrastRatio(Color.alphaBlend(unselected, bar), bar) < minContrast) {
      unselected = colour.withValues(alpha: unselected.a + 0.05);
    }
    return TabBar(
      tabs: tabs,
      labelColor: colour,
      unselectedLabelColor: unselected,
      indicatorColor: colour,
      dividerColor: Colors.transparent,
    );
  }
}
