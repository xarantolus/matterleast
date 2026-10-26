import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/conversation_actions.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/views/conversation_views.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/post_ranges.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/screens/channel/conversation_state.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/ui/anchored_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversation_controller.g.dart';

/// An open channel, or the thread of [rootId] in it: watches the stored
/// window, refreshes it once on open, loads older history as the reader
/// scrolls, and marks the conversation read.
@riverpod
class Conversation extends _$Conversation {
  static const _step = ConversationActions.pageSize;

  ServerSession? _session;
  ConversationActions? _actions;
  StreamSubscription<ConversationWindow>? _subscription;
  StreamSubscription<void>? _caughtUp;
  var _limit = _step;
  DateTime? _rangeAt;
  DateTime? _lastViewedAt;
  String? _me;
  var _loadingNewer = false;
  final _openedAt = DateTime.now().toUtc();

  /// Only messages created before this start the new-messages line: what
  /// arrives while the reader watches is not unread. Lifted by Mark unread.
  late DateTime? _unreadUntil = _openedAt;

  /// A bigger window is on its way; the reader's next moves don't ask again.
  var _growing = false;

  /// Messages in the first answer of a new watch, or stored by a fetch,
  /// are history, not live arrivals.
  var _historyOnly = true;

  /// The next window is of another stretch of history: the list opens anew.
  var _moved = false;
  DateTime _quietUntil = DateTime(0);

  bool get _isThread => rootId != null;
  String get _scope => _isThread ? 'thread' : 'channel';
  String get _scopeId => rootId ?? channelId;

  @override
  ConversationState build(
    String url,
    String channelId, {
    String? rootId,
    String? highlightPostId,
  }) {
    ref.onDispose(() {
      unawaited(_subscription?.cancel());
      unawaited(_caughtUp?.cancel());
      _session?.runner.cancelOwner(this);
    });
    unawaited(_start());
    return ConversationState(highlightKey: highlightPostId);
  }

  Future<void> _start() async {
    final session = await ref.read(serverSessionProvider(url).future);
    if (!ref.mounted) return;
    _session = session;
    _actions = ConversationActions(session);
    final facts = await ConversationViews(session.db)
        .openFacts(channelId, rootId: rootId);
    _me = facts.me;
    _lastViewedAt = facts.lastViewedAt;
    if (!_isThread) {
      // Stay in the stretch of history stored now, even if the refresh
      // finds a gap and stores the newest messages apart.
      _rangeAt = newestRange(
        await session.store.rangesFor('channel', channelId),
      )?.latest;
    }
    if (!ref.mounted) return;
    state = state.copyWith(saved: facts.saved);
    _watch();
    _caughtUp = session.connection.caughtUp.listen(
      (_) => unawaited(_catchUp()),
    );
    await _markRead();
    unawaited(_refresh());
    if (!_isThread) {
      unawaited(
        _actions!.channelStats(channelId, owner: this).catchError((_) {}),
      );
    }
  }

  void _watch() {
    if (!ref.mounted) return;
    final views = ConversationViews(_session!.db, server: _session!.url);
    unawaited(_subscription?.cancel());
    _subscription =
        (_isThread
                ? views.thread(rootId!, limit: _limit, openedAt: _openedAt)
                : views.channel(
                    channelId,
                    limit: _limit,
                    openedAt: _openedAt,
                    rangeAt: _rangeAt,
                    unreadAfter: _lastViewedAt,
                  ))
            .listen(_onWindow);
    _historyOnly = true;
  }

  /// A fetch is done; what it stored shows up within one watch interval.
  void _fetched() =>
      _quietUntil = DateTime.now().add(const Duration(milliseconds: 300));

  void _onWindow(ConversationWindow window) {
    if (!ref.mounted) return;
    _growing = false;
    final before = state.window;
    final arrived = {...state.arrived};
    var fromOthers = false;
    final live =
        !_historyOnly &&
        !state.refreshing &&
        !state.loadingOlder &&
        DateTime.now().isAfter(_quietUntil);
    _historyOnly = false;
    if (live && before != null && before.posts.isNotEmpty) {
      final known = {for (final p in before.posts) p.key};
      final newest = before.posts.first.createAt;
      final now = DateTime.now();
      for (final post in window.posts) {
        if (!post.createAt.isAfter(newest)) break;
        if (known.contains(post.key)) continue;
        arrived[post.key] = now;
        if (post.userId != _me) fromOthers = true;
      }
    }
    final moved = _moved;
    _moved = false;
    state = state.copyWith(
      window: window,
      arrived: arrived,
      generation: moved ? state.generation + 1 : state.generation,
      rows: _rows(window),
    );
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (fromOthers && lifecycle == AppLifecycleState.resumed) {
      unawaited(_markRead());
    }
  }

  List<ListRow> _rows(ConversationWindow window) => reuseRows(
    state.rows,
    buildRows(
      [...window.posts, ?window.root],
      lastViewedAt: _lastViewedAt,
      myUserId: _me,
      unreadUntil: _unreadUntil,
    ),
  );

  /// The user marked [post] unread: the new-messages line moves above it.
  void markedUnread(PostItem post) {
    _lastViewedAt = post.createAt.subtract(const Duration(milliseconds: 1));
    _unreadUntil = null;
    final window = state.window;
    if (window == null) return;
    state = state.copyWith(rows: _rows(window));
  }

  Future<void> _markRead() async {
    if (!_isThread) {
      final actions = await ref.read(channelActionsProvider(url).future);
      await actions.view(channelId);
      return;
    }
    final team = await _threadTeam();
    if (team == null) return;
    await _actions!.markThreadRead(team, rootId!).catchError((Object _) {});
  }

  /// The team a thread's read marks and following are kept in; null
  /// without collapsed threads.
  Future<String?> _threadTeam() =>
      ConversationViews(_session!.db)
          .threadTeam(channelId, channelTeamId: state.window?.teamId);

  /// Follows or stops following the open thread; shows at once and
  /// is undone when the server refuses, which throws [ApiError].
  Future<void> setFollowing({required bool following}) async {
    if (_actions == null || !_isThread) return;
    final team = await _threadTeam();
    if (team == null) return;
    final posts = await ref.read(postActionsProvider(url).future);
    await (following
        ? posts.followThread(team, rootId!, channelId: channelId)
        : posts.unfollowThread(team, rootId!));
  }

  Future<void> _refresh() async {
    if (!ref.mounted) return;
    state = state.copyWith(refreshing: true, refreshFailure: null);
    try {
      if (_isThread) {
        await _actions!.refreshThread(rootId!, owner: this);
        await _showReplyAsked();
      } else {
        await _actions!.refreshChannel(channelId, owner: this);
        await _openHighlight();
      }
      _fetched();
      if (ref.mounted) state = state.copyWith(refreshing: false);
    } on Object catch (e) {
      if (ref.mounted) {
        state = state.copyWith(
          refreshing: false,
          refreshFailure: ApiError.of(e),
        );
      }
    }
  }

  /// A message outside the stored newest messages: fetch the messages
  /// around it and move there.
  Future<void> _openHighlight() async {
    final key = state.highlightKey;
    if (key == null || state.rows.any((r) => r.key == key)) return;
    var at = await ConversationViews(_session!.db).postCreatedAt(key);
    final ranges = await _session!.store.rangesFor('channel', channelId);
    if (at == null || rangeContaining(ranges, at) == null) {
      at = await _actions!.aroundInChannel(channelId, key, owner: this);
    }
    if (at == null || !ref.mounted) return;
    _rangeAt = at;
    _limit = _step;
    _moved = true;
    _watch();
  }

  /// Moves to the reply asked for once the thread is fetched, widening the
  /// window when it is older than the replies shown.
  Future<void> _showReplyAsked() async {
    final key = state.highlightKey;
    if (key == null || state.rows.any((r) => r.key == key)) return;
    final newer = await ConversationViews(_session!.db)
        .repliesAfter(rootId!, key);
    if (newer == null || !ref.mounted) return;
    if (newer >= _limit) _limit = newer + _step;
    // Opens again at the reply, which arrived after the first rows did.
    _moved = true;
    _watch();
  }

  Future<void> retry() => _refresh();

  /// After a reconnect that may have missed events: fetch what came since
  /// the newest stored message, as on opening, and mark it read when seen.
  Future<void> _catchUp() async {
    if (!ref.mounted || state.refreshing) return;
    await _refresh();
    if (!ref.mounted || state.refreshFailure != null) return;
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      await _markRead();
    }
  }

  /// Follows the reader: more of the stored window, then older pages, near
  /// the top; newer pages near the bottom of an older stretch.
  void onView(AnchoredListView view) {
    final window = state.window;
    if (window == null || _actions == null) return;
    if (view.nearOlderEnd) {
      if (window.moreStored) {
        if (!_growing && window.posts.length >= _limit) {
          _growing = true;
          _limit += _step;
          _watch();
        }
      } else if (!window.reachesStart &&
          !state.loadingOlder &&
          state.olderFailure == null) {
        unawaited(_loadOlder());
      }
    }
    final newestVisible = view.newestVisible;
    if (window.newerApart &&
        !_loadingNewer &&
        newestVisible != null &&
        newestVisible < 5 &&
        window.posts.isNotEmpty) {
      unawaited(_loadNewer(window.posts.first));
    }
  }

  Future<void> _loadOlder() async {
    final oldest = state.window?.posts.lastOrNull;
    state = state.copyWith(loadingOlder: true, olderFailure: null);
    try {
      if (oldest == null) {
        await (_isThread
            ? _actions!.refreshThread(rootId!, owner: this)
            : _actions!.refreshChannel(channelId, owner: this));
      } else if (_isThread) {
        await _actions!.olderInThread(
          rootId!,
          oldestId: oldest.id,
          oldestAt: oldest.createAt,
          owner: this,
        );
      } else {
        await _actions!.olderInChannel(
          channelId,
          oldestId: oldest.id,
          oldestAt: oldest.createAt,
          owner: this,
        );
      }
      if (!ref.mounted) return;
      _fetched();
      _limit += _step;
      _watch();
      state = state.copyWith(loadingOlder: false);
    } on Object catch (e) {
      Log.warn('conversation', 'older page failed: ${ApiError.of(e)}');
      if (ref.mounted) {
        state = state.copyWith(
          loadingOlder: false,
          olderFailure: ApiError.of(e),
        );
      }
    }
  }

  void retryOlder() {
    if (!state.loadingOlder) unawaited(_loadOlder());
  }

  Future<void> _loadNewer(PostItem newest) async {
    _loadingNewer = true;
    try {
      await _actions!.newerInChannel(
        channelId,
        newestId: newest.id,
        newestAt: newest.createAt,
        owner: this,
      );
      _fetched();
    } on ApiError {
      // Tried again when the reader comes back to the bottom.
    } finally {
      _loadingNewer = false;
    }
  }

  /// Moves to the newest messages and forgets the saved place.
  void showLatest() {
    final session = _session;
    if (session == null) return;
    unawaited(session.store.clearViewState(_scope, _scopeId));
    final apart = state.window?.newerApart ?? false;
    state = state.copyWith(
      saved: null,
      highlightKey: null,
      intent: OpenIntent.bottom,
    );
    if (apart) {
      _rangeAt = null;
      _limit = _step;
      _moved = true;
      _watch();
    }
  }

  /// Remembers where the reader left off.
  void leave(AnchoredPosition? position) {
    if (!ref.mounted) return;
    final session = _session;
    final window = state.window;
    if (session == null || window == null || position == null) return;
    final post = [
      ...window.posts,
      ?window.root,
    ].where((p) => p.key == position.key).firstOrNull;
    if (post == null) return;
    unawaited(
      session.store.saveViewState(
        _scope,
        _scopeId,
        postId: post.id,
        offset: position.offset,
        at: DateTime.now().toUtc(),
      ),
    );
  }
}
