import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/emoji_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/integration_actions.dart';
import 'package:matterleast/data/actions/message_links.dart';
import 'package:matterleast/data/db/throttled_watch.dart';
import 'package:matterleast/data/emoji/custom_emoji.dart';
import 'package:matterleast/domain/integration_blocks.dart';
import 'package:matterleast/domain/preference_keys.dart';
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

/// Kept while the app runs, so a second tap joins an action still running.
@Riverpod(keepAlive: true)
Future<IntegrationActions> integrationActions(Ref ref, String url) async =>
    IntegrationActions(await ref.watch(serverSessionProvider(url).future));

@riverpod
Stream<ParseOptions> parseOptions(Ref ref, String url) async* {
  final links = await ref.watch(messageLinksProvider(url).future);
  yield* links.parseOptions();
}

/// What message rows show of what integrations and links bring: preview
/// cards when the server and the user's setting allow them, names and
/// pictures integrations chose only when the server allows overriding,
/// Mattermost's own interactive blocks when the server has them on.
typedef PostDisplay = ({
  bool linkPreviews,
  bool usernameOverride,
  bool iconOverride,
  bool mmBlocks,
});

@riverpod
Stream<PostDisplay> postDisplay(Ref ref, String url) async* {
  final db = (await ref.watch(serverSessionProvider(url).future)).db;
  yield* throttledWatch(
    db.tableUpdates(TableUpdateQuery.onAllTables([db.config, db.preferences])),
    () async {
      final features = await db.features();
      final mine = await db.preference(
        Prefs.linkPreviews.$1,
        Prefs.linkPreviews.$2,
      );
      return (
        linkPreviews: features.linkPreviews && mine != 'false',
        usernameOverride: features.usernameOverride,
        iconOverride: features.iconOverride,
        mmBlocks: features.flag('MmBlocksEnabled'),
      );
    },
    interval: const Duration(milliseconds: 300),
  ).distinct();
}

/// Gives the message bodies below it the server's parse options and what
/// taps on mentions, channel links and links do. The rows are built only
/// once the parse options and the custom emoji are known, so they are laid
/// out once, at their final size; the values handed down stay identical
/// while nothing changes, so rows don't rebuild for nothing.
class MessageEnvironment extends ConsumerStatefulWidget {
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
  ConsumerState<MessageEnvironment> createState() => _MessageEnvironmentState();

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
        // Nothing may take focus back when the reader returns.
        FocusManager.instance.primaryFocus?.unfocus();
        await openLinkFromMessage(Navigator.of(context), ref, uri);
      case NoLink():
        return;
    }
  }

  Future<void> _runAction(
    BuildContext context,
    WidgetRef ref,
    PostActionRequest request,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final server = Uri.parse(url);
    try {
      final actions = await ref.read(integrationActionsProvider(url).future);
      final location = await actions.run(request);
      if (location == null || !navigator.mounted) return;
      if (classifyLink(location, server) case UriLink(:final uri)) {
        FocusManager.instance.primaryFocus?.unfocus();
        await openLinkFromMessage(navigator, ref, uri);
      }
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(requestProblemText(e, server.host))),
      );
    }
  }
}

class _MessageEnvironmentState extends ConsumerState<MessageEnvironment> {
  late final _server = Uri.parse(widget.url);
  Map<String, String>? _emoji;
  Object? _resolver;
  Widget? Function(String, double)? _customEmoji;

  void _onMention(String name) => widget._showPerson(context, ref, name);

  void _onChannel(String name) => widget._openChannel(context, ref, name);

  void _onLink(LinkTarget target) => widget._openLink(context, ref, target);

  Future<void> _onAction(PostActionRequest request) =>
      widget._runAction(context, ref, request);

  Widget _image(String imageUrl, Size size) => ServerImage(
    serverUrl: widget.url,
    url: imageUrl,
    width: size.width,
    height: size.height,
  );

  Widget? Function(String, double) _emojiLookup(
    Map<String, String> emoji,
    CustomEmojiResolver? resolver,
  ) {
    if (_customEmoji case final same?
        when identical(emoji, _emoji) && identical(resolver, _resolver)) {
      return same;
    }
    _emoji = emoji;
    _resolver = resolver;
    final url = widget.url;
    return _customEmoji = (name, size) {
      if (!emoji.containsKey(name)) {
        resolver?.want([name]);
        return null;
      }
      return EmojiGlyph(name: name, size: size, serverUrl: url);
    };
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.url;
    final options = ref.watch(parseOptionsProvider(url));
    final emoji = ref.watch(customEmojiProvider(url));
    bool known(AsyncValue<Object?> v) => v.hasValue || v.hasError;
    if (!known(options) || !known(emoji)) {
      return const SizedBox.expand();
    }
    final me = ref.watch(currentUserProvider(url)).value;
    final resolver = ref.watch(customEmojiResolverProvider(url)).value;
    final display = ref.watch(postDisplayProvider(url)).value;
    return PostEnvironment(
      server: _server,
      options: options.value ?? const ParseOptions(),
      myUsername: me?.username ?? '',
      onMention: _onMention,
      onChannel: _onChannel,
      onLink: _onLink,
      customEmoji: _emojiLookup(emoji.value ?? const {}, resolver),
      image: _image,
      linkPreviews: display?.linkPreviews ?? true,
      usernameOverride: display?.usernameOverride ?? false,
      iconOverride: display?.iconOverride ?? false,
      mmBlocks: display?.mmBlocks ?? false,
      onAction: _onAction,
      child: widget.child,
    );
  }
}
