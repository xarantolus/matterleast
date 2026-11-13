import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/screens/channel/composer.dart';
import 'package:matterleast/screens/channel/composer_controller.dart';
import 'package:matterleast/screens/channel/message_menu.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/search/switch_picker.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/permalink_card.dart';
import 'package:matterleast/ui/tokens.dart';

/// Conversations a message can be forwarded to.
const _destinations = {
  SwitchKind.channel,
  SwitchKind.privateChannel,
  SwitchKind.direct,
  SwitchKind.group,
  SwitchKind.joinable,
};

Future<SwitchItem?> _pickDestination(BuildContext context, String url) =>
    pickSwitchItem(
      context,
      title: 'Forward to',
      hint: 'Find a channel or conversation',
      serverUrl: url,
      kinds: _destinations,
    );

/// Asks where to forward the message, then shows the composer of that
/// conversation for a comment; sending posts the comment and the link to
/// the message there. Offers to open the destination afterwards.
Future<void> forwardMessage(
  BuildContext context,
  MessageTarget target,
  String permalink,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final url = target.url;
  final first = await _pickDestination(context, url);
  if (first == null || !context.mounted) return;
  final to = await showAppSheet<SwitchItem>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ForwardSheet(
      url: url,
      teamId: target.teamId,
      post: target.post,
      permalink: permalink,
      first: first,
    ),
  );
  if (to == null) return;
  messenger.showSnackBar(
    SnackBar(
      content: Text('Forwarded to ${to.title}'),
      action: SnackBarAction(
        label: 'Open',
        onPressed: () => openConversation(
          navigator,
          url: url,
          channelId: to.id,
          title: to.title,
          teamId: to.teamId,
          followed: true,
        ),
      ),
    ),
  );
}

class _ForwardSheet extends ConsumerStatefulWidget {
  const _ForwardSheet({
    required this.url,
    required this.teamId,
    required this.post,
    required this.permalink,
    required this.first,
  });

  final String url;
  final String teamId;
  final PostItem post;
  final String permalink;
  final SwitchItem first;

  @override
  ConsumerState<_ForwardSheet> createState() => _ForwardSheetState();
}

class _ForwardSheetState extends ConsumerState<_ForwardSheet> {
  late SwitchItem _to = widget.first;

  ComposerDraftProvider _composer(SwitchItem to) =>
      composerDraftProvider(widget.url, to.id, '', forward: widget.permalink);

  Future<void> _change() async {
    final picked = await _pickDestination(context, widget.url);
    if (picked == null || !mounted || picked.id == _to.id) return;
    // What was typed goes with the user to the new conversation.
    final typed = ref.read(_composer(_to)).text;
    ref.read(_composer(picked).notifier).changed(typed);
    setState(() => _to = picked);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final text = Theme.of(context).textTheme;
    final to = _to;
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Text('Forward message', style: text.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Card.outlined(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: text.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      linkedExcerpt(post.message),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            mouseCursor: clickCursor,
            leading: const Icon(Icons.tag),
            title: Text('To ${to.title}'),
            trailing: const Icon(Icons.expand_more),
            onTap: _change,
          ),
          Composer(
            key: ValueKey(to.id),
            url: widget.url,
            channelId: to.id,
            teamId: to.teamId ?? widget.teamId,
            hint: 'Add a comment',
            autofocus: true,
            forward: widget.permalink,
            unjoined: to.kind == SwitchKind.joinable,
            onForwarded: () => Navigator.of(context).pop(to),
          ),
        ],
      ),
    );
  }
}
