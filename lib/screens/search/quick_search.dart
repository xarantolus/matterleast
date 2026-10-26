import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel_info/browse_channels_screen.dart';
import 'package:matterleast/screens/channel_info/people_picker_screen.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/screens/search/search_results_screen.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/pane_label.dart';
import 'package:matterleast/ui/presence_dot.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

/// Where searches for messages run and recent searches come from: one
/// server and team.
typedef SearchTarget = ({String url, String teamId});

/// The search icon of the app bar. It opens one full-screen view that finds
/// channels, conversations and people on every signed-in server, and
/// searches messages.
class QuickSearchAnchor extends ConsumerWidget {
  const QuickSearchAnchor({
    required this.controller,
    required this.servers,
    required this.target,
    super.key,
  });

  final SearchController controller;

  /// Signed-in servers, in rail order.
  final List<ServerEntry> servers;
  final SearchTarget? target;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SearchAnchor(
    searchController: controller,
    isFullScreen: true,
    viewHintText: 'Find channels, people or messages',
    builder: (context, controller) => IconButton(
      tooltip: 'Search',
      icon: const Icon(Icons.search),
      onPressed: controller.openView,
    ),
    suggestionsBuilder: (_, _) => const <Widget>[],
    viewOnSubmitted: (text) => _searchMessages(context, text),
    viewBuilder: (_) => QuickSearchView(
      controller: controller,
      servers: servers,
      target: target,
      onOpen: (item) => _open(context, ref, item),
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

  void _push(BuildContext context, Widget screen) {
    final navigator = Navigator.of(context);
    controller.closeView('');
    unawaited(navigator.push(MaterialPageRoute<void>(builder: (_) => screen)));
  }

  void _searchMessages(BuildContext context, String text) {
    final target = this.target;
    if (target == null || text.trim().isEmpty) return;
    final navigator = Navigator.of(context);
    controller.closeView(text);
    unawaited(
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => SearchResultsScreen(
            url: target.url,
            teamId: target.teamId,
            query: text.trim(),
          ),
        ),
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    SwitchItem item,
  ) async {
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
      controller.closeView('');
      await openChannel(
        navigator,
        ref,
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
}

/// What the search view shows: where to go before anything is typed, and
/// matches as the user types, stored ones at once and the servers' below.
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

  final SearchController controller;
  final List<ServerEntry> servers;
  final SearchTarget? target;
  final ValueChanged<SwitchItem> onOpen;
  final ValueChanged<String> onSearch;

  /// Rows such as Browse channels and New message at the end of the start
  /// view.
  final List<Widget> startActions;

  @override
  ConsumerState<QuickSearchView> createState() => _QuickSearchViewState();
}

class _QuickSearchViewState extends ConsumerState<QuickSearchView> {
  late String _term = widget.controller.text;
  late String _remoteTerm = _term;
  Timer? _debounce;

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
    setState(() => _term = term);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _remoteTerm = _term);
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final s in widget.servers)
        ...?ref.watch(switchItemsProvider(s.url)).value,
    ];
    final names = widget.servers.length > 1
        ? {for (final s in widget.servers) s.url: s.displayName}
        : const <String, String>{};
    final term = _term.trim();
    if (term.isEmpty) {
      return _StartView(
        items: items,
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
    final local = rankSwitchItems(term, items);
    var searching = _remoteTerm.trim() != term;
    final remote = <SwitchItem>[];
    for (final s in widget.servers) {
      final answer = ref.watch(switchRemoteProvider(s.url, _remoteTerm));
      if (answer.isLoading) searching = true;
      remote.addAll(answer.value ?? const []);
    }
    final extra = extraRemoteItems(term, local, remote);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Column(
      children: [
        ProgressSlot(active: searching),
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(bottom: bottom + Spacing.lg),
            children: [
              for (final item in [...local, ...extra])
                SwitchTile(
                  item: item,
                  serverName: names[item.serverUrl],
                  onTap: () => widget.onOpen(item),
                ),
              if (local.isEmpty && extra.isEmpty && !searching)
                Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Text(
                    'No channels or people match "$term".',
                    style: TextStyle(color: context.tokens.muted),
                  ),
                ),
              if (widget.target != null)
                ListTile(
                  leading: const SizedBox(
                    width: 40,
                    child: Icon(Icons.manage_search),
                  ),
                  title: Text('Search messages for "$term"'),
                  onTap: () => widget.onSearch(term),
                ),
            ],
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
    super.key,
  });

  final SwitchItem item;
  final VoidCallback onTap;
  final String? serverName;

  /// Replaces the unread badge, such as a checkbox in a picker.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final details = [
      ?serverName,
      if (item.kind == SwitchKind.joinable) 'Not joined',
      if (item.kind == SwitchKind.archived) 'Archived',
      ?item.subtitle,
    ];
    final strong = (item.unread && !item.muted) || item.mentions > 0;
    return ListTile(
      onTap: onTap,
      leading: SizedBox.square(dimension: 40, child: _leading(context)),
      title: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: strong ? const TextStyle(fontWeight: FontWeight.w700) : null,
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
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: PresenceDot(status: item.status, size: 12),
            ),
          ],
        );
      case SwitchKind.group:
        return Icon(Icons.group_outlined, color: muted);
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
