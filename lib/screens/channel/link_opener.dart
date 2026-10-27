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
  Uri uri, {
  bool fromOutside = false,
}) async {
  if (!navigator.mounted) return;
  // The app's container outlives the screen the link was tapped on.
  final ref = ProviderScope.containerOf(navigator.context, listen: false);
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
        await _openPost(navigator, ref, url, postId, fromOutside: fromOutside);
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

/// Opens the message [postId] on the server [url] in its channel (or its
/// thread under collapsed threads), joining first when needed. Says so
/// while the server takes a moment to find it, unless the caller
/// [showsProgress] itself, and why in a snackbar when the server refuses.
/// Completes once the conversation shows.
Future<void> openPost(
  NavigatorState navigator,
  String url,
  String postId, {
  bool fromOutside = false,
  bool showsProgress = false,
}) async {
  if (!navigator.mounted) return;
  final ref = ProviderScope.containerOf(navigator.context, listen: false);
  try {
    await _openPost(
      navigator,
      ref,
      url,
      postId,
      fromOutside: fromOutside,
      showsProgress: showsProgress,
    );
  } on ApiError catch (e) {
    _say(
      navigator,
      "Couldn't open the message. ${requestProblemText(e, Uri.parse(url).host)}",
    );
  }
}

Future<void> _openPost(
  NavigatorState navigator,
  ProviderContainer ref,
  String url,
  String postId, {
  required bool fromOutside,
  bool showsProgress = false,
}) async {
  Future<T> locating<T>(Future<T> Function() work) => showsProgress
      ? work()
      : _saySlow(navigator, 'Opening the message…', work);
  final links = await ref.read(messageLinksProvider(url).future);
  final session = await ref.read(serverSessionProvider(url).future);
  var located = await locating(() => links.locatePost(postId));
  if (located is LinkedPostNeedsJoin) {
    if (located.privateChannel || !navigator.mounted) {
      _notFound(navigator);
      return;
    }
    final join = located;
    if (!await _askJoin(navigator, join)) return;
    final actions = await ref.read(channelActionsProvider(url).future);
    await locating(() async {
      if (!join.inTeam) await actions.joinTeam(join.teamId);
      await actions.join(join.channelId);
    });
    located = await locating<LinkedPost>(() => links.locatePost(postId));
  }
  switch (located) {
    case LinkedPostFound():
      final thread = threadToOpen(
        rootId: located.rootId,
        collapsedThreads: await session.db.collapsedThreads(),
      );
      if (!navigator.mounted) return;
      unawaited(
        openConversation(
          navigator,
          url: url,
          channelId: located.channelId,
          title: located.channelName,
          teamId: located.teamId,
          highlightPostId: postId,
          rootId: thread,
          fromOutside: fromOutside,
        ),
      );
    case LinkedPostMissing() || LinkedPostNeedsJoin():
      _notFound(navigator);
  }
}

/// Opens `~name` of the team [teamName], offering to join an open channel
/// the user is not in, like a channel link.
Future<void> openChannelNamed(
  NavigatorState navigator,
  String url,
  String teamName,
  String name,
) async {
  if (!navigator.mounted) return;
  final ref = ProviderScope.containerOf(navigator.context, listen: false);
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
  ProviderContainer ref,
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
  await openConversation(
    navigator,
    url: url,
    channelId: id,
    title: channel.displayName,
    teamId: channel.stored?.teamId,
  );
}

Future<void> _openDirectMessage(
  NavigatorState navigator,
  ProviderContainer ref,
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
  await openConversation(
    navigator,
    url: url,
    channelId: channelId,
    title: '@$username',
  );
}

Future<bool> _askJoin(NavigatorState navigator, LinkedPostNeedsJoin join) =>
    confirmJoin(
      navigator.context,
      join.channelName,
      why: join.inTeam
          ? "The message is in a channel you're not in."
          : "The message is in ${join.teamName}, a team you're not in, so "
                'you join the team too.',
    );

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

/// Runs [work], saying [message] in a snackbar when it takes long enough
/// to look stuck, and taking it away once done.
Future<T> _saySlow<T>(
  NavigatorState navigator,
  String message,
  Future<T> Function() work,
) async {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? shown;
  final later = Timer(const Duration(milliseconds: 300), () {
    if (!navigator.mounted) return;
    shown = ScaffoldMessenger.maybeOf(navigator.context)?.showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(minutes: 1)),
    );
  });
  try {
    return await work();
  } finally {
    later.cancel();
    shown?.close();
  }
}

void _say(NavigatorState navigator, String message) {
  if (!navigator.mounted) return;
  ScaffoldMessenger.maybeOf(navigator.context)
      ?.showSnackBar(SnackBar(content: Text(message)));
}
