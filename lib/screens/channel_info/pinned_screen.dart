import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/home/open_item.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/fill_scrollable.dart';
import 'package:matterleast/ui/message_preview_tile.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/refresh_area.dart';
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
    final found = ref.watch(
      searchPostItemsProvider(url, (ids ?? const []).join(',')),
    );
    final items = found.value ?? const [];
    // Known ids still turning into rows aren't "no pinned messages".
    final resolving = (ids?.isNotEmpty ?? false) && !found.hasValue;
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
              onTap: () => openInboxItem(context, item),
            ),
        ],
      );
    } else if (refresh.isLoading || ids == null || resolving) {
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
      body: RefreshArea(onRefresh: pull, child: body),
    );
  }
}
