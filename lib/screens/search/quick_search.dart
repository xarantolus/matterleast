import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel/composer_keys.dart';
import 'package:matterleast/screens/channel_info/browse_channels_screen.dart';
import 'package:matterleast/screens/channel_info/people_picker_screen.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/screens/search/search_results_screen.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/custom_status_emoji.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/pane_label.dart';
import 'package:matterleast/ui/person_tile.dart';
import 'package:matterleast/ui/presence_dot.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/slide_route.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

/// Where searches for messages run and recent searches come from: one
/// server and team.
typedef SearchTarget = ({String url, String teamId});

/// Opens the quick switcher from elsewhere, such as Ctrl+K.
class QuickSearchOpener extends ChangeNotifier {
  void open() => notifyListeners();
}

/// The search icon of the app bar. It opens one full-screen view that finds
/// channels, conversations and people on every signed-in server, and
/// searches messages.
class QuickSearchAnchor extends ConsumerStatefulWidget {
  const QuickSearchAnchor({
    required this.opener,
    required this.servers,
    required this.target,
    super.key,
  });

  final QuickSearchOpener opener;

  /// Signed-in servers, in rail order.
  final List<ServerEntry> servers;
  final SearchTarget? target;

  @override
  ConsumerState<QuickSearchAnchor> createState() => _QuickSearchAnchorState();
}

class _QuickSearchAnchorState extends ConsumerState<QuickSearchAnchor> {
  final _text = TextEditingController();
  Route<void>? _view;

  SearchTarget? get target => widget.target;

  @override
  void initState() {
    super.initState();
    widget.opener.addListener(_openView);
  }

  @override
  void didUpdateWidget(QuickSearchAnchor old) {
    super.didUpdateWidget(old);
    if (old.opener != widget.opener) {
      old.opener.removeListener(_openView);
      widget.opener.addListener(_openView);
    }
  }

  @override
  void dispose() {
    widget.opener.removeListener(_openView);
    _text.dispose();
    super.dispose();
  }

  void _openView() {
    if (_view?.isActive ?? false) return;
    final view = _view = PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 150),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
      pageBuilder: (context, _, _) => QuickSearchView(
        controller: _text,
        servers: widget.servers,
        target: target,
        onOpen: (item) => _open(context, item),
        onSearch: (text) => _searchMessages(context, text),
        startActions: [
          if (target case final target?) ...[
            ListTile(
              leading: const SizedBox(
                width: 40,
                child: Icon(Icons.travel_explore),
              ),
              title: const Text('Browse channels'),
              onTap: () => _push(
                context,
                BrowseChannelsScreen(url: target.url, teamId: target.teamId),
              ),
            ),
            ListTile(
              leading: const SizedBox(
                width: 40,
                child: Icon(Icons.edit_outlined),
              ),
              title: const Text('New message'),
              onTap: () => _push(
                context,
                newMessageScreen(url: target.url, teamId: target.teamId),
              ),
            ),
          ],
        ],
      ),
    );
    unawaited(Navigator.of(context).push(view));
  }

  void _closeView(NavigatorState navigator, String text) {
    _text.text = text;
    final view = _view;
    if (view == null || !view.isActive) return;
    if (view.isCurrent) {
      navigator.pop();
    } else {
      navigator.removeRoute(view);
    }
  }

  void _push(BuildContext context, Widget screen) {
    final navigator = Navigator.of(context);
    _closeView(navigator, '');
    unawaited(navigator.push(SlideRoute<void>(builder: (_) => screen)));
  }

  void _searchMessages(BuildContext context, String text) {
    final target = this.target;
    if (target == null || text.trim().isEmpty) return;
    final navigator = Navigator.of(context);
    _closeView(navigator, text);
    unawaited(
      navigator.push(
        SlideRoute<void>(
          builder: (_) => SearchResultsScreen(
            url: target.url,
            teamId: target.teamId,
            query: text.trim(),
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, SwitchItem item) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (item.kind == SwitchKind.joinable &&
        !await confirmJoin(context, item.title)) {
      return;
    }
    try {
      final actions = await ref.read(
        channelActionsProvider(item.serverUrl).future,
      );
      final channelId = switch (item.kind) {
        SwitchKind.person => await actions.directChannel(item.id),
        SwitchKind.joinable => await actions.join(item.id).then((_) => item.id),
        _ => item.id,
      };
      _closeView(navigator, '');
      await openConversation(
        navigator,
        url: item.serverUrl,
        channelId: channelId,
        title: item.title,
        teamId: item.teamId,
      );
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't open ${item.title}. "
            '${requestProblemText(e, Uri.parse(item.serverUrl).host)}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Search',
    icon: const Icon(Icons.search),
    onPressed: _openView,
  );
}

typedef _Matches = ({
  List<SwitchItem> local,
  List<SwitchItem> extra,
  bool searching,
  String? failedHost,
  bool offline,
});

/// The full-screen search. Return opens the highlighted match, or
/// searches messages on that row or when nothing matches.
class QuickSearchView extends ConsumerStatefulWidget {
  const QuickSearchView({
    required this.controller,
    required this.servers,
    required this.target,
    required this.onOpen,
    required this.onSearch,
    this.startActions = const [],
    super.key,
  });

  final TextEditingController controller;
  final List<ServerEntry> servers;
  final SearchTarget? target;
  final ValueChanged<SwitchItem> onOpen;
  final ValueChanged<String> onSearch;

  /// Rows such as Browse channels at the end of the start view.
  final List<Widget> startActions;

  @override
  ConsumerState<QuickSearchView> createState() => _QuickSearchViewState();
}

class _QuickSearchViewState extends ConsumerState<QuickSearchView> {
  late String _term = widget.controller.text;
  late String _remoteTerm = _term;
  Timer? _debounce;
  int _highlight = 0;
  final _highlighted = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    _debounce?.cancel();
    super.dispose();
  }

  void _changed() {
    final term = widget.controller.text;
    if (term == _term) return;
    setState(() {
      _term = term;
      _highlight = 0;
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _remoteTerm = _term);
    });
  }

  // `ref.watch` while building, `ref.read` on a key press: both see the
  // same rows.
  _Matches _matches(String term, T Function<T>(ProviderListenable<T>) watch) {
    final items = [
      for (final s in widget.servers)
        ...?watch(switchItemsProvider(s.url)).value,
    ];
    final local = rankSwitchItems(term, items);
    final offline = watch(offlineProvider);
    // Waiting to send the term only counts when it can be sent.
    var searching = !offline && _remoteTerm.trim() != term;
    final remote = <SwitchItem>[];
    String? failedHost;
    for (final s in widget.servers) {
      final answer = watch(switchRemoteProvider(s.url, _remoteTerm));
      if (answer.isLoading) searching = true;
      if (answer.hasError && !answer.isLoading) {
        failedHost ??= Uri.parse(s.url).host;
      }
      remote.addAll(answer.value ?? const []);
    }
    return (
      local: local,
      extra: extraRemoteItems(term, local, remote),
      searching: searching,
      failedHost: failedHost,
      offline: offline,
    );
  }

  List<SwitchItem?> _choices(_Matches m) => [
    ...m.local,
    ...m.extra,
    if (widget.target != null) null,
  ];

  void _submit(String text) {
    final term = text.trim();
    if (term.isEmpty) return;
    final choices = _choices(_matches(term, ref.read));
    final picked = choices.isEmpty
        ? null
        : choices[_highlight.clamp(0, choices.length - 1)];
    if (picked != null) {
      widget.onOpen(picked);
    } else {
      widget.onSearch(term);
    }
  }

  void _move(int step) {
    final term = _term.trim();
    if (term.isEmpty) return;
    final count = _choices(_matches(term, ref.read)).length;
    setState(() => _highlight = movedHighlight(_highlight, step, count));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final row = _highlighted.currentContext;
      if (row != null && row.mounted) {
        unawaited(
          Scrollable.ensureVisible(row, alignmentPolicy: .keepVisibleAtEnd),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background =
        theme.searchViewTheme.backgroundColor ??
        theme.colorScheme.surfaceContainerHigh;
    // The view covers the app bar, whose light status-bar icons would be
    // unreadable on the view's surface.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      sized: false,
      value: background.computeLuminance() > 0.5
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: Material(
        color: background,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _header(context),
              const Divider(height: 1),
              Expanded(child: _content(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => SizedBox(
    height: 72,
    child: Row(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.sm),
          child: BackButton(),
        ),
        Expanded(
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                  _move(1),
              const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                  _move(-1),
            },
            child: TextField(
              controller: widget.controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: _submit,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Find channels, people or messages',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        if (_term.isNotEmpty)
          IconButton(
            tooltip: 'Clear text',
            icon: const Icon(Icons.close),
            onPressed: widget.controller.clear,
          ),
        const SizedBox(width: Spacing.sm),
      ],
    ),
  );

  Widget _content(BuildContext context) {
    final names = widget.servers.length > 1
        ? {for (final s in widget.servers) s.url: s.displayName}
        : const <String, String>{};
    final term = _term.trim();
    if (term.isEmpty) {
      return _StartView(
        items: [
          for (final s in widget.servers)
            ...?ref.watch(switchItemsProvider(s.url)).value,
        ],
        serverNames: names,
        target: widget.target,
        onOpen: widget.onOpen,
        onSearch: (text) {
          widget.controller.text = text;
          widget.onSearch(text);
        },
        actions: widget.startActions,
      );
    }
    final m = _matches(term, ref.watch);
    final shown = [...m.local, ...m.extra];
    final choices = _choices(m).length;
    final highlight = choices == 0 ? -1 : _highlight.clamp(0, choices - 1);
    final scheme = Theme.of(context).colorScheme;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Column(
      children: [
        ProgressSlot(active: m.searching),
        Expanded(
          child: ListTileTheme(
            data: ListTileThemeData(
              selectedColor: scheme.onSecondaryContainer,
              selectedTileColor: scheme.secondaryContainer,
            ),
            child: ListView(
              padding: EdgeInsets.only(bottom: bottom + Spacing.lg),
              children: [
                for (final (i, item) in shown.indexed)
                  SwitchTile(
                    key: i == highlight ? _highlighted : ValueKey(item.key),
                    item: item,
                    selected: i == highlight,
                    serverName: names[item.serverUrl],
                    onTap: () => widget.onOpen(item),
                  ),
                if (!m.searching && (m.failedHost != null || shown.isEmpty))
                  Padding(
                    padding: const EdgeInsets.all(Spacing.lg),
                    child: Text(switch ((m.failedHost, shown.isEmpty)) {
                      (_?, true) when m.offline =>
                        "You're offline, and nothing saved on this phone "
                            'matches “$term”.',
                      (_?, false) when m.offline =>
                        "You're offline · showing saved matches",
                      (final host?, true) =>
                        "Couldn't search $host, and nothing saved on this "
                            'phone matches “$term”.',
                      (final host?, false) =>
                        "Couldn't search $host · showing saved matches",
                      _ => 'No channels or people match “$term”.',
                    }, style: TextStyle(color: context.tokens.muted)),
                  ),
                if (widget.target != null)
                  ListTile(
                    key: highlight == shown.length ? _highlighted : null,
                    selected: highlight == shown.length,
                    leading: const SizedBox(
                      width: 40,
                      child: Icon(Icons.manage_search),
                    ),
                    title: Text('Search messages for “$term”'),
                    onTap: () => widget.onSearch(term),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StartView extends ConsumerWidget {
  const _StartView({
    required this.items,
    required this.serverNames,
    required this.target,
    required this.onOpen,
    required this.onSearch,
    required this.actions,
  });

  final List<SwitchItem> items;
  final Map<String, String> serverNames;
  final SearchTarget? target;
  final ValueChanged<SwitchItem> onOpen;
  final ValueChanged<String> onSearch;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = this.target;
    final recents = target == null
        ? const <String>[]
        : ref.watch(recentSearchesProvider(target.url, target.teamId)).value ??
              const <String>[];
    final start = switchStart(items);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ListView(
      padding: EdgeInsets.only(bottom: bottom + Spacing.lg),
      children: [
        if (recents.isNotEmpty) ...[
          const PaneLabel('Recent searches'),
          for (final term in recents.take(5))
            ListTile(
              leading: const SizedBox(width: 40, child: Icon(Icons.history)),
              title: Text(term, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () => onSearch(term),
              trailing: IconButton(
                tooltip: 'Remove from recent searches',
                icon: const Icon(Icons.close),
                onPressed: () async {
                  final search = await ref.read(
                    messageSearchProvider(target!.url).future,
                  );
                  await search.forget(target.teamId, term);
                },
              ),
            ),
        ],
        if (start.unread.isNotEmpty) ...[
          const PaneLabel('Unread'),
          for (final item in start.unread)
            SwitchTile(
              item: item,
              serverName: serverNames[item.serverUrl],
              onTap: () => onOpen(item),
            ),
        ],
        if (start.recent.isNotEmpty) ...[
          const PaneLabel('Recent'),
          for (final item in start.recent)
            SwitchTile(
              item: item,
              serverName: serverNames[item.serverUrl],
              onTap: () => onOpen(item),
            ),
        ],
        if (actions.isNotEmpty) ...[const Divider(), ...actions],
      ],
    );
  }
}

/// One channel, conversation or person in the search view.
class SwitchTile extends StatelessWidget {
  const SwitchTile({
    required this.item,
    required this.onTap,
    this.serverName,
    this.trailing,
    this.markKind = true,
    this.selected = false,
    super.key,
  });

  final SwitchItem item;
  final VoidCallback onTap;

  final bool selected;

  /// Says "Not joined" or "Archived" on such channels; pointless in a list
  /// of nothing else.
  final bool markKind;
  final String? serverName;

  /// Replaces the unread badge, such as a checkbox in a picker.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final details = [
      ?serverName,
      if (markKind && item.kind == SwitchKind.joinable) 'Not joined',
      if (markKind && item.kind == SwitchKind.archived) 'Archived',
      if (item.subtitle case final subtitle? when subtitle.isNotEmpty) subtitle,
    ];
    final strong = (item.unread && !item.muted) || item.mentions > 0;
    if (item.kind == SwitchKind.person && item.userId != null) {
      return PersonTile(
        serverUrl: item.serverUrl,
        userId: item.userId!,
        name: item.title,
        username: item.handle ?? '',
        pictureUpdate: item.pictureUpdate,
        status: item.status,
        trailing: trailing,
        selected: selected,
        onTap: onTap,
      );
    }
    return ListTile(
      selected: selected,
      onTap: onTap,
      leading: SizedBox.square(dimension: 40, child: _leading(context)),
      title: Row(
        children: [
          Flexible(
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: strong
                  ? const TextStyle(fontWeight: FontWeight.w700)
                  : null,
            ),
          ),
          if (item.kind == SwitchKind.direct && item.userId != null)
            CustomStatusEmoji(serverUrl: item.serverUrl, userId: item.userId!),
        ],
      ),
      subtitle: details.isEmpty
          ? null
          : Text(
              details.join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: tokens.muted),
            ),
      trailing:
          trailing ??
          (item.mentions > 0
              ? Badge.count(count: item.mentions)
              : strong
              ? Badge(smallSize: 10, backgroundColor: tokens.unread)
              : null),
    );
  }

  Widget _leading(BuildContext context) {
    final muted = context.tokens.muted;
    switch (item.kind) {
      case SwitchKind.direct || SwitchKind.person:
        final userId = item.userId;
        return Stack(
          children: [
            if (userId != null)
              UserAvatar(
                serverUrl: item.serverUrl,
                userId: userId,
                name: item.title,
                lastPictureUpdate: item.pictureUpdate,
              )
            else
              InitialsBadge(name: item.title, round: true),
            if (userId != null)
              PositionedDirectional(
                end: 0,
                bottom: 0,
                child: LivePresenceDot(
                  serverUrl: item.serverUrl,
                  userId: userId,
                  status: item.status,
                  size: 12,
                ),
              ),
          ],
        );
      case SwitchKind.group:
        return GroupAvatar(
          serverUrl: item.serverUrl,
          members: item.members,
          fallback: Icon(Icons.group_outlined, color: muted),
        );
      case SwitchKind.privateChannel:
        return Icon(Icons.lock_outline, color: muted);
      case SwitchKind.archived:
        return Icon(Icons.archive_outlined, color: muted);
      case SwitchKind.joinable:
        return Icon(Icons.add_circle_outline, color: muted);
      case SwitchKind.channel:
        return Icon(Icons.tag, color: muted);
    }
  }
}
