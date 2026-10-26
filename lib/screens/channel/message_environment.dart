import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/emoji_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/message_links.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/markdown/links.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';
import 'package:matterleast/screens/channel/link_opener.dart';
import 'package:matterleast/ui/conversation_route.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/server_image.dart';
import 'package:matterleast/ui/tokens.dart';
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
    final links = await ref.read(messageLinksProvider(url).future);
    final user = await links.userMentioned(typed);
    if (!context.mounted) return;
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheet) => _PersonSheet(user: user, typed: typed),
      ),
    );
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
      navigator.push(
        ConversationRoute<void>(
          builder: (_) => ChannelScreen(
            url: url,
            channelId: channel.id,
            title: channel.displayName,
          ),
        ),
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

class _PersonSheet extends StatelessWidget {
  const _PersonSheet({required this.user, required this.typed});

  final UserRow? user;
  final String typed;

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    final text = Theme.of(context).textTheme;
    final name = user == null
        ? '@$typed'
        : personName((
            username: user.username,
            firstName: user.firstName,
            lastName: user.lastName,
            nickname: user.nickname,
            status: user.status,
          ), 'full_name');
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          0,
          Spacing.lg,
          Spacing.xl,
        ),
        child: Row(
          children: [
            InitialsBadge(name: name, size: 56, round: true),
            const SizedBox(width: Spacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: text.titleLarge),
                  Text(
                    user == null
                        ? 'Not someone this app knows yet'
                        : '@${user.username}'
                              '${user.position.isEmpty ? '' : ' · ${user.position}'}',
                    style: text.bodyMedium?.copyWith(
                      color: context.tokens.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
