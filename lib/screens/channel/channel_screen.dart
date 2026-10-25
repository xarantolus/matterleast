import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/empty_state.dart';

/// A conversation. Messages come with the channel view; for now it names
/// the channel.
class ChannelScreen extends StatelessWidget {
  const ChannelScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: const EmptyState(
      icon: Icons.chat_bubble_outline,
      title: 'Messages arrive in the next milestone',
      body: 'This channel is marked as read.',
    ),
  );
}
