import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/domain/drafts.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/screens/drafts/drafts_providers.dart';
import 'package:matterleast/screens/drafts/scheduled_list.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

/// Unsent messages of one team and of direct messages: tap to go on
/// writing, swipe or long-press to delete. Where the server schedules
/// messages, a second tab lists those.
class DraftsScreen extends ConsumerWidget {
  const DraftsScreen({
    required this.url,
    required this.teamId,
    required this.teamName,
    this.scheduledFirst = false,
    super.key,
  });

  final String url;
  final String teamId;
  final String teamName;

  /// Opens on the scheduled messages.
  final bool scheduledFirst;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(refreshDraftsProvider(url, teamId));
    final scheduling =
        ref.watch(featuresProvider(url)).value?.scheduledPosts ?? false;
    final scheduled = ref.watch(teamScheduledProvider(url, teamId)).value;
    final title = Text(
      teamName.isEmpty ? 'Drafts' : 'Drafts · $teamName',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (!scheduling && (scheduled?.isEmpty ?? true)) {
      return Scaffold(
        appBar: AppBar(title: title),
        body: _drafts(context, ref),
      );
    }
    return DefaultTabController(
      length: 2,
      initialIndex: scheduledFirst ? 1 : 0,
      child: Scaffold(
        appBar: AppBar(
          title: title,
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Drafts'),
              Tab(
                text: switch (scheduled?.length ?? 0) {
                  0 => 'Scheduled',
                  final n => 'Scheduled ($n)',
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _drafts(context, ref),
            ScheduledList(url: url, teamId: teamId),
          ],
        ),
      ),
    );
  }

  Widget _drafts(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(teamDraftsProvider(url, teamId)).value;
    return switch (drafts) {
      null => const Center(child: CircularProgressIndicator()),
      [] => const EmptyState(
        icon: Icons.edit_note,
        title: 'No drafts',
        body:
            "Messages you start writing and don't send are kept here, "
            'so you can finish them later.',
      ),
      final drafts => ListView.builder(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + Spacing.lg,
        ),
        itemCount: drafts.length,
        itemBuilder: (context, i) {
          final draft = drafts[i];
          return Dismissible(
            key: ValueKey('${draft.channelId}/${draft.rootId}'),
            background: const _DeleteBackground(
              alignment: AlignmentDirectional.centerStart,
            ),
            secondaryBackground: const _DeleteBackground(
              alignment: AlignmentDirectional.centerEnd,
            ),
            onDismissed: (_) => _delete(context, ref, draft),
            child: _DraftTile(
              url: url,
              draft: draft,
              onTap: () => openConversation(
                Navigator.of(context),
                url: url,
                channelId: draft.channelId,
                title: draft.title,
                teamId: teamId,
                rootId: draft.rootId.isEmpty ? null : draft.rootId,
              ),
              onLongPress: () => _options(context, ref, draft),
            ),
          );
        },
      ),
    };
  }

  Future<void> _options(
    BuildContext context,
    WidgetRef ref,
    DraftItem draft,
  ) async {
    final delete = await showAppSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: ListTile(
          leading: Icon(
            Icons.delete_outline,
            color: Theme.of(sheet).colorScheme.error,
          ),
          title: Text(
            'Delete draft',
            style: TextStyle(color: Theme.of(sheet).colorScheme.error),
          ),
          onTap: () => Navigator.of(sheet).pop(true),
        ),
      ),
    );
    if ((delete ?? false) && context.mounted) {
      await _delete(context, ref, draft);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    DraftItem draft,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final actions = await ref.read(composerActionsProvider(url).future);
    final removed = await actions.removeDraft(
      draft.channelId,
      rootId: draft.rootId,
    );
    if (removed == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Draft deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => unawaited(actions.restoreDraft(removed)),
          ),
        ),
      );
  }
}

class _DraftTile extends ConsumerWidget {
  const _DraftTile({
    required this.url,
    required this.draft,
    required this.onTap,
    required this.onLongPress,
  });

  final String url;
  final DraftItem draft;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final thread = draft.rootId.isNotEmpty;
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: switch (draft.userId) {
        final userId? => UserAvatar(
          serverUrl: url,
          userId: userId,
          name: draft.title,
        ),
        null => InitialsBadge(
          name: draft.title,
          icon: thread ? Icons.forum_outlined : Icons.tag,
          round: true,
        ),
      },
      title: Row(
        children: [
          Expanded(
            child: Text(
              draft.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            shortWhen(
              draft.updatedAt,
              today,
              use24: MediaQuery.alwaysUse24HourFormatOf(context),
            ),
            style: text.bodySmall?.copyWith(color: tokens.muted),
          ),
        ],
      ),
      subtitle: Text.rich(
        TextSpan(
          children: [
            if (thread)
              TextSpan(
                text: 'In a thread · ',
                style: TextStyle(color: tokens.accent),
              ),
            TextSpan(text: draft.preview),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: tokens.muted),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground({required this.alignment});

  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.errorContainer,
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
          child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
        ),
      ),
    );
  }
}
