import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/domain/conversation_open.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/screens/channel/composer_controller.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_state.dart';
import 'package:matterleast/screens/channel/message_environment.dart';
import 'package:matterleast/screens/channel/message_menu.dart';
import 'package:matterleast/ui/anchored_list.dart';
import 'package:matterleast/ui/emoji_picker.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/post_tile.dart';
import 'package:matterleast/ui/swipe_to_open.dart';
import 'package:matterleast/ui/tokens.dart';

/// The message list of a channel or thread with its loading states and the
/// pills that move through it.
class ConversationView extends ConsumerStatefulWidget {
  const ConversationView({
    required this.url,
    required this.conversation,
    required this.startText,
    this.onOpenThread,
    this.composer,
    super.key,
  });

  final String url;
  final ConversationProvider conversation;

  /// Where Edit puts a message; null where nothing can be written.
  final ComposerDraftProvider? composer;

  /// Shown above the oldest message once nothing older exists.
  final String? startText;
  final ValueChanged<PostItem>? onOpenThread;

  @override
  ConsumerState<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends ConsumerState<ConversationView> {
  final _list = AnchoredListController();
  late final Conversation _controller = ref.read(widget.conversation.notifier);
  AnchoredListView? _view;
  ({int generation, AnchoredPosition? anchor})? _opened;
  Object? _highlighted;
  Timer? _highlightTimer;
  var _lineSeen = false;

  /// When the reader scrolled away from the bottom; what arrives after
  /// counts as new below.
  DateTime? _leftBottomAt;

  static const _arrivalAnimation = Duration(milliseconds: 250);

  @override
  void dispose() {
    _controller.leave(_list.position);
    _highlightTimer?.cancel();
    super.dispose();
  }

  /// Where a list for this generation opens, decided once.
  AnchoredPosition? _openAt(ConversationState state, double height) {
    final opened = _opened;
    if (opened != null && opened.generation == state.generation) {
      return opened.anchor;
    }
    final at = state.intent == OpenIntent.bottom
        ? const OpenAtBottom()
        : openPosition(
            rows: state.rows,
            height: height,
            now: DateTime.now().toUtc(),
            highlightKey: state.highlightKey,
            saved: state.saved,
          );
    final anchor = switch (at) {
      OpenAtBottom() => null,
      OpenAtRow(:final key, :final offset) => (key: key, offset: offset),
      OpenCentred(:final key) => (key: key, offset: height / 2),
    };
    if (at case OpenCentred(:final key)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _list.centre(key));
      _highlight(key);
    }
    _opened = (generation: state.generation, anchor: anchor);
    return anchor;
  }

  bool _justArrived(DateTime? at, DateTime now) =>
      at != null && now.difference(at) < _arrivalAnimation;

  void _highlight(Object key) {
    _highlighted = key;
    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _highlighted = null);
    });
  }

  void _onView(AnchoredListView view) {
    final rows = ref.read(widget.conversation).rows;
    final line = rows.indexWhere((r) => r is NewMessagesLine);
    final newest = view.newestVisible;
    final oldest = view.oldestVisible;
    if (line >= 0 && newest != null && oldest != null) {
      if (line >= newest && line <= oldest) _lineSeen = true;
    }
    setState(() {
      _view = view;
      _leftBottomAt = view.pinned ? null : (_leftBottomAt ?? DateTime.now());
    });
    _controller.onView(view);
  }

  void _jumpToLine(List<ListRow> rows, double height) {
    final line = rows.indexWhere((r) => r is NewMessagesLine);
    if (line < 0) return;
    setState(() => _lineSeen = true);
    if (line + 1 < rows.length) {
      _list.jumpTo(rows[line + 1].key, offset: height * 0.75);
    } else {
      _list.jumpTo(rows[line].key, offset: height * 0.75 - 32);
    }
  }

  void _showLatest(ConversationState state) {
    _controller.showLatest();
    if (!(state.window?.newerApart ?? false)) {
      unawaited(_list.animateToBottom());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.conversation);
    final host = Uri.parse(widget.url).host;
    return switch (conversationBody(state, host: host)) {
      BodyLoading() => const Center(child: CircularProgressIndicator()),
      BodyFailed(:final text) => EmptyState(
        icon: Icons.cloud_off,
        title: "Couldn't load messages",
        body: text,
        action: FilledButton.tonal(
          onPressed: _controller.retry,
          child: const Text('Retry'),
        ),
      ),
      BodyEmpty() => const EmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'No messages yet. Say hello.',
        body: 'Messages posted here show up in this space.',
      ),
      BodyReady() => LayoutBuilder(
        builder: (context, constraints) => _ready(state, constraints.maxHeight),
      ),
    };
  }

  Widget _ready(ConversationState state, double height) {
    final rows = state.rows;
    final view = _view;
    final now = DateTime.now();
    final newestVisible = view?.newestVisible ?? 0;
    final newBelow = [
      for (final row in rows.take(newestVisible))
        if (row is MessageRow &&
            (state.arrived[row.key]?.isAfter(_leftBottomAt ?? now) ?? false))
          row,
    ].length;
    final line = rows.indexWhere((r) => r is NewMessagesLine);
    final lineAbove =
        !_lineSeen &&
        line >= 0 &&
        view?.oldestVisible != null &&
        line > view!.oldestVisible!;
    final apart = state.window?.newerApart ?? false;
    final scrolledUp = view != null && !view.pinned;
    return Stack(
      children: [
        MessageEnvironment(
          url: widget.url,
          teamId: state.window?.teamId ?? '',
          child: AnchoredList<ListRow>(
            key: ValueKey(state.generation),
            rows: rows,
            keyOf: (row) => row.key,
            controller: _list,
            initialAnchor: _openAt(state, height),
            onViewChanged: _onView,
            olderEdge: _OlderEdge(
              state: state,
              startText: widget.startText,
              onRetry: _controller.retryOlder,
            ),
            itemBuilder: (context, row) => switch (row) {
              MessageRow(:final post, :final compact, :final combined) =>
                AppearOnce(
                  animate: _justArrived(state.arrived[row.key], now),
                  child: _message(state, post, compact, combined),
                ),
              DaySeparator(:final day) => DaySeparatorTile(day: day),
              NewMessagesLine() => const NewMessagesTile(),
            },
          ),
        ),
        if (lineAbove)
          Positioned(
            top: Spacing.sm,
            left: 0,
            right: 0,
            child: Center(
              child: ActionChip(
                avatar: const Icon(Icons.arrow_upward, size: 18),
                label: Text(switch ((rows[line] as NewMessagesLine).count) {
                  1 => '1 new message',
                  final n => '$n new messages',
                }),
                onPressed: () => _jumpToLine(rows, height),
              ),
            ),
          ),
        if (apart)
          Positioned(
            bottom: Spacing.lg,
            left: 0,
            right: 0,
            child: Center(
              child: FilledButton.tonalIcon(
                onPressed: () => _showLatest(state),
                icon: const Icon(Icons.arrow_downward),
                label: const Text('Jump to latest'),
              ),
            ),
          )
        else if (scrolledUp)
          Positioned(
            bottom: Spacing.lg,
            right: Spacing.lg,
            child: Badge.count(
              count: newBelow,
              isLabelVisible: newBelow > 0,
              child: FloatingActionButton.small(
                heroTag: null,
                tooltip: newBelow > 0 ? '$newBelow new' : 'Jump to latest',
                onPressed: () => _showLatest(state),
                child: const Icon(Icons.arrow_downward),
              ),
            ),
          ),
      ],
    );
  }
}

extension on _ConversationViewState {
  Widget _message(
    ConversationState state,
    PostItem post,
    bool compact,
    List<PostItem> combined,
  ) {
    final teamId = state.window?.teamId ?? '';
    final usable = !post.isSystem && !post.deleted;
    final tile = PostTile(
      post: post,
      compact: compact,
      combined: combined,
      highlighted: _highlighted == post.key,
      onOpenThread: widget.onOpenThread == null
          ? null
          : () => widget.onOpenThread!(post),
      onDismiss: post.isEphemeral
          ? () async =>
                (await ref.read(composerActionsProvider(widget.url).future))
                    .dismissEphemeral(post.id)
          : null,
      onToggleReaction: post.sendState == null
          ? (name) => _toggleReaction(post, name)
          : null,
      onAddReaction: post.sendState == null ? () => _pickReaction(post) : null,
    );
    if (post.sendState == 'failed') {
      return InkWell(
        onTap: () => showFailedPostSheet(context, url: widget.url, post: post),
        child: tile,
      );
    }
    if (!usable) return tile;
    void open() {
      FocusManager.instance.primaryFocus?.unfocus();
      unawaited(_menu(post, teamId));
    }

    return SwipeToOpen(
      onOpen: open,
      child: InkWell(onLongPress: open, child: tile),
    );
  }

  Future<void> _menu(PostItem post, String teamId) => showMessageMenu(
    context,
    url: widget.url,
    teamId: teamId,
    post: post,
    onReply: widget.onOpenThread == null
        ? null
        : () => widget.onOpenThread!(post),
    onEdit: switch (widget.composer) {
      final composer? => () => ref.read(composer.notifier).startEditing(post),
      null => null,
    },
    onMarkedUnread: () => _controller.markedUnread(post),
  );

  Future<void> _toggleReaction(PostItem post, String name) async {
    final messenger = ScaffoldMessenger.of(context);
    final actions = await ref.read(postActionsProvider(widget.url).future);
    final mine = post.reactions.any((g) => g.emojiName == name && g.mine);
    try {
      if (mine) {
        await actions.removeReaction(post.id, name);
      } else {
        await actions.addReaction(post.id, name);
      }
    } on ApiError {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't change the reaction. Check the connection and try again.",
          ),
        ),
      );
    }
  }

  Future<void> _pickReaction(PostItem post) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final actions = ref.read(postActionsProvider(widget.url).future);
    final picked = await showEmojiPicker(context, widget.url);
    if (picked == null) return;
    await (await actions)
        .addReaction(post.id, picked)
        .catchError((Object _) {});
  }
}

/// Above the oldest message: a spinner while older ones load, a retry
/// after a failure, or where the conversation starts.
class _OlderEdge extends StatelessWidget {
  const _OlderEdge({
    required this.state,
    required this.startText,
    required this.onRetry,
  });

  final ConversationState state;
  final String? startText;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final window = state.window;
    if (window == null) return const SizedBox.shrink();
    if (window.reachesStart) {
      final text = startText;
      if (text == null) return const SizedBox(height: Spacing.sm);
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.xl,
          Spacing.lg,
          Spacing.lg,
        ),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
    }
    if (state.olderFailed) {
      return Center(
        child: TextButton(
          onPressed: onRetry,
          child: const Text("Couldn't load older messages · Retry"),
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.all(Spacing.md),
      child: Center(
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
