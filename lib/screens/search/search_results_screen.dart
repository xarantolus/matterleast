import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/message_search.dart';
import 'package:matterleast/domain/post_files.dart'
    show fileKindOf, formatBytes;
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/screens/channel/link_opener.dart';
import 'package:matterleast/screens/home/open_item.dart';
import 'package:matterleast/screens/open_page.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/screens/search/switch_picker.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/file_icon.dart';
import 'package:matterleast/ui/fill_scrollable.dart';
import 'package:matterleast/ui/message_preview_tile.dart';
import 'package:matterleast/ui/pane_label.dart';
import 'package:matterleast/ui/post_files.dart';
import 'package:matterleast/ui/refresh_area.dart';
import 'package:matterleast/ui/tokens.dart';

enum _Tab { messages, files }

/// Opens message search over [url]'s teams, or every server's when null.
void openMessageSearch(
  BuildContext context, {
  String? url,
  String teamId = '',
}) => unawaited(
  openPage(
    Navigator.of(context),
    SearchResultsScreen(url: url, teamId: teamId, query: ''),
  ),
);

/// The app bar's search button.
class MessageSearchButton extends StatelessWidget {
  const MessageSearchButton({this.url, this.teamId = '', super.key});

  final String? url;
  final String teamId;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Search messages',
    icon: const Icon(Icons.search),
    onPressed: () => openMessageSearch(context, url: url, teamId: teamId),
  );
}

/// Messages and files found on one server, or on every signed-in one when
/// [url] is null, narrowed by server, team, channel, person and dates.
class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({
    required this.url,
    required this.teamId,
    required this.query,
    this.scope,
    this.files = false,
    super.key,
  });

  final String? url;
  final String teamId;
  final String query;

  /// Starts narrowed, such as to one channel's files.
  final SearchScope? scope;
  final bool files;

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  late final _text = TextEditingController(text: widget.query);
  late String _query = widget.query;
  late String? _server = widget.url;
  late SearchScope _scope =
      widget.scope ?? SearchScope(teamId: widget.teamId, allTeams: true);
  late _Tab _tab = widget.files ? _Tab.files : _Tab.messages;

  @override
  void initState() {
    super.initState();
    _remember(_query);
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  /// Files the term among a searched server's recent searches, under the
  /// team the scope names or else the one the user is in there.
  Future<void> _rememberOn(String url, String query) async {
    final team = _server != null && _scope.teamId.isNotEmpty
        ? _scope.teamId
        : await ref.read(currentTeamProvider(url).future);
    if (team == null) return;
    final search = await ref.read(messageSearchProvider(url).future);
    await search.remember(team, query);
  }

  void _remember(String query) {
    if (query.trim().isEmpty) return;
    unawaited(
      ref
          .read(serversProvider.future)
          .then(
            (servers) => Future.wait([
              for (final s in servers)
                if (s.signedIn && (_server == null || _server == s.url))
                  _rememberOn(s.url, query),
            ]),
          )
          .catchError((Object _) => const <void>[]),
    );
  }

  void _submit(String text) {
    setState(() => _query = text.trim());
    _remember(_query);
  }

  bool get _hasTerms => searchTerms(_query, _scope).isNotEmpty;

  /// Fetches the results again; a pull says when that failed, while Retry
  /// on a failed search shows the cause in place already.
  Future<void> _refresh({bool quiet = false}) async {
    final messenger = ScaffoldMessenger.of(context);
    final server = _server;
    try {
      final requests = await ref.read(
        searchPlanProvider(server, _scope).future,
      );
      final answers = <Future<Object?>>[];
      for (final r in requests) {
        if (_tab == _Tab.messages) {
          final answer = serverPostResultsProvider(r.url, r.scope, _query);
          ref
            ..invalidate(localPostResultsProvider(r.url, r.scope, _query))
            ..invalidate(answer);
          answers.add(ref.read(answer.future));
        } else {
          final answer = serverFileResultsProvider(r.url, r.scope, _query);
          ref
            ..invalidate(localFileResultsProvider(r.url, r.scope, _query))
            ..invalidate(answer);
          answers.add(ref.read(answer.future));
        }
      }
      await Future.wait(answers);
    } on Object catch (e) {
      // With several servers the failed ones are listed in the results.
      if (quiet || server == null) return;
      messenger.showSnackBar(
        SnackBar(content: Text(requestProblemText(e, hostOf(server)))),
      );
    }
  }

  void _retry() => unawaited(_refresh(quiet: true));

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(searchPlanProvider(_server, _scope)).value;
    final servers = [
      for (final s in ref.watch(serversProvider).value ?? const <ServerEntry>[])
        if (s.signedIn) s,
    ];
    final names = {
      if (servers.length > 1)
        for (final s in servers) s.url: s.displayName,
    };
    final refreshing =
        _hasTerms &&
        (requests == null ||
            requests.any(
              (r) =>
                  (_tab == _Tab.messages
                          ? ref.watch(
                              serverPostResultsProvider(r.url, r.scope, _query),
                            )
                          : ref.watch(
                              serverFileResultsProvider(r.url, r.scope, _query),
                            ))
                      .isLoading,
            ));
    final foreground = Theme.of(context).appBarTheme.foregroundColor;
    return ContentPage(
      title: TextField(
        controller: _text,
        autofocus: widget.query.isEmpty && !widget.files,
        textInputAction: TextInputAction.search,
        onSubmitted: _submit,
        style: TextStyle(color: foreground),
        cursorColor: foreground,
        decoration: InputDecoration(
          hintText: switch ((_tab, _scope.channelLabel)) {
            (_Tab.files, final where?) => 'Search files in $where',
            (_Tab.files, null) => 'Search files',
            (_, final where?) => 'Search in $where',
            _ => 'Search messages',
          },
          border: InputBorder.none,
          hintStyle: TextStyle(color: foreground?.withValues(alpha: 0.8)),
        ),
      ),
      progress: refreshing,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.md,
                Spacing.md,
                0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<_Tab>(
                  segments: const [
                    ButtonSegment(
                      value: _Tab.messages,
                      label: Text('Messages'),
                      icon: Icon(Icons.chat_bubble_outline),
                    ),
                    ButtonSegment(
                      value: _Tab.files,
                      label: Text('Files'),
                      icon: Icon(Icons.description_outlined),
                    ),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (s) => setState(() => _tab = s.first),
                ),
              ),
            ),
            _ScopeChips(
              server: _server,
              servers: servers,
              pickServer: widget.url == null && servers.length > 1,
              scope: _scope,
              onChanged: (scope) => setState(() => _scope = scope),
              onServer: (url) => setState(() {
                _server = url;
                _scope = _scope.copyWith(
                  teamId: '',
                  allTeams: true,
                  channelId: null,
                  channelName: null,
                  channelLabel: null,
                  userId: null,
                  username: null,
                  userLabel: null,
                );
              }),
            ),
            if (_tab == _Tab.files)
              _FileKindChips(
                selected: _scope.fileKind,
                onSelected: (kind) =>
                    setState(() => _scope = _scope.copyWith(fileKind: kind)),
              ),
            Expanded(
              child: !_hasTerms
                  ? _Start(
                      request: requests?.firstOrNull,
                      onPick: (term) {
                        _text.text = term;
                        _submit(term);
                      },
                    )
                  : requests == null
                  ? const FillScrollable(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : RefreshArea(
                      onRefresh: _refresh,
                      child: _tab == _Tab.messages
                          ? _MessageResults(
                              key: ValueKey(
                                Object.hash(
                                  _query,
                                  Object.hashAll([
                                    for (final r in requests) (r.url, r.scope),
                                  ]),
                                ),
                              ),
                              requests: requests,
                              names: names,
                              query: _query,
                              onRetry: _retry,
                            )
                          : _FileResults(
                              requests: requests,
                              names: names,
                              query: _query,
                              onRetry: _retry,
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Before a search: the recent ones, or what to do.
class _Start extends ConsumerWidget {
  const _Start({required this.request, required this.onPick});

  final SearchRequest? request;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = this.request;
    final recents = request == null || request.scope.teamId.isEmpty
        ? const <String>[]
        : ref
                  .watch(
                    recentSearchesProvider(request.url, request.scope.teamId),
                  )
                  .value ??
              const <String>[];
    if (request == null || recents.isEmpty) {
      return const EmptyState(
        icon: Icons.search,
        title: 'Search messages and files',
        body:
            'Type words to find, or pick a channel, a person or a date above.',
      );
    }
    return ListView(
      children: [
        const PaneLabel('Recent searches'),
        for (final term in recents.take(5))
          ListTile(
            leading: const SizedBox(width: 40, child: Icon(Icons.history)),
            title: Text(term, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () => onPick(term),
            trailing: IconButton(
              tooltip: 'Remove from recent searches',
              icon: const Icon(Icons.close),
              onPressed: () async {
                final search = await ref.read(
                  messageSearchProvider(request.url).future,
                );
                await search.forget(request.scope.teamId, term);
              },
            ),
          ),
      ],
    );
  }
}

/// Narrows file results to one kind of file.
class _FileKindChips extends StatelessWidget {
  const _FileKindChips({required this.selected, required this.onSelected});

  final FileKind? selected;
  final ValueChanged<FileKind?> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.sm),
    child: Row(
      spacing: Spacing.sm,
      children: [
        ChoiceChip(
          mouseCursor: clickCursor,
          label: const Text('All types'),
          selected: selected == null,
          onSelected: (_) => onSelected(null),
        ),
        for (final kind in FileKind.values)
          ChoiceChip(
            mouseCursor: clickCursor,
            label: Text(kind.label),
            selected: kind == selected,
            onSelected: (_) => onSelected(kind),
          ),
      ],
    ),
  );
}

class _ScopeChips extends ConsumerWidget {
  const _ScopeChips({
    required this.server,
    required this.servers,
    required this.pickServer,
    required this.scope,
    required this.onChanged,
    required this.onServer,
  });

  /// The one server searched; null for all of them.
  final String? server;
  final List<ServerEntry> servers;

  /// Started from Home, so the server can be picked.
  final bool pickServer;
  final SearchScope scope;
  final ValueChanged<SearchScope> onChanged;
  final ValueChanged<String?> onServer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = server;
    final teams = url == null
        ? const <RailTeam>[]
        : ref.watch(railTeamsProvider(url)).value ?? const [];
    final team = teams.where((t) => t.id == scope.teamId).firstOrNull;
    final items = url == null
        ? const <SwitchItem>[]
        : ref.watch(switchItemsProvider(url)).value ?? const [];
    final crossTeam =
        url != null &&
        (ref.watch(featuresProvider(url)).value?.crossTeamSearch ?? false);
    String day(DateTime d) => dateLabel(d, DateTime.now());

    Future<DateTime?> pickDay(DateTime? current) => showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );

    Widget chip({
      required String label,
      required bool set,
      required VoidCallback onPressed,
      required VoidCallback onClear,
      IconData? icon,
    }) => Padding(
      padding: const EdgeInsetsDirectional.only(end: Spacing.sm),
      child: InputChip(
        mouseCursor: clickCursor,
        avatar: icon == null ? null : Icon(icon, size: 18),
        label: Text(label),
        selected: set,
        showCheckmark: false,
        onPressed: onPressed,
        onDeleted: set ? onClear : null,
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      child: Row(
        children: [
          if (pickServer)
            chip(
              icon: Icons.dns_outlined,
              label:
                  servers
                      .where((s) => s.url == server)
                      .firstOrNull
                      ?.displayName ??
                  'All servers',
              set: false,
              onClear: () {},
              onPressed: () async {
                final picked = await pickSwitchItem(
                  context,
                  title: 'Search on',
                  hint: 'Find a server',
                  items: [
                    const SwitchItem(
                      serverUrl: '',
                      kind: SwitchKind.channel,
                      id: '',
                      title: 'All servers',
                    ),
                    for (final s in servers)
                      SwitchItem(
                        serverUrl: s.url,
                        kind: SwitchKind.channel,
                        id: s.url,
                        title: s.displayName,
                      ),
                  ],
                );
                if (picked != null) {
                  onServer(picked.id.isEmpty ? null : picked.id);
                }
              },
            ),
          if (url != null && teams.length > 1)
            chip(
              icon: Icons.groups_outlined,
              label: scope.allTeams && crossTeam
                  ? 'All teams'
                  : team?.displayName ?? 'Team',
              set: false,
              onClear: () {},
              onPressed: () async {
                final picked = await pickSwitchItem(
                  context,
                  title: 'Search in team',
                  hint: 'Find a team',
                  items: [
                    if (crossTeam)
                      SwitchItem(
                        serverUrl: url,
                        kind: SwitchKind.channel,
                        id: '',
                        title: 'All teams',
                      ),
                    for (final t in teams)
                      SwitchItem(
                        serverUrl: url,
                        kind: SwitchKind.channel,
                        id: t.id,
                        title: t.displayName,
                      ),
                  ],
                );
                if (picked == null) return;
                if (picked.id.isEmpty) {
                  onChanged(scope.copyWith(allTeams: true));
                } else {
                  // Channels belong to one team, so a new team starts over.
                  onChanged(SearchScope(teamId: picked.id));
                }
              },
            ),
          if (url != null)
            chip(
              icon: Icons.tag,
              label: scope.channelLabel == null
                  ? 'In channel'
                  : 'In ${scope.channelLabel}',
              set: scope.channelName != null,
              onClear: () => onChanged(
                scope.copyWith(
                  channelId: null,
                  channelName: null,
                  channelLabel: null,
                ),
              ),
              onPressed: () async {
                final picked = await pickSwitchItem(
                  context,
                  title: 'Search in',
                  hint: 'Find a channel or conversation',
                  items: [
                    for (final i in items)
                      if (i.joined &&
                          i.handle != null &&
                          (scope.allTeams ||
                              i.teamId == scope.teamId ||
                              i.kind == SwitchKind.direct ||
                              i.kind == SwitchKind.group))
                        i,
                  ],
                );
                if (picked == null) return;
                final conversation =
                    picked.kind == SwitchKind.direct ||
                    picked.kind == SwitchKind.group;
                onChanged(
                  scope.copyWith(
                    channelId: picked.id,
                    channelName: picked.handle,
                    channelLabel: conversation
                        ? picked.title
                        : '#${picked.title}',
                  ),
                );
              },
            ),
          if (url != null)
            chip(
              icon: Icons.person_outline,
              label: scope.userLabel == null
                  ? 'From person'
                  : 'From ${scope.userLabel}',
              set: scope.username != null,
              onClear: () => onChanged(
                scope.copyWith(userId: null, username: null, userLabel: null),
              ),
              onPressed: () async {
                final picked = await pickSwitchItem(
                  context,
                  title: 'Messages from',
                  hint: 'Find a person',
                  items: [
                    for (final i in items)
                      if ((i.kind == SwitchKind.person ||
                              i.kind == SwitchKind.direct) &&
                          i.userId != null)
                        i.copyWith(
                          id: i.userId!,
                          handle: i.subtitle?.replaceFirst('@', ''),
                        ),
                  ],
                );
                if (picked == null) return;
                onChanged(
                  scope.copyWith(
                    userId: picked.id,
                    username: picked.handle,
                    userLabel: picked.title,
                  ),
                );
              },
            ),
          chip(
            icon: Icons.event_outlined,
            label: scope.on == null ? 'On' : 'On ${day(scope.on!)}',
            set: scope.on != null,
            onClear: () => onChanged(scope.copyWith(on: null)),
            onPressed: () async {
              final picked = await pickDay(scope.on);
              if (picked != null) {
                onChanged(
                  scope.copyWith(on: picked, before: null, after: null),
                );
              }
            },
          ),
          chip(
            label: scope.after == null ? 'After' : 'After ${day(scope.after!)}',
            set: scope.after != null,
            onClear: () => onChanged(scope.copyWith(after: null)),
            onPressed: () async {
              final picked = await pickDay(scope.after);
              if (picked != null) {
                onChanged(scope.copyWith(after: picked, on: null));
              }
            },
          ),
          chip(
            label: scope.before == null
                ? 'Before'
                : 'Before ${day(scope.before!)}',
            set: scope.before != null,
            onClear: () => onChanged(scope.copyWith(before: null)),
            onPressed: () async {
              final picked = await pickDay(scope.before);
              if (picked != null) {
                onChanged(scope.copyWith(before: picked, on: null));
              }
            },
          ),
        ],
      ),
    );
  }
}

/// The servers that couldn't be searched, quietly, with Retry.
class _Failures extends StatelessWidget {
  const _Failures({required this.failures, required this.onRetry});

  final List<({String name, String cause})> failures;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
    child: Row(
      children: [
        Expanded(
          child: Text(
            [for (final f in failures) "Couldn't search ${f.name}. ${f.cause}"]
                .join('\n'),
            style: TextStyle(color: context.tokens.muted),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

/// One server's answer and what is stored of it, as one view.
({String name, SearchView<T> view}) _source<T>(
  SearchRequest r,
  Map<String, String> names,
  AsyncValue<List<T>> local,
  AsyncValue<List<T>> server,
  Object? Function(T)? keyOf,
) {
  final host = hostOf(r.url);
  return (
    name: names[r.url] ?? host,
    view: searchView(
      local: local.value,
      server: server.value,
      serverLoading: server.isLoading,
      serverError: server.hasError
          ? requestProblemText(server.error!, host)
          : null,
      keyOf: keyOf,
    ),
  );
}

class _MessageResults extends ConsumerWidget {
  const _MessageResults({
    super.key,
    required this.requests,
    required this.names,
    required this.query,
    required this.onRetry,
  });

  final List<SearchRequest> requests;
  final Map<String, String> names;
  final String query;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = [
      for (final r in requests)
        _source<String>(
          r,
          names,
          ref.watch(localPostResultsProvider(r.url, r.scope, query)),
          ref.watch(serverPostResultsProvider(r.url, r.scope, query)),
          null,
        ),
    ];
    return switch (mergeSearch(sources)) {
      SearchLoading() => const FillScrollable(
        child: Center(child: CircularProgressIndicator()),
      ),
      SearchEmpty() => _NoResults(query: query),
      SearchFailed(:final cause) => _Failed(cause: cause, onRetry: onRetry),
      SearchShown(:final failures) => _PostList(
        groups: [
          for (final (i, r) in requests.indexed)
            if (sources[i].view case SearchShown(:final results, :final more))
              (url: r.url, results: results, more: more),
        ],
        names: names,
        failures: failures,
        onRetry: onRetry,
      ),
    };
  }
}

class _PostList extends ConsumerStatefulWidget {
  const _PostList({
    required this.groups,
    required this.names,
    required this.failures,
    required this.onRetry,
  });

  /// Each server's results; its extra ones from the server go below.
  final List<({String url, List<String> results, List<String> more})> groups;
  final Map<String, String> names;
  final List<({String name, String cause})> failures;
  final VoidCallback onRetry;

  @override
  ConsumerState<_PostList> createState() => _PostListState();
}

class _PostListState extends ConsumerState<_PostList> {
  late List<List<String>> _arrivals = arrivalGroups(const [], _ready);

  Iterable<String> get _ready => [
    for (final g in widget.groups)
      if (g.results.isNotEmpty) g.url,
  ];

  @override
  void didUpdateWidget(_PostList old) {
    super.didUpdateWidget(old);
    _arrivals = arrivalGroups(_arrivals, _ready);
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.groups;
    final names = widget.names;
    final failures = widget.failures;
    final onRetry = widget.onRetry;
    List<InboxItem> itemsOf(String url, List<String> ids) => ids.isEmpty
        ? const []
        : ref.watch(searchPostItemsProvider(url, ids.join(','))).value ??
              const <InboxItem>[];
    DateTime time(InboxItem i) => i.time;
    final moreItems = mergeNewestFirst([
      for (final g in groups) itemsOf(g.url, g.more),
    ], time);
    final rows = <Object>[];
    for (final (i, urls) in _arrivals.indexed) {
      final items = mergeNewestFirst([
        for (final g in groups)
          if (urls.contains(g.url)) itemsOf(g.url, g.results),
      ], time);
      if (items.isEmpty) continue;
      if (i > 0) {
        rows.add(
          PaneLabel('More from ${urls.map((u) => names[u] ?? u).join(', ')}'),
        );
      }
      rows.addAll(withDays(items, time));
    }
    if (moreItems.isNotEmpty) {
      rows
        ..add(const PaneLabel('More from the server'))
        ..addAll(withDays(moreItems, time));
    }
    // The ids are known before their rows are read, so the count is right
    // at once instead of starting at 0.
    final count = groups.fold(
      0,
      (n, g) => n + g.results.length + g.more.length,
    );
    final bottom = MediaQuery.paddingOf(context).bottom;
    final top = failures.isEmpty ? 1 : 2;
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: bottom + Spacing.lg),
      itemCount: rows.length + top,
      itemBuilder: (context, i) {
        if (i == 0) {
          return PaneLabel('$count ${count == 1 ? 'result' : 'results'}');
        }
        if (i < top) return _Failures(failures: failures, onRetry: onRetry);
        return switch (rows[i - top]) {
          final DateTime day => _DayHeader(day: day),
          final PaneLabel label => label,
          final InboxItem item => MessagePreviewTile(
            item: item,
            serverName: names[item.serverUrl],
            onTap: () => openInboxItem(context, item),
          ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}

typedef _Found = ({String url, FileHit file});

class _FileResults extends ConsumerWidget {
  const _FileResults({
    required this.requests,
    required this.names,
    required this.query,
    required this.onRetry,
  });

  final List<SearchRequest> requests;
  final Map<String, String> names;
  final String query;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = <({String name, SearchView<_Found> view})>[
      for (final r in requests)
        _source<_Found>(
          r,
          names,
          ref
              .watch(localFileResultsProvider(r.url, r.scope, query))
              .whenData(
                (files) => [for (final f in files) (url: r.url, file: f)],
              ),
          ref
              .watch(serverFileResultsProvider(r.url, r.scope, query))
              .whenData(
                (files) => [for (final f in files) (url: r.url, file: f)],
              ),
          (f) => f.file.id,
        ),
    ];
    final bottom = MediaQuery.paddingOf(context).bottom;
    return switch (mergeSearch(sources)) {
      SearchLoading() => const FillScrollable(
        child: Center(child: CircularProgressIndicator()),
      ),
      SearchEmpty() => _NoResults(query: query),
      SearchFailed(:final cause) => _Failed(cause: cause, onRetry: onRetry),
      SearchShown(:final results, :final more, :final failures) => () {
        DateTime? time(_Found f) => f.file.createAt;
        // Each server's hits are already newest first.
        List<List<_Found>> byServer(List<_Found> all) => [
          for (final r in requests)
            [
              for (final f in all)
                if (f.url == r.url) f,
            ],
        ];
        final rows = [
          ...withDays(mergeNewestFirst(byServer(results), time), time),
          if (more.isNotEmpty) ...[
            const PaneLabel('More from the server'),
            ...withDays(mergeNewestFirst(byServer(more), time), time),
          ],
        ];
        final count = results.length + more.length;
        final top = failures.isEmpty ? 1 : 2;
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: bottom + Spacing.lg),
          itemCount: rows.length + top,
          itemBuilder: (context, i) {
            if (i == 0) {
              return PaneLabel('$count ${count == 1 ? 'file' : 'files'}');
            }
            if (i < top) {
              return _Failures(failures: failures, onRetry: onRetry);
            }
            return switch (rows[i - top]) {
              final DateTime day => _DayHeader(day: day),
              final PaneLabel label => label,
              final _Found found => _FileTile(
                url: found.url,
                file: found.file,
                serverName: names[found.url],
              ),
              _ => const SizedBox.shrink(),
            };
          },
        );
      }(),
    };
  }
}

class _DayHeader extends ConsumerWidget {
  const _DayHeader({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.fromLTRB(
      Spacing.lg,
      Spacing.md,
      Spacing.lg,
      Spacing.xs,
    ),
    child: Text(
      dayLabel(day, ref.watch(todayProvider)).toUpperCase(),
      style: context.tokens.smallCaps,
    ),
  );
}

class _FileTile extends ConsumerStatefulWidget {
  const _FileTile({required this.url, required this.file, this.serverName});

  final String url;
  final FileHit file;
  final String? serverName;

  @override
  ConsumerState<_FileTile> createState() => _FileTileState();
}

class _FileTileState extends ConsumerState<_FileTile> {
  bool _locating = false;

  Future<void> _openInChannel() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      await openPost(
        Navigator.of(context),
        widget.url,
        widget.file.postId,
        showsProgress: true,
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.file;
    return ListTile(
      onTap: () => openFile(
        context,
        ref,
        url: widget.url,
        file: file.postFile,
        author: file.place,
        sentAt: file.createAt ?? DateTime.now(),
      ),
      leading: SizedBox(
        width: 40,
        child: Icon(
          fileIcon(
            fileKindOf(extension: file.extension, mimeType: file.mimeType),
            file.extension,
          ),
          color: context.tokens.accent,
        ),
      ),
      title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          formatBytes(file.size),
          if (file.place.isNotEmpty) file.place,
          ?widget.serverName,
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: context.tokens.muted),
      ),
      trailing: _locating
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              tooltip: 'Jump to message',
              icon: const Icon(Icons.move_down),
              onPressed: _openInChannel,
            ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) => FillScrollable(
    child: EmptyState(
      icon: Icons.search_off,
      title: query.isEmpty ? 'No results' : 'No results for “$query”',
      body:
          'Check the spelling, use fewer words, or remove a filter. A * at '
          'the end of a word finds words starting with it.',
    ),
  );
}

class _Failed extends StatelessWidget {
  const _Failed({required this.cause, required this.onRetry});

  final String cause;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => FillScrollable(
    child: EmptyState(
      icon: Icons.cloud_off,
      title: "Couldn't search",
      body: cause,
      action: FilledButton.tonal(
        onPressed: onRetry,
        child: const Text('Retry'),
      ),
    ),
  );
}
