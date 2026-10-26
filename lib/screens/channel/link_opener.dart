import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/message_links.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/server_link.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel/message_environment.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [uri] from a message: in the app when it points into a server the
/// user is signed in to, else in the browser. A link [fromOutside] the app
/// asks before it starts a conversation.
Future<void> openLinkFromMessage(
  NavigatorState navigator,
  WidgetRef ref,
  Uri uri, {
  bool fromOutside = false,
}) async {
  final servers = ref.read(serversProvider).value ?? const [];
  final signedIn = {
    for (final s in servers)
      if (s.signedIn) Uri.parse(s.url): s.url,
  };
  final link = parseServerLink(uri, signedIn.keys);
  final url = link == null ? null : signedIn[link.server];
  if (link == null || url == null) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return;
  }
  try {
    switch (link) {
      case PostLink(:final postId):
        await _openPost(navigator, ref, url, postId);
      case ChannelNameLink(:final team, :final name):
        await _openChannelNamed(navigator, ref, url, team, name);
      case DirectMessageLink(:final username):
        await _openDirectMessage(
          navigator,
          ref,
          url,
          username,
          fromOutside: fromOutside,
        );
      case ServerHomeLink():
        ref.read(railSelectionProvider.notifier).select(RailTarget(url: url));
        navigator.popUntil((route) => route.isFirst);
    }
  } on ApiError catch (e) {
    _say(
      navigator,
      "Couldn't open the link. ${requestProblemText(e, link.server.host)}",
    );
  }
}

Future<void> _openPost(
  NavigatorState navigator,
  WidgetRef ref,
  String url,
  String postId,
) async {
  final links = await ref.read(messageLinksProvider(url).future);
  final session = await ref.read(serverSessionProvider(url).future);
  var located = await links.locatePost(postId);
  if (located is LinkedPostNeedsJoin) {
    if (located.privateChannel || !navigator.mounted) {
      _notFound(navigator);
      return;
    }
    final join = located;
    if (!await _askJoin(navigator, join)) return;
    final actions = await ref.read(channelActionsProvider(url).future);
    if (!join.inTeam) await actions.joinTeam(join.teamId);
    await actions.join(join.channelId);
    located = await links.locatePost(postId);
  }
  switch (located) {
    case LinkedPostFound():
      final thread = threadToOpen(
        rootId: located.rootId,
        collapsedThreads: await session.db.collapsedThreads(),
      );
      if (!navigator.mounted) return;
      await openChannel(
        navigator,
        ref,
        url: url,
        channelId: located.channelId,
        title: located.channelName,
        teamId: located.teamId,
        highlightPostId: postId,
        rootId: thread,
      );
    case LinkedPostMissing() || LinkedPostNeedsJoin():
      _notFound(navigator);
  }
}

/// Opens `~name` of the team [teamName], offering to join an open channel
/// the user is not in, like a channel link.
Future<void> openChannelNamed(
  NavigatorState navigator,
  WidgetRef ref,
  String url,
  String teamName,
  String name,
) async {
  try {
    await _openChannelNamed(navigator, ref, url, teamName, name);
  } on ApiError catch (e) {
    _say(
      navigator,
      "Couldn't open ~$name. ${requestProblemText(e, Uri.parse(url).host)}",
    );
  }
}

Future<void> _openChannelNamed(
  NavigatorState navigator,
  WidgetRef ref,
  String url,
  String teamName,
  String name,
) async {
  final links = await ref.read(messageLinksProvider(url).future);
  final channel = await links.channelLinked(teamName, name);
  final id = channel?.id;
  if (channel == null || id == null) {
    _say(navigator, "~$name isn't a channel you can open.");
    return;
  }
  if (channel.stored == null) {
    if (!channel.open || !navigator.mounted) {
      _say(navigator, "~$name is a private channel you're not in.");
      return;
    }
    if (!await confirmJoin(navigator.context, channel.displayName)) return;
    final actions = await ref.read(channelActionsProvider(url).future);
    await actions.join(id);
  }
  if (!navigator.mounted) return;
  await openChannel(
    navigator,
    ref,
    url: url,
    channelId: id,
    title: channel.displayName,
    teamId: channel.stored?.teamId,
  );
}

Future<void> _openDirectMessage(
  NavigatorState navigator,
  WidgetRef ref,
  String url,
  String username, {
  required bool fromOutside,
}) async {
  final links = await ref.read(messageLinksProvider(url).future);
  final userId = await links.userIdMentioned(username);
  if (userId == null) {
    _say(navigator, "There's nobody called @$username on this server.");
    return;
  }
  final actions = await ref.read(channelActionsProvider(url).future);
  // A link alone never starts a conversation; another app or a web page
  // could aim it at anyone.
  if (fromOutside &&
      await actions.storedDirectChannel(userId) == null &&
      (!navigator.mounted ||
          !await confirm(
            navigator.context,
            title: 'Message @$username?',
            body:
                'A link from outside the app opens a conversation with '
                "@$username. You haven't messaged them yet.",
            action: 'Message',
          ))) {
    return;
  }
  final channelId = await actions.directChannel(userId);
  if (!navigator.mounted) return;
  await openChannel(
    navigator,
    ref,
    url: url,
    channelId: channelId,
    title: '@$username',
  );
}

Future<bool> _askJoin(
  NavigatorState navigator,
  LinkedPostNeedsJoin join,
) async =>
    await showDialog<bool>(
      context: navigator.context,
      builder: (context) => AlertDialog(
        title: Text('Join ${join.channelName}?'),
        content: Text(
          join.inTeam
              ? "The message is in a channel you're not in. Join it to read "
                    'the message there.'
              : "The message is in ${join.teamName}, a team you're not in. "
                    'Join the team and the channel to read it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Join'),
          ),
        ],
      ),
    ) ??
    false;

void _notFound(NavigatorState navigator) {
  if (!navigator.mounted) return;
  unawaited(
    showDialog<void>(
      context: navigator.context,
      builder: (context) => AlertDialog(
        title: const Text('Message not found'),
        content: const Text(
          "It was deleted, or it's in a channel you can't see.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    ),
  );
}

void _say(NavigatorState navigator, String message) {
  if (!navigator.mounted) return;
  ScaffoldMessenger.maybeOf(navigator.context)
      ?.showSnackBar(SnackBar(content: Text(message)));
}
