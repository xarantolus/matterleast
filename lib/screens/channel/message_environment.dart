import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/emoji_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/message_links.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/markdown/links.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/screens/channel/link_opener.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/you/user_profile_sheet.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/server_image.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message_environment.g.dart';

@riverpod
Future<MessageLinks> messageLinks(Ref ref, String url) async =>
    MessageLinks(await ref.watch(serverSessionProvider(url).future));

@riverpod
Stream<ParseOptions> parseOptions(Ref ref, String url) async* {
  final links = await ref.watch(messageLinksProvider(url).future);
  yield* links.parseOptions();
}

/// Gives the message bodies below it the server's parse options and what
/// taps on mentions, channel links and links do.
class MessageEnvironment extends ConsumerWidget {
  const MessageEnvironment({
    required this.url,
    required this.teamId,
    required this.child,
    super.key,
  });

  final String url;
  final String teamId;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options =
        ref.watch(parseOptionsProvider(url)).value ?? const ParseOptions();
    final me = ref.watch(currentUserProvider(url)).value;
    final emoji = ref.watch(customEmojiProvider(url)).value ?? const {};
    final resolver = ref.watch(customEmojiResolverProvider(url)).value;
    return PostEnvironment(
      server: Uri.parse(url),
      options: options,
      myUsername: me?.username ?? '',
      onMention: (name) => _showPerson(context, ref, name),
      onChannel: (name) => _openChannel(context, ref, name),
      onLink: (target) => _openLink(context, ref, target),
      customEmoji: (name, size) {
        if (!emoji.containsKey(name)) {
          resolver?.want([name]);
          return null;
        }
        return EmojiGlyph(name: name, size: size, serverUrl: url);
      },
      image: (imageUrl, size) => ServerImage(
        serverUrl: url,
        url: imageUrl,
        width: size.width,
        height: size.height,
      ),
      child: child,
    );
  }

  Future<void> _showPerson(
    BuildContext context,
    WidgetRef ref,
    String typed,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final links = ref.read(messageLinksProvider(url).future);
    final String? userId;
    try {
      userId = await (await links).userIdMentioned(typed);
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't look up @$typed. "
            '${requestProblemText(e, Uri.parse(url).host)}',
          ),
        ),
      );
      return;
    }
    if (!context.mounted) return;
    if (userId == null) {
      messenger.showSnackBar(
        SnackBar(content: Text('No one on this server is called @$typed.')),
      );
      return;
    }
    unawaited(showUserProfile(context, url: url, userId: userId));
  }

  Future<void> _openChannel(
    BuildContext context,
    WidgetRef ref,
    String name,
  ) async {
    final navigator = Navigator.of(context);
    final links = await ref.read(messageLinksProvider(url).future);
    final channel = await links.channelNamed(name, teamId: teamId);
    if (channel == null) {
      final team = await links.teamName(teamId);
      if (team != null) {
        await openChannelNamed(navigator, ref, url, team, name);
        return;
      }
    }
    if (!navigator.mounted) return;
    if (channel == null) {
      ScaffoldMessenger.of(navigator.context).showSnackBar(
        SnackBar(content: Text("~$name isn't a channel you're in.")),
      );
      return;
    }
    unawaited(
      openConversation(
        navigator,
        url: url,
        channelId: channel.id,
        title: channel.displayName,
        teamId: channel.teamId,
      ),
    );
  }

  Future<void> _openLink(
    BuildContext context,
    WidgetRef ref,
    LinkTarget target,
  ) async {
    switch (target) {
      case UriLink(:final uri):
        await openLinkFromMessage(Navigator.of(context), ref, uri);
      case NoLink():
        return;
    }
  }
}
