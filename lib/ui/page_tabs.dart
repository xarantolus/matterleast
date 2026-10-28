import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/server_theme.dart';

/// Tabs at the top of a page, with the unselected labels raised until they
/// read on server themes too.
class PageTabs extends StatelessWidget {
  const PageTabs({required this.tabs, super.key});

  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colour = theme.colorScheme.onSurface;
    final page = theme.scaffoldBackgroundColor;
    var unselected = colour.withValues(alpha: 0.7);
    while (unselected.a < 1 &&
        contrastRatio(Color.alphaBlend(unselected, page), page) < minContrast) {
      unselected = colour.withValues(alpha: unselected.a + 0.05);
    }
    return TabBar(
      tabs: tabs,
      labelColor: colour,
      unselectedLabelColor: unselected,
      indicatorColor: theme.colorScheme.primary,
    );
  }
}
