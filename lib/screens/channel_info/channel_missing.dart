import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/channel_info.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/ui/empty_state.dart';

/// In place of a channel's screen while its stored details are on their
/// way, couldn't be read, or don't exist.
class ChannelMissing extends StatelessWidget {
  const ChannelMissing({
    required this.state,
    required this.host,
    required this.onRetry,
    super.key,
  });

  final AsyncValue<ChannelInfo?> state;
  final String host;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => switch (state) {
    AsyncError(:final error) => EmptyState(
      icon: Icons.error_outline,
      title: "Couldn't show the channel",
      body: requestProblemText(error, host),
      action: FilledButton.tonal(
        onPressed: onRetry,
        child: const Text('Retry'),
      ),
    ),
    AsyncData() => const EmptyState(
      icon: Icons.search_off,
      title: 'Channel not found',
      body:
          "It isn't saved on this device. It may have been deleted, or you "
          'may have left it.',
    ),
    _ => const Center(child: CircularProgressIndicator()),
  };
}
