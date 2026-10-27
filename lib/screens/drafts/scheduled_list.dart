import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/domain/scheduled_posts.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/screens/drafts/drafts_providers.dart';
import 'package:matterleast/screens/drafts/schedule_picker.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

/// The team's scheduled messages: tap for Send now, Reschedule, Edit and
/// Delete. Failed ones come first and say why.
class ScheduledList extends ConsumerWidget {
  const ScheduledList({required this.url, required this.teamId, super.key});

  final String url;
  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(teamScheduledProvider(url, teamId)).value;
    // Kept current for the reschedule picker.
    ref.watch(manualTimeZoneProvider(url));
    return switch (items) {
      null => const Center(child: CircularProgressIndicator()),
      [] => const EmptyState(
        icon: Icons.schedule_send_outlined,
        title: 'Nothing scheduled',
        body:
            'Hold the send button while writing to send a message later. '
            'It waits here until then.',
      ),
      final items => ListView.builder(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + Spacing.lg,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) => _ScheduledTile(
          url: url,
          item: items[i],
          onTap: () => _options(context, ref, items[i]),
        ),
      ),
    };
  }

  Future<void> _options(
    BuildContext context,
    WidgetRef ref,
    ScheduledItem item,
  ) async {
    final error = Theme.of(context).colorScheme.error;
    final choice = await showAppSheet<_Choice>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (choice, icon, label) in const [
              (_Choice.sendNow, Icons.send_outlined, 'Send now'),
              (_Choice.reschedule, Icons.schedule_outlined, 'Reschedule'),
              (_Choice.edit, Icons.edit_outlined, 'Edit message'),
            ])
              ListTile(
                leading: Icon(icon),
                title: Text(label),
                onTap: () => Navigator.of(sheet).pop(choice),
              ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: error),
              title: Text('Delete', style: TextStyle(color: error)),
              onTap: () => Navigator.of(sheet).pop(_Choice.delete),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final session = await ref.read(serverSessionProvider(url).future);
    final scheduled = session.connection.scheduled;
    Future<void> attempt(Future<void> Function() work, String done) async {
      try {
        await work();
        messenger.showSnackBar(SnackBar(content: Text(done)));
      } on ApiError catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text(requestProblemText(e, Uri.parse(url).host))),
        );
      }
    }

    switch (choice) {
      case _Choice.sendNow:
        final post = await scheduled.find(item.id);
        if (post == null) return;
        final actions = await ref.read(composerActionsProvider(url).future);
        await actions.send(
          item.channelId,
          rootId: item.rootId,
          message: post.message ?? '',
          files: post.metadata?.files ?? const [],
          priority: post.metadata?.priority,
        );
        try {
          await scheduled.delete(item.id);
          messenger.showSnackBar(const SnackBar(content: Text('Sent')));
        } on ApiError catch (e) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Sent, but it is still scheduled: '
                '${requestProblemText(e, Uri.parse(url).host)}',
              ),
            ),
          );
        }
      case _Choice.reschedule:
        if (!context.mounted) return;
        final zone = ref.read(manualTimeZoneProvider(url)).value;
        final at = await pickScheduleTime(
          context,
          zone: zone,
          title: 'Reschedule',
        );
        if (at == null) return;
        await attempt(() => scheduled.reschedule(item.id, at), 'Rescheduled');
      case _Choice.edit:
        final post = await scheduled.find(item.id);
        if (post == null || !context.mounted) return;
        final text = await _editText(context, post.message ?? '');
        if (text == null || text.trim().isEmpty) return;
        await attempt(() => scheduled.edit(item.id, text.trim()), 'Saved');
      case _Choice.delete:
        if (!context.mounted) return;
        final sure = await confirm(
          context,
          title: 'Delete scheduled message?',
          body: "It won't be sent.",
          action: 'Delete',
        );
        if (!sure) return;
        await attempt(() => scheduled.delete(item.id), 'Deleted');
    }
  }

  Future<String?> _editText(BuildContext context, String message) {
    final controller = TextEditingController(text: message);
    return showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Edit message'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 1,
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }
}

enum _Choice { sendNow, reschedule, edit, delete }

class _ScheduledTile extends ConsumerWidget {
  const _ScheduledTile({
    required this.url,
    required this.item,
    required this.onTap,
  });

  final String url;
  final ScheduledItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final thread = item.rootId.isNotEmpty;
    final when = untilLabel(
      item.scheduledAt,
      today,
      use24: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    final problem = item.problem;
    return ListTile(
      onTap: onTap,
      leading: switch (item.userId) {
        final userId? => UserAvatar(
          serverUrl: url,
          userId: userId,
          name: item.title,
        ),
        null => InitialsBadge(
          name: item.title,
          icon: thread ? Icons.forum_outlined : Icons.tag,
          round: true,
        ),
      },
      title: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: tokens.muted),
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            children: [
              Icon(
                problem == null ? Icons.schedule : Icons.error_outline,
                size: 16,
                color: problem == null ? tokens.accent : scheme.error,
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  problem ??
                      [
                        if (thread) 'In a thread',
                        'Sends ${when.contains(' ') ? when : 'at $when'}',
                      ].join(' · '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: problem == null ? tokens.accent : scheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
