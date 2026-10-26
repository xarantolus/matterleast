import 'dart:async';

import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/post_actions.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/preference_keys.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/ui/emoji_picker.dart';
import 'package:matterleast/ui/reactions_bar.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message_menu.g.dart';

/// What the message menu needs to know beyond the post itself.
typedef PostMenuFacts = ({
  String myId,
  bool saved,

  /// Null when threads can't be followed (no collapsed threads).
  bool? following,

  /// For permalinks; empty when no team is known.
  String teamName,
});

@riverpod
Future<PostMenuFacts> postMenuFacts(
  Ref ref,
  String url,
  PostItem post,
  String teamId,
) async {
  final db = (await ref.watch(serverSessionProvider(url).future)).db;
  final me = await db.syncText(SyncKeys.currentUserId) ?? '';
  final saved =
      await (db.select(db.preferences)..where(
            (p) =>
                p.category.equals(Prefs.flaggedPost) & p.name.equals(post.id),
          ))
          .getSingleOrNull();
  final rootId = post.isReply ? post.rootId : post.id;
  bool? following;
  if (await db.collapsedThreads()) {
    final thread = await (db.select(
      db.threads,
    )..where((t) => t.rootId.equals(rootId))).getSingleOrNull();
    following = thread?.isFollowing ?? false;
  }
  final team = teamId.isNotEmpty
      ? teamId
      : await db.syncText(SyncKeys.currentTeamId) ?? '';
  final teamRow = await (db.select(
    db.teams,
  )..where((t) => t.id.equals(team))).getSingleOrNull();
  return (
    myId: me,
    saved: saved != null && saved.value == 'true',
    following: following,
    teamName: teamRow?.name ?? '',
  );
}

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
  ),
);

class MessageMenu extends ConsumerWidget {
  const MessageMenu({
    required this.url,
    required this.teamId,
    required this.post,
    required this.messenger,
    this.onReply,
    this.onEdit,
    this.onMarkedUnread,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facts = ref.watch(postMenuFactsProvider(url, post, teamId)).value;
    final recent = ref.watch(recentEmojiProvider(url)).value ?? const [];
    if (facts == null) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final quick = {...recent, ..._defaultQuickReactions}.take(6).toList();
    final mine = post.userId == facts.myId;
    final unsent = post.sendState != null;
    final permalink = facts.teamName.isEmpty
        ? null
        : '${url.replaceFirst(RegExp(r'/+$'), '')}/${facts.teamName}/pl/${post.id}';
    final following = facts.following;
    final threadRoot = post.isReply ? post.rootId : post.id;
    void close() => Navigator.of(context).pop();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!unsent && !post.isEphemeral)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final name in quick)
                    IconButton(
                      tooltip: ':$name:',
                      onPressed: () {
                        close();
                        unawaited(
                          _run(ref.read(postActionsProvider(url).future), (
                            a,
                          ) async {
                            final group = post.reactions
                                .where((g) => g.emojiName == name && g.mine)
                                .firstOrNull;
                            if (group == null) {
                              await a.addReaction(post.id, name);
                            }
                          }, "Couldn't add the reaction."),
                        );
                      },
                      icon: EmojiGlyph(name: name, size: 28),
                    ),
                  IconButton.filledTonal(
                    tooltip: 'More reactions',
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final actions = ref.read(postActionsProvider(url).future);
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
              ),
            ),
          if (onReply != null && !unsent)
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
          if (!unsent && !post.isEphemeral) ...[
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
                    (a) =>
                        post.pinned ? a.unpinPost(post.id) : a.pinPost(post.id),
                    post.pinned
                        ? "Couldn't unpin the message."
                        : "Couldn't pin the message.",
                  ),
                );
              },
            ),
            if (!mine)
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
            if (mine && onEdit != null && !post.isSystem)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  close();
                  onEdit!();
                },
              ),
            if (mine)
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

Future<bool> confirmDelete(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Delete message?'),
        content: const Text(
          'The message and its replies are deleted for everyone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ??
    false;

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
