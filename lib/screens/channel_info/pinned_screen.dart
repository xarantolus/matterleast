import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/fill_scrollable.dart';
import 'package:matterleast/ui/message_preview_tile.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/tokens.dart';

/// A channel's pinned messages: the stored ones at once, fetched again
/// behind them.
class PinnedScreen extends ConsumerWidget {
  const PinnedScreen({
    required this.url,
    required this.channelId,
    required this.title,
    super.key,
  });

  final String url;
  final String channelId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refresh = ref.watch(pinnedRefreshProvider(url, channelId));
    final ids = ref.watch(pinnedIdsProvider(url, channelId)).value;
    final items =
        ref
            .watch(searchPostItemsProvider(url, (ids ?? const []).join(',')))
            .value ??
        const [];
    final host = Uri.parse(url).host;
    final bottom = MediaQuery.paddingOf(context).bottom;
    Future<void> pull() async {
      final messenger = ScaffoldMessenger.of(context);
      ref.invalidate(pinnedRefreshProvider(url, channelId));
      try {
        await ref.read(pinnedRefreshProvider(url, channelId).future);
      } on Object catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text(requestProblemText(e, host))),
        );
      }
    }

    final Widget body;
    if (items.isNotEmpty) {
      body = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: bottom + Spacing.lg),
        children: [
          for (final item in items)
            MessagePreviewTile(
              item: item,
              onTap: () => openConversation(
                Navigator.of(context),
                url: url,
                channelId: channelId,
                title: title,
                teamId: item.teamId,
                highlightPostId: item.postId,
                rootId: item.rootId,
              ),
            ),
        ],
      );
    } else if (refresh.isLoading || ids == null) {
      body = const FillScrollable(
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (refresh.hasError) {
      body = FillScrollable(
        child: EmptyState(
          icon: Icons.cloud_off,
          title: "Couldn't load pinned messages",
          body: requestProblemText(refresh.error!, host),
          action: FilledButton.tonal(
            onPressed: pull,
            child: const Text('Retry'),
          ),
        ),
      );
    } else {
      body = const FillScrollable(
        child: EmptyState(
          icon: Icons.push_pin_outlined,
          title: 'No pinned messages',
          body: 'Pin a message from its menu to keep it here for everyone.',
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Pinned in $title'),
        bottom: ProgressSlot(active: refresh.isLoading && items.isNotEmpty),
      ),
      body: RefreshIndicator(onRefresh: pull, child: body),
    );
  }
}
