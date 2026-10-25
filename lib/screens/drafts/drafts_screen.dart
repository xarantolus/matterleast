import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/empty_state.dart';

/// Unsent messages of one team. Writing arrives with the composer.
class DraftsScreen extends StatelessWidget {
  const DraftsScreen({required this.teamName, super.key});

  final String teamName;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'Drafts · $teamName',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    body: const EmptyState(
      icon: Icons.edit_note,
      title: 'No drafts',
      body: 'Drafts you write will appear here.',
    ),
  );
}
