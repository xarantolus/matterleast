import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/post_actions.dart';
import 'package:matterleast/data/views/conversation_views.dart';
import 'package:matterleast/domain/burn_on_read.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/reminders.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/domain/today.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/emoji_picker.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message_menu.g.dart';

@riverpod
Future<PostMenuFacts> postMenuFacts(
  Ref ref,
  String url,
  PostItem post,
  String teamId,
) async =>
    ConversationViews((await ref.watch(serverSessionProvider(url).future)).db)
        .menuFacts(post, teamId, now: DateTime.now().toUtc());

/// Shown on the quick-reaction row before the user has reacted to anything.
const _defaultQuickReactions = [
  '+1',
  'smiley',
  'white_check_mark',
  'heart',
  'eyes',
  'raised_hands',
];

/// The menu for one message: quick reactions, then what can be done with
/// it. [onReply] and [onEdit] are null where that doesn't apply.
Future<void> showMessageMenu(
  BuildContext context, {
  required String url,
  required String teamId,
  required PostItem post,
  VoidCallback? onReply,
  VoidCallback? onEdit,
  VoidCallback? onMarkedUnread,
  ValueChanged<String?>? onQuote,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => MessageMenu(
    url: url,
    teamId: teamId,
    post: post,
    messenger: ScaffoldMessenger.of(context),
    onReply: onReply,
    onEdit: onEdit,
    onMarkedUnread: onMarkedUnread,
    onQuote: onQuote,
  ),
);

/// How many recent emoji fit in a row [width] wide next to "More
/// reactions": six where there is room, fewer on a narrow sheet.
int quickReactionCount(double width) => (width ~/ 48 - 1).clamp(3, 6);

class MessageMenu extends ConsumerWidget {
  const MessageMenu({
    required this.url,
    required this.teamId,
    required this.post,
    required this.messenger,
    this.onReply,
    this.onEdit,
    this.onMarkedUnread,
    this.onQuote,
    super.key,
  });

  final String url;
  final String teamId;
  final PostItem post;

  /// The screen's, so messages outlive the sheet.
  final ScaffoldMessengerState messenger;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onMarkedUnread;

  /// Puts a quote of the message, with its permalink when known, into the
  /// conversation's composer.
  final ValueChanged<String?>? onQuote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factsState = ref.watch(postMenuFactsProvider(url, post, teamId));
    final facts = factsState.value;
    final recent = ref.watch(recentEmojiProvider(url)).value ?? const [];
    if (facts == null) {
      return SizedBox(
        height: 120,
        child: Center(
          child: factsState.hasError
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Couldn't load the options."),
                    TextButton(
                      onPressed: () => ref.invalidate(
                        postMenuFactsProvider(url, post, teamId),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                )
              : const CircularProgressIndicator(
                  semanticsLabel: 'Loading options',
                ),
        ),
      );
    }
    final rights = facts.rights;
    final unsent = post.sendState != null;
    final permalink = facts.teamName.isEmpty
        ? null
        : '${url.replaceFirst(RegExp(r'/+$'), '')}/${facts.teamName}/pl/${post.id}';
    final following = facts.following;
    final threadRoot = post.isReply ? post.rootId : post.id;
    void close() => Navigator.of(context).pop();
    final burns = post.type == burnOnReadType;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!unsent && !post.isEphemeral && rights.react)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final quick = {
                    ...recent,
                    ..._defaultQuickReactions,
                  }.take(quickReactionCount(constraints.maxWidth)).toList();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final name in quick)
                        IconButton.outlined(
                          style: IconButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                            ),
                          ),
                          tooltip: ':$name:',
                          onPressed: () {
                            close();
                            unawaited(
                              _run(ref.read(postActionsProvider(url).future), (
                                a,
                              ) async {
                                final mine = post.reactions.any(
                                  (g) => g.emojiName == name && g.mine,
                                );
                                await (mine
                                    ? a.removeReaction(post.id, name)
                                    : a.addReaction(post.id, name));
                              }, "Couldn't change the reaction."),
                            );
                          },
                          icon: EmojiGlyph(
                            name: name,
                            size: 28,
                            serverUrl: url,
                          ),
                        ),
                      IconButton.filledTonal(
                        tooltip: 'More reactions',
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final actions = ref.read(
                            postActionsProvider(url).future,
                          );
                          final picked = await showEmojiPicker(context, url);
                          navigator.pop();
                          if (picked != null) {
                            await _run(
                              actions,
                              (a) => a.addReaction(post.id, picked),
                              "Couldn't add the reaction.",
                            );
                          }
                        },
                        icon: const Icon(Icons.add_reaction_outlined),
                      ),
                    ],
                  );
                },
              ),
            ),
          if (onReply != null && !unsent && rights.reply && !burns)
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                close();
                onReply!();
              },
            ),
          ListTile(
            leading: const Icon(Icons.content_copy),
            title: const Text('Copy text'),
            onTap: () {
              close();
              unawaited(Clipboard.setData(ClipboardData(text: post.message)));
            },
          ),
          if (permalink != null && !unsent && !post.isEphemeral)
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy link'),
              onTap: () {
                close();
                unawaited(Clipboard.setData(ClipboardData(text: permalink)));
              },
            ),
          if (onQuote != null &&
              !unsent &&
              !post.isEphemeral &&
              !post.isSystem &&
              post.message.trim().isNotEmpty)
            ListTile(
              leading: const Icon(Icons.format_quote_outlined),
              title: const Text('Quote'),
              onTap: () {
                close();
                onQuote!(permalink);
              },
            ),
          if (!unsent && !post.isEphemeral) ...[
            if (facts.reminders)
              ListTile(
                leading: const Icon(Icons.alarm_outlined),
                title: const Text('Remind me'),
                onTap: () => _remind(context, ref),
              ),
            ListTile(
              leading: Icon(
                facts.saved ? Icons.bookmark_remove : Icons.bookmark_border,
              ),
              title: Text(facts.saved ? 'Unsave' : 'Save'),
              onTap: () {
                close();
                unawaited(
                  _run(
                    ref.read(postActionsProvider(url).future),
                    (a) => facts.saved
                        ? a.unsavePost(post.id)
                        : a.savePost(post.id),
                    facts.saved
                        ? "Couldn't unsave the message."
                        : "Couldn't save the message.",
                  ),
                );
              },
            ),
            if (rights.pin)
              ListTile(
                leading: Icon(
                  post.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                ),
                title: Text(post.pinned ? 'Unpin' : 'Pin to channel'),
                onTap: () {
                  close();
                  unawaited(
                    _run(
                      ref.read(postActionsProvider(url).future),
                      (a) => post.pinned
                          ? a.unpinPost(post.id)
                          : a.pinPost(post.id),
                      post.pinned
                          ? "Couldn't unpin the message."
                          : "Couldn't pin the message.",
                    ),
                  );
                },
              ),
            if (rights.markUnread)
              ListTile(
                leading: const Icon(Icons.mark_chat_unread_outlined),
                title: const Text('Mark as unread'),
                onTap: () {
                  close();
                  onMarkedUnread?.call();
                  unawaited(
                    _run(
                      ref.read(postActionsProvider(url).future),
                      (a) => a.markUnread(post.id),
                      "Couldn't mark the message unread.",
                    ),
                  );
                },
              ),
            if (following != null && teamId.isNotEmpty)
              ListTile(
                leading: Icon(
                  following
                      ? Icons.notifications_off_outlined
                      : Icons.notifications_active_outlined,
                ),
                title: Text(following ? 'Unfollow thread' : 'Follow thread'),
                onTap: () {
                  close();
                  unawaited(
                    _run(
                      ref.read(postActionsProvider(url).future),
                      (a) => following
                          ? a.unfollowThread(teamId, threadRoot)
                          : a.followThread(teamId, threadRoot, channelId: null),
                      "Couldn't change following the thread.",
                    ),
                  );
                },
              ),
            if (onEdit != null && rights.edit)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  close();
                  onEdit!();
                },
              ),
            if (burns)
              ListTile(
                leading: Icon(
                  Icons.local_fire_department_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Burn now',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  close();
                  unawaited(
                    _run(
                      ref.read(postActionsProvider(url).future),
                      (a) => a.burnNow(post.id),
                      "Couldn't burn the message.",
                    ),
                  );
                },
              ),
            if (rights.delete)
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final actions = ref.read(postActionsProvider(url).future);
                  final sure = await confirmDelete(context);
                  navigator.pop();
                  if (sure) {
                    await _run(
                      actions,
                      (a) => a.deletePost(post.id),
                      "Couldn't delete the message.",
                    );
                  }
                },
              ),
          ],
        ],
      ),
    );
  }

  /// Asks when, with the menu still open beneath, then closes it.
  Future<void> _remind(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final actions = ref.read(postActionsProvider(url).future);
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final at = await askReminderTime(context);
    navigator.pop();
    if (at == null) return;
    final now = DateTime.now();
    if (!at.isAfter(now)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('That time has passed; pick a later one.'),
        ),
      );
      return;
    }
    await _run(actions, (a) async {
      await a.remind(post.id, at);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Reminder set for ${untilLabel(at, now, use24: use24)}',
          ),
        ),
      );
    }, "Couldn't set the reminder.");
  }

  Future<void> _run(
    Future<PostActions> actions,
    Future<void> Function(PostActions actions) action,
    String failure,
  ) async {
    try {
      await action(await actions);
    } on ApiError catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '$failure ${requestProblemText(e, Uri.parse(url).host)}',
          ),
        ),
      );
    }
  }
}

Future<bool> confirmDelete(BuildContext context) => confirm(
  context,
  title: 'Delete message?',
  body: 'The message and its replies are deleted for everyone.',
  action: 'Delete',
  destructive: true,
);

/// When to be reminded, local time: a ready-made time, or a date and a
/// time picked one after the other; null when the user backs out.
Future<DateTime?> askReminderTime(BuildContext context) async {
  final now = DateTime.now();
  final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
  final choice = await showModalBottomSheet<({ReminderChoice? preset})>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (choice, label) in const [
            (ReminderChoice.thirtyMinutes, 'In 30 minutes'),
            (ReminderChoice.oneHour, 'In 1 hour'),
            (ReminderChoice.twoHours, 'In 2 hours'),
            (ReminderChoice.tomorrow, 'Tomorrow'),
          ])
            ListTile(
              title: Text(label),
              trailing: Text(
                untilLabel(reminderTime(choice, now), now, use24: use24),
              ),
              onTap: () => Navigator.of(sheet).pop((preset: choice)),
            ),
          ListTile(
            title: const Text('Custom'),
            trailing: const Icon(Icons.calendar_month_outlined),
            onTap: () => Navigator.of(sheet).pop((preset: null)),
          ),
        ],
      ),
    ),
  );
  if (choice == null || !context.mounted) return null;
  if (choice.preset case final preset?) {
    return reminderTime(preset, DateTime.now());
  }
  final later = DateTime.now().add(const Duration(hours: 1));
  final day = await showDatePicker(
    context: context,
    initialDate: later,
    firstDate: localDay(now),
    lastDate: localDay(now).add(const Duration(days: 365)),
  );
  if (day == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(later),
  );
  if (time == null) return null;
  return DateTime(day.year, day.month, day.day, time.hour, time.minute);
}

/// A message that couldn't be sent: send it again or throw it away.
Future<void> showFailedPostSheet(
  BuildContext context, {
  required String url,
  required PostItem post,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (sheet) => Consumer(
    builder: (context, ref, _) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(title: Text('This message was not sent.')),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Try again'),
            onTap: () async {
              Navigator.of(sheet).pop();
              await (await ref.read(composerActionsProvider(url).future))
                  .retry(post.key);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete'),
            onTap: () async {
              Navigator.of(sheet).pop();
              await (await ref.read(composerActionsProvider(url).future))
                  .discard(post.key);
            },
          ),
        ],
      ),
    ),
  ),
);
