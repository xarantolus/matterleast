import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/domain/conversation_open.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel/composer_controller.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_state.dart';
import 'package:matterleast/screens/channel/message_environment.dart';
import 'package:matterleast/screens/channel/message_hover.dart';
import 'package:matterleast/screens/channel/message_menu.dart';
import 'package:matterleast/screens/channel/reading_places.dart';
import 'package:matterleast/ui/anchored_list.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/markdown/show_more.dart';
import 'package:matterleast/ui/post_tile.dart';
import 'package:matterleast/ui/swipe_to_open.dart';
import 'package:matterleast/ui/tokens.dart';

/// Opens the thread of [post]; for a [reply] with the keyboard up.
/// Opens the thread of a message; completes when the user is back.
typedef OpenThread = Future<void> Function(PostItem post, {bool reply});

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
  final OpenThread? onOpenThread;

  @override
  ConsumerState<ConversationView> createState() => _ConversationViewState();
}

const _refocusDelay = Duration(milliseconds: 600);

class _ConversationViewState extends ConsumerState<ConversationView> {
  final _list = AnchoredListController();
  late final Conversation _controller;
  late final ReadingPlaces _places;
  final _view = ValueNotifier<AnchoredListView?>(null);
  final _lineSeen = ValueNotifier(false);
  ({int generation, AnchoredPosition? anchor})? _opened;
  Object? _highlighted;
  Timer? _highlightTimer;
  final _expanded = <String>{};
  late ConversationState _state;

  /// The built widget of each row, handed out again while the row is
  /// unchanged, so an update rebuilds only the rows that changed.
  final _built = <Object, _BuiltRow>{};
  var _builtGeneration = -1;

  /// When the reader scrolled away from the bottom; what arrives after
  /// counts as new below.
  DateTime? _leftBottomAt;

  static const _arrivalAnimation = Duration(milliseconds: 250);

  /// Room between the newest message and the composer, which also holds
  /// the typing line, and keeps the way back down off the newest message.
  static const _bottomGap = Spacing.xxl + Spacing.lg;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(widget.conversation.notifier);
    _places = ref.read(readingPlacesProvider)
      ..attach(widget.conversation, _list);
  }

  @override
  void dispose() {
    _places.detach(widget.conversation, _list);
    _controller.leave(_list.position);
    _highlightTimer?.cancel();
    _view.dispose();
    _lineSeen.dispose();
    super.dispose();
  }

  /// Where a list for this generation opens, decided once.
  AnchoredPosition? _openAt(ConversationState state, double height) {
    final opened = _opened;
    if (opened != null && opened.generation == state.generation) {
      return opened.anchor;
    }
    final handed = opened == null ? _places.take(widget.conversation) : null;
    final at =
        handed ??
        (state.intent == OpenIntent.bottom
            ? const OpenAtBottom()
            : openPosition(
                rows: state.rows,
                height: height,
                now: DateTime.now().toUtc(),
                highlightKey: state.highlightKey,
                saved: state.saved,
              ));
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
    final rows = _state.rows;
    final line = rows.indexWhere((r) => r is NewMessagesLine);
    final newest = view.newestVisible;
    final oldest = view.oldestVisible;
    if (line >= 0 && newest != null && oldest != null) {
      if (line >= newest && line <= oldest) _lineSeen.value = true;
    }
    _leftBottomAt = view.pinned ? null : (_leftBottomAt ?? DateTime.now());
    _view.value = view;
    _controller.onView(view);
  }

  void _jumpToLine(List<ListRow> rows, double height) {
    final line = rows.indexWhere((r) => r is NewMessagesLine);
    if (line < 0) return;
    _lineSeen.value = true;
    if (line + 1 < rows.length) {
      _list.jumpTo(rows[line + 1].key, offset: height * 0.75);
    } else {
      _list.jumpTo(rows[line].key, offset: height * 0.75 - 32);
    }
  }

  void _changed(ConversationState? before, ConversationState after) {
    if (before == null) return;
    // What the user sends shows where they can see it go out.
    if (sentJustNow(before, after) && !(_view.value?.pinned ?? true)) {
      _showLatest(after);
    }
    _announce(before, after);
  }

  /// Tells a screen reader what arrived or failed; nothing without one.
  void _announce(ConversationState before, ConversationState after) {
    if (!MediaQuery.accessibleNavigationOf(context)) return;
    // A conversation under a thread or sheet doesn't talk over it.
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
    final news = conversationNews(before, after);
    if (news.isEmpty) return;
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        news.join('. '),
        Directionality.of(context),
      ),
    );
  }

  /// Opens the thread of [post] and, when a screen reader had its focus on
  /// the message, puts it back there once the thread closes. The navigator
  /// tries that too, but by the message's old semantics node, which is
  /// gone when the row was rebuilt meanwhile.
  Future<void> _openThread(PostItem post, {bool reply = false}) async {
    final open = widget.onOpenThread;
    if (open == null) return;
    final focus = ServicesBinding.instance.accessibilityFocus;
    final before = focus.value;
    final closed = open(post, reply: reply);
    // A thread beside the channel in a pane leaves the focus alone.
    final covered = !(ModalRoute.of(context)?.isCurrent ?? true);
    await closed;
    if (before == null || !covered || !mounted) return;
    await _uncovered();
    // After the navigator's own attempt, which waits about as long.
    await Future<void>.delayed(_refocusDelay);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || focus.value == before) return;
    _messageRow(post.id)
        ?.findRenderObject()
        ?.sendSemanticsEvent(const FocusSemanticEvent());
  }

  /// Completes once the route over this one has slid away.
  Future<void> _uncovered() {
    final cover = ModalRoute.of(context)?.secondaryAnimation;
    if (cover == null || cover.isDismissed) return Future.value();
    final done = Completer<void>();
    void listen(AnimationStatus status) {
      if (!status.isDismissed) return;
      cover.removeStatusListener(listen);
      done.complete();
    }

    cover.addStatusListener(listen);
    return done.future;
  }

  /// The row of [postId], if it is built.
  Element? _messageRow(String postId) {
    Element? found;
    void visit(Element element) {
      if (found != null) return;
      if (element.widget case PostTile(:final post) when post.id == postId) {
        found = element;
        return;
      }
      element.visitChildElements(visit);
    }

    (context as Element).visitChildElements(visit);
    return found;
  }

  void _showLatest(ConversationState state) {
    _controller.showLatest();
    if (!(state.window?.newerApart ?? false)) {
      unawaited(_list.animateToBottom());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(widget.conversation, _changed);
    final state = ref.watch(widget.conversation);
    _state = state;
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

  static Object _keyOf(ListRow row) => row.key;

  Widget _row(BuildContext context, ListRow row) {
    final state = _state;
    if (_builtGeneration != state.generation) {
      _built.clear();
      _builtGeneration = state.generation;
    }
    final rows = state.rows;
    final newest = rows.isNotEmpty && identical(rows.first, row);
    final root = state.window?.root?.key;
    var dividerBelow = false;
    if (root != null && row.key == root && !newest) {
      final index = rows.indexOf(row);
      dividerBelow = index > 0 && rows[index - 1] is! DaySeparator;
    }
    final highlighted = _highlighted == row.key;
    final cached = _built[row.key];
    if (cached != null &&
        cached.row == row &&
        cached.highlighted == highlighted &&
        cached.newest == newest &&
        cached.dividerBelow == dividerBelow) {
      return cached.widget;
    }
    Widget built = switch (row) {
      MessageRow(:final post, :final compact, :final combined) => AppearOnce(
        animate: _justArrived(state.arrived[row.key], DateTime.now()),
        child: _message(post, compact, combined, highlighted: highlighted),
      ),
      DaySeparator(:final day) => DaySeparatorTile(day: day),
      NewMessagesLine() => const NewMessagesTile(),
    };
    if (dividerBelow) {
      built = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          built,
          const Divider(height: Spacing.lg),
        ],
      );
    }
    if (newest) {
      built = Padding(
        padding: const EdgeInsets.only(bottom: _bottomGap),
        child: built,
      );
    }
    _built[row.key] = (
      row: row,
      highlighted: highlighted,
      newest: newest,
      dividerBelow: dividerBelow,
      widget: built,
    );
    if (_built.length > rows.length * 2) {
      final keys = {for (final r in rows) r.key};
      _built.removeWhere((key, _) => !keys.contains(key));
    }
    return built;
  }

  Widget _ready(ConversationState state, double height) => Stack(
    children: [
      ShowMoreMemory(
        expanded: _expanded,
        child: MessageEnvironment(
          url: widget.url,
          teamId: state.window?.teamId ?? '',
          // The hover toolbar floats over the rows, clipped to the list.
          child: Overlay.wrap(
            child: AnchoredList<ListRow>(
              key: ValueKey(state.generation),
              rows: state.rows,
              keyOf: _keyOf,
              controller: _list,
              initialAnchor: _openAt(state, height),
              onViewChanged: _onView,
              olderEdge: _OlderEdge(
                state: state,
                host: Uri.parse(widget.url).host,
                startText: widget.startText,
                onRetry: _controller.retryOlder,
              ),
              itemBuilder: _row,
            ),
          ),
        ),
      ),
      Positioned.fill(
        child: ListenableBuilder(
          listenable: Listenable.merge([_view, _lineSeen]),
          builder: (context, _) => _pills(state, height),
        ),
      ),
    ],
  );

  /// The "N new" chip above and the way back down below, which follow the
  /// reader without rebuilding the list.
  Widget _pills(ConversationState state, double height) {
    final rows = state.rows;
    final view = _view.value;
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
        !_lineSeen.value &&
        line >= 0 &&
        view?.oldestVisible != null &&
        line > view!.oldestVisible!;
    final apart = state.window?.newerApart ?? false;
    final scrolledUp = view != null && !view.pinned;
    return Stack(
      children: [
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
            bottom: Spacing.sm,
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

const _replyAction = CustomSemanticsAction(label: 'Reply');
const _reactAction = CustomSemanticsAction(label: 'Add reaction');
const _menuAction = CustomSemanticsAction(label: 'Message options');

typedef _BuiltRow = ({
  ListRow row,
  bool highlighted,
  bool newest,
  bool dividerBelow,
  Widget widget,
});

extension on _ConversationViewState {
  Widget _message(
    PostItem post,
    bool compact,
    List<PostItem> combined, {
    required bool highlighted,
  }) {
    final usable = !post.isSystem && !post.deleted && !post.unreadable;
    final threads = widget.onOpenThread != null;
    // An archived channel is read-only, reactions included.
    final reacts =
        post.sendState == null && !(_state.window?.archived ?? false);
    void openThread() => unawaited(_openThread(post));
    void reply() => unawaited(_openThread(post, reply: true));
    final target = _target(post);
    void open() => unawaited(showMessageMenu(context, target));

    final failed = post.sendState == 'failed';
    final tappable = usable && threads && post.sendState == null;
    // With a mouse a click selects text; the toolbar, the right click and
    // the replies bar take over what a tap and a long press do on a phone.
    final desktop = isDesktop;
    final tile = PostTile(
      post: post,
      compact: compact,
      combined: combined,
      highlighted: highlighted,
      onOpenThread: threads ? openThread : null,
      onDismiss: post.isEphemeral
          ? () async =>
                (await ref.read(composerActionsProvider(widget.url).future))
                    .dismissEphemeral(post.id)
          : null,
      onToggleReaction: reacts
          ? (name) => unawaited(toggleReaction(context, widget.url, post, name))
          : null,
      onAddReaction: reacts
          ? (anchor) => unawaited(
              pickReaction(context, widget.url, post, anchor: anchor),
            )
          : null,
      onAcknowledge: reacts ? () => _toggleAcknowledged(post) : null,
      onTap: failed
          ? () => showFailedPostSheet(context, url: widget.url, post: post)
          : tappable && !desktop
          ? openThread
          : null,
      tapHint: failed ? 'try again or delete' : 'open thread',
      onLongPress: usable && !failed && !desktop ? open : null,
      onContextMenu: usable && !failed && desktop
          ? (position, selection) => unawaited(
              showMessageContextMenu(
                context,
                target,
                position,
                selection: selection,
              ),
            )
          : null,
      actions: usable && post.sendState == null
          ? {
              if (threads) _replyAction: reply,
              if (reacts)
                _reactAction: () =>
                    unawaited(pickReaction(context, widget.url, post)),
              _menuAction: open,
            }
          : const {},
    );
    if (failed || !usable) return tile;
    if (desktop) return MessageHover(target: target, child: tile);
    return SwipeToOpen(onOpen: open, child: tile);
  }

  MessageTarget _target(PostItem post) => MessageTarget(
    url: widget.url,
    teamId: _state.window?.teamId ?? '',
    post: post,
    onReply: widget.onOpenThread == null
        ? null
        : () => unawaited(_openThread(post, reply: true)),
    onEdit: switch (widget.composer) {
      final composer? => () => ref.read(composer.notifier).startEditing(post),
      null => null,
    },
    onMarkedUnread: () => _controller.markedUnread(post),
    onQuote: switch (widget.composer) {
      final composer? =>
        (permalink) => ref
            .read(composer.notifier)
            .quote(post.message, permalink: permalink),
      null => null,
    },
  );

  Future<void> _toggleAcknowledged(PostItem post) async {
    final messenger = ScaffoldMessenger.of(context);
    final actions = await ref.read(postActionsProvider(widget.url).future);
    try {
      if (post.acknowledgedAt == null) {
        await actions.acknowledge(post.id);
      } else {
        await actions.unacknowledge(post.id);
      }
    } on ApiError catch (e) {
      // The button is gone then; the server has no acknowledgements.
      if (endpointUnavailable(e)) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't change the acknowledgement. "
            '${requestProblemText(e, Uri.parse(widget.url).host)}',
          ),
        ),
      );
    }
  }
}

/// Above the oldest message: a spinner while older ones load, a retry
/// after a failure, or where the conversation starts.
class _OlderEdge extends StatelessWidget {
  const _OlderEdge({
    required this.state,
    required this.host,
    required this.startText,
    required this.onRetry,
  });

  final ConversationState state;
  final String host;
  final String? startText;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final window = state.window;
    if (window == null) return const SizedBox.shrink();
    if (state.olderFailure case final cause? when !window.reachesStart) {
      return Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          children: [
            Text(
              "Couldn't load older messages. "
              '${requestProblemText(cause, host)}',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.tokens.muted),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }
    final text = startText;
    // Both are laid out, so the start takes exactly the spinner's room and
    // a reader at the top stays there when it replaces the spinner.
    return IndexedStack(
      index: window.reachesStart ? 1 : 0,
      alignment: AlignmentDirectional.bottomStart,
      children: [
        // The edge is built even far off screen; it only spins, asking for
        // a frame each time, while a page is on its way.
        TickerMode(
          enabled: state.loadingOlder && !window.reachesStart,
          child: const Padding(
            padding: EdgeInsets.all(Spacing.md),
            child: Center(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  semanticsLabel: 'Loading older messages',
                ),
              ),
            ),
          ),
        ),
        if (text == null)
          const SizedBox(height: Spacing.sm)
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.xl,
              Spacing.lg,
              Spacing.lg,
            ),
            child: Text(text, style: Theme.of(context).textTheme.titleMedium),
          ),
      ],
    );
  }
}
