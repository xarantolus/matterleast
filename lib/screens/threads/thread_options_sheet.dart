import 'dart:async';

import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/conversation_actions.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/preference_keys.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/thread_options.dart';
import 'package:matterleast/screens/channel/link_opener.dart';
import 'package:matterleast/screens/home/open_item.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'thread_options_sheet.g.dart';

/// Whether the thread's first post is saved, and the team name its link
/// needs.
@riverpod
Future<({bool saved, String teamName})> threadOptionFacts(
  Ref ref,
  String url,
  String rootId,
  String? teamId,
) async {
  final db = (await ref.watch(serverSessionProvider(url).future)).db;
  final saved =
      await (db.select(db.preferences)..where(
            (p) => p.category.equals(Prefs.flaggedPost) & p.name.equals(rootId),
          ))
          .getSingleOrNull();
  final team = teamId == null
      ? null
      : await (db.select(
          db.teams,
        )..where((t) => t.id.equals(teamId))).getSingleOrNull();
  return (saved: saved?.value == 'true', teamName: team?.name ?? '');
}

/// The sheet for a followed thread of the Threads list or Home.
Future<void> showThreadOptions(BuildContext context, InboxItem item) =>
    showAppSheet<void>(
      context: context,
      builder: (_) => ThreadOptionsSheet(
        item: item,
        navigator: Navigator.of(context),
        messenger: ScaffoldMessenger.of(context),
      ),
    );

class ThreadOptionsSheet extends ConsumerWidget {
  const ThreadOptionsSheet({
    required this.item,
    required this.navigator,
    required this.messenger,
    super.key,
  });

  final InboxItem item;

  /// The screen's, so the actions outlive the sheet.
  final NavigatorState navigator;
  final ScaffoldMessengerState messenger;

  static const _icons = {
    ThreadOption.reply: Icons.reply,
    ThreadOption.unfollow: Icons.notifications_off_outlined,
    ThreadOption.follow: Icons.notifications_active_outlined,
    ThreadOption.openInChannel: Icons.open_in_new,
    ThreadOption.markRead: Icons.done_all,
    ThreadOption.markUnread: Icons.mark_chat_unread_outlined,
    ThreadOption.save: Icons.bookmark_border,
    ThreadOption.unsave: Icons.bookmark_remove,
    ThreadOption.copyLink: Icons.link,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facts = ref
        .watch(
          threadOptionFactsProvider(item.serverUrl, item.rootId!, item.teamId),
        )
        .value;
    final options = threadOptions(
      following: true,
      unread: item.unread,
      saved: facts?.saved ?? false,
      canLink: facts != null && facts.teamName.isNotEmpty,
    );
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              ListTile(
                leading: Icon(_icons[option]),
                title: Text(option.label),
                onTap: () {
                  Navigator.of(context).pop();
                  unawaited(_run(ref, option, facts?.teamName ?? ''));
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _run(WidgetRef ref, ThreadOption option, String teamName) async {
    final url = item.serverUrl;
    final rootId = item.rootId!;
    final team = item.teamId ?? '';
    try {
      switch (option) {
        case ThreadOption.reply:
          await openInboxItem(navigator.context, item);
        case ThreadOption.openInChannel:
          await openPost(navigator, url, rootId);
        case ThreadOption.markRead:
          final session = await ref.read(serverSessionProvider(url).future);
          await ConversationActions(session).markThreadRead(team, rootId);
        case ThreadOption.markUnread:
          final actions = await ref.read(postActionsProvider(url).future);
          await actions.markThreadUnread(team, rootId);
        case ThreadOption.follow:
          final actions = await ref.read(postActionsProvider(url).future);
          await actions.followThread(team, rootId);
        case ThreadOption.unfollow:
          final actions = await ref.read(postActionsProvider(url).future);
          await actions.unfollowThread(team, rootId);
        case ThreadOption.save:
          final actions = await ref.read(postActionsProvider(url).future);
          await actions.savePost(rootId);
        case ThreadOption.unsave:
          final actions = await ref.read(postActionsProvider(url).future);
          await actions.unsavePost(rootId);
        case ThreadOption.copyLink:
          final base = url.replaceFirst(RegExp(r'/+$'), '');
          await Clipboard.setData(
            ClipboardData(text: '$base/$teamName/pl/$rootId'),
          );
      }
    } on ApiError catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't ${option.label.toLowerCase()}. "
            '${requestProblemText(e, Uri.parse(url).host)}',
          ),
        ),
      );
    }
  }
}
