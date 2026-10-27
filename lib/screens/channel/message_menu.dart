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
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/context_menu.dart';
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

/// One message and what the screen showing it lets be done with it.
/// [onReply] and [onEdit] are null where that doesn't apply.
@immutable
class MessageTarget {
  const MessageTarget({
    required this.url,
    required this.teamId,
    required this.post,
    this.onReply,
    this.onEdit,
    this.onMarkedUnread,
    this.onQuote,
  });

  final String url;
  final String teamId;
  final PostItem post;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onMarkedUnread;

  /// Puts a quote of the message, with its permalink when known, into the
  /// conversation's composer.
  final ValueChanged<String?>? onQuote;
}

/// What a menu entry does once the menu is gone, against the context of
/// the screen that opened it.
typedef MessageRun = Future<void> Function(BuildContext context);

enum MessageActionKind {
  react,
  reply,
  copyText,
  copyLink,
  quote,
  remind,
  save,
  pin,
  markUnread,
  follow,
  edit,
  burn,
  delete,
}

/// One thing that can be done with a message: the same in the sheet, the
/// right-click menu and the hover toolbar.
@immutable
class MessageAction {
  const MessageAction(
    this.kind,
    this.label,
    this.icon,
    this.run, {
    this.destructive = false,
  });

  final MessageActionKind kind;
  final String label;
  final IconData icon;
  final bool destructive;
  final MessageRun run;
}

/// Pure: what can be done with [target]'s message, in menu order.
List<MessageAction> messageActions(MessageTarget target, PostMenuFacts facts) {
  final post = target.post;
  final url = target.url;
  final rights = facts.rights;
  final unsent = post.sendState != null;
  final permalink = facts.teamName.isEmpty
      ? null
      : '${url.replaceFirst(RegExp(r'/+$'), '')}/${facts.teamName}/pl/${post.id}';
  final following = facts.following;
  final threadRoot = post.isReply ? post.rootId : post.id;
  final burns = post.type == burnOnReadType;
  final onReply = target.onReply;
  final onEdit = target.onEdit;
  final onQuote = target.onQuote;
  Future<void> act(
    BuildContext context,
    Future<void> Function(PostActions actions) action,
    String failure,
  ) => runPostAction(context, url, action, failure);

  return [
    if (!unsent && !post.isEphemeral && rights.react)
      MessageAction(
        MessageActionKind.react,
        'Add reaction',
        Icons.add_reaction_outlined,
        (context) => pickReaction(context, url, post),
      ),
    if (onReply != null && !unsent && rights.reply && !burns)
      MessageAction(
        MessageActionKind.reply,
        'Reply',
        Icons.reply,
        (_) async => onReply(),
      ),
    MessageAction(
      MessageActionKind.copyText,
      'Copy text',
      Icons.content_copy,
      (_) => Clipboard.setData(ClipboardData(text: post.message)),
    ),
    if (permalink != null && !unsent && !post.isEphemeral)
      MessageAction(
        MessageActionKind.copyLink,
        'Copy link',
        Icons.link,
        (_) => Clipboard.setData(ClipboardData(text: permalink)),
      ),
    if (onQuote != null &&
        !unsent &&
        !post.isEphemeral &&
        !post.isSystem &&
        post.message.trim().isNotEmpty)
      MessageAction(
        MessageActionKind.quote,
        'Quote',
        Icons.format_quote_outlined,
        (_) async => onQuote(permalink),
      ),
    if (!unsent && !post.isEphemeral) ...[
      if (facts.reminders)
        MessageAction(
          MessageActionKind.remind,
          'Remind me',
          Icons.alarm_outlined,
          (context) => _remind(context, url, post),
        ),
      MessageAction(
        MessageActionKind.save,
        facts.saved ? 'Unsave' : 'Save',
        facts.saved ? Icons.bookmark_remove : Icons.bookmark_border,
        (context) => act(
          context,
          (a) => facts.saved ? a.unsavePost(post.id) : a.savePost(post.id),
          facts.saved
              ? "Couldn't unsave the message."
              : "Couldn't save the message.",
        ),
      ),
      if (rights.pin)
        MessageAction(
          MessageActionKind.pin,
          post.pinned ? 'Unpin' : 'Pin to channel',
          post.pinned ? Icons.push_pin : Icons.push_pin_outlined,
          (context) => act(
            context,
            (a) => post.pinned ? a.unpinPost(post.id) : a.pinPost(post.id),
            post.pinned
                ? "Couldn't unpin the message."
                : "Couldn't pin the message.",
          ),
        ),
      if (rights.markUnread)
        MessageAction(
          MessageActionKind.markUnread,
          'Mark as unread',
          Icons.mark_chat_unread_outlined,
          (context) {
            target.onMarkedUnread?.call();
            return act(
              context,
              (a) => a.markUnread(post.id),
              "Couldn't mark the message unread.",
            );
          },
        ),
      if (following != null && target.teamId.isNotEmpty)
        MessageAction(
          MessageActionKind.follow,
          following ? 'Unfollow thread' : 'Follow thread',
          following
              ? Icons.notifications_off_outlined
              : Icons.notifications_active_outlined,
          (context) => act(
            context,
            (a) => following
                ? a.unfollowThread(target.teamId, threadRoot)
                : a.followThread(target.teamId, threadRoot, channelId: null),
            "Couldn't change following the thread.",
          ),
        ),
      if (onEdit != null && rights.edit)
        MessageAction(
          MessageActionKind.edit,
          'Edit',
          Icons.edit_outlined,
          (_) async => onEdit(),
        ),
      if (burns)
        MessageAction(
          MessageActionKind.burn,
          'Burn now',
          Icons.local_fire_department_outlined,
          (context) => act(
            context,
            (a) => a.burnNow(post.id),
            "Couldn't burn the message.",
          ),
          destructive: true,
        ),
      if (rights.delete)
        MessageAction(
          MessageActionKind.delete,
          'Delete',
          Icons.delete_outline,
          (context) async {
            if (!await confirmDelete(context) || !context.mounted) return;
            await act(
              context,
              (a) => a.deletePost(post.id),
              "Couldn't delete the message.",
            );
          },
          destructive: true,
        ),
    ],
  ];
}

/// The emoji the quick reactions offer, most recent first, at most [count].
List<String> quickReactions(List<String> recent, int count) =>
    {...recent, ..._defaultQuickReactions}.take(count).toList();

/// The menu for one message as a sheet: quick reactions, then what can be
/// done with it.
Future<void> showMessageMenu(BuildContext context, MessageTarget target) async {
  final run = await showAppSheet<MessageRun>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => MessageMenu(target: target),
  );
  if (run != null && context.mounted) await run(context);
}

/// The same menu at the pointer, for a right click at [position] (global).
/// [selection] is text selected in the message, offered for copying.
Future<void> showMessageContextMenu(
  BuildContext context,
  MessageTarget target,
  Offset position, {
  String? selection,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final container = ProviderScope.containerOf(context, listen: false);
  final provider = postMenuFactsProvider(
    target.url,
    target.post,
    target.teamId,
  );
  final sub = container.listen(provider.future, (_, _) {});
  final PostMenuFacts facts;
  try {
    facts = await sub.read();
  } on Object {
    messenger.showSnackBar(
      const SnackBar(content: Text("Couldn't load the options.")),
    );
    return;
  } finally {
    sub.close();
  }
  if (!context.mounted) return;
  final actions = messageActions(target, facts);
  final error = Theme.of(context).colorScheme.error;
  final run = await showMenuAt<MessageRun>(context, position, [
    if (selection != null && selection.isNotEmpty) ...[
      PopupMenuItem(
        value: (_) => Clipboard.setData(ClipboardData(text: selection)),
        child: const MenuEntry(icon: Icons.copy, label: 'Copy selection'),
      ),
      const PopupMenuDivider(),
    ],
    for (final action in actions)
      PopupMenuItem(
        value: action.run,
        child: MenuEntry(
          icon: action.icon,
          label: action.label,
          color: action.destructive ? error : null,
        ),
      ),
  ]);
  if (run != null && context.mounted) await run(context);
}

/// How many recent emoji fit in a row [width] wide next to "Add
/// reaction": six where there is room, fewer on a narrow sheet.
int quickReactionCount(double width) => (width ~/ 48 - 1).clamp(3, 6);

/// The sheet's content; it closes with the chosen action, which the opener
/// runs.
class MessageMenu extends ConsumerWidget {
  const MessageMenu({required this.target, super.key});

  final MessageTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = target.url;
    final post = target.post;
    final provider = postMenuFactsProvider(url, post, target.teamId);
    final factsState = ref.watch(provider);
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
                      onPressed: () => ref.invalidate(provider),
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
    final actions = messageActions(target, facts);
    void pick(MessageRun run) => Navigator.of(context).pop(run);
    final error = Theme.of(context).colorScheme.error;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final action in actions)
            if (action.kind == MessageActionKind.react)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: LayoutBuilder(
                  builder: (context, constraints) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final name in quickReactions(
                        recent,
                        quickReactionCount(constraints.maxWidth),
                      ))
                        IconButton.outlined(
                          style: IconButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                            ),
                          ),
                          tooltip: ':$name:',
                          onPressed: () => pick(
                            (context) =>
                                toggleReaction(context, url, post, name),
                          ),
                          icon: EmojiGlyph(
                            name: name,
                            size: 28,
                            serverUrl: url,
                          ),
                        ),
                      IconButton.filledTonal(
                        tooltip: action.label,
                        onPressed: () => pick(action.run),
                        icon: Icon(action.icon),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListTile(
                leading: Icon(
                  action.icon,
                  color: action.destructive ? error : null,
                ),
                title: Text(
                  action.label,
                  style: action.destructive ? TextStyle(color: error) : null,
                ),
                onTap: () => pick(action.run),
              ),
        ],
      ),
    );
  }
}

/// Adds the user's [name] reaction to [post], or takes it back.
Future<void> toggleReaction(
  BuildContext context,
  String url,
  PostItem post,
  String name,
) {
  final mine = post.reactions.any((g) => g.emojiName == name && g.mine);
  return runPostAction(
    context,
    url,
    (a) =>
        mine ? a.removeReaction(post.id, name) : a.addReaction(post.id, name),
    "Couldn't change the reaction.",
  );
}

/// Asks for an emoji and adds it to [post]; on desktop the picker opens
/// next to [anchor] (global).
Future<void> pickReaction(
  BuildContext context,
  String url,
  PostItem post, {
  Rect? anchor,
}) async {
  final picked = await showEmojiPicker(context, url, anchor: anchor);
  if (picked == null || !context.mounted) return;
  await runPostAction(
    context,
    url,
    (a) => a.addReaction(post.id, picked),
    "Couldn't add the reaction.",
  );
}

/// Runs [action] on the server's post actions; a failure shows as a snack
/// bar starting with [failure].
Future<void> runPostAction(
  BuildContext context,
  String url,
  Future<void> Function(PostActions actions) action,
  String failure,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final actions = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(postActionsProvider(url).future);
  try {
    await action(await actions);
  } on ApiError catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text('$failure ${requestProblemText(e, Uri.parse(url).host)}'),
      ),
    );
  }
}

/// Asks when, then sets the reminder.
Future<void> _remind(BuildContext context, String url, PostItem post) async {
  final messenger = ScaffoldMessenger.of(context);
  final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
  final at = await askReminderTime(context);
  if (at == null || !context.mounted) return;
  final now = DateTime.now();
  if (!at.isAfter(now)) {
    messenger.showSnackBar(
      const SnackBar(content: Text('That time has passed; pick a later one.')),
    );
    return;
  }
  await runPostAction(context, url, (a) async {
    await a.remind(post.id, at);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Reminder set for ${untilLabel(at, now, use24: use24)}'),
      ),
    );
  }, "Couldn't set the reminder.");
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
  final choice = await showAppSheet<({ReminderChoice? preset})>(
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
}) => showAppSheet<void>(
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
