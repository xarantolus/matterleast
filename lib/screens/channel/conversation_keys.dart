import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/keyboard_shortcuts.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/root/open_panes.dart';

/// The conversation's own keys, over its messages and its composer: Ctrl+
/// Shift+L into the message field, and Esc marking the channel read when
/// it has a new-messages line and nothing is open over it to close first.
class ConversationKeys extends ConsumerStatefulWidget {
  const ConversationKeys({
    required this.conversation,
    required this.isThread,
    required this.builder,
    super.key,
  });

  final ConversationProvider conversation;
  final bool isThread;

  /// Builds the conversation with the focus node its composer takes.
  final Widget Function(FocusNode composer) builder;

  @override
  ConsumerState<ConversationKeys> createState() => _ConversationKeysState();
}

class _ConversationKeysState extends ConsumerState<ConversationKeys> {
  final _composer = FocusNode(debugLabel: 'composer');

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  bool get _canMarkRead =>
      !widget.isThread &&
      ref.read(widget.conversation).rows.any((row) => row is NewMessagesLine) &&
      ref.read(paneRoutesProvider).stack.isEmpty &&
      ref.read(openPanesProvider).thread == null;

  @override
  Widget build(BuildContext context) => Actions(
    actions: {
      FocusComposerIntent: EnabledAction<FocusComposerIntent>(
        enabled: () => _composer.context != null,
        onInvoke: (_) => _composer.requestFocus(),
      ),
      MarkReadIntent: EnabledAction<MarkReadIntent>(
        enabled: () => _canMarkRead,
        onInvoke: (_) =>
            unawaited(ref.read(widget.conversation.notifier).markRead()),
      ),
    },
    child: widget.builder(_composer),
  );
}
