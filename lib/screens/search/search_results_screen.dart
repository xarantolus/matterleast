import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/message_search.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/screens/home/open_item.dart';
import 'package:matterleast/screens/open_page.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/search/file_list.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/screens/search/switch_picker.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/fill_scrollable.dart';
import 'package:matterleast/ui/message_preview_tile.dart';
import 'package:matterleast/ui/pane_label.dart';
import 'package:matterleast/ui/picker_modes.dart';
import 'package:matterleast/ui/refresh_area.dart';
import 'package:matterleast/ui/tokens.dart';

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
  SearchTab? _picked;

  /// Searching is an act: submitting, picking a tab or a filter, or opening
  /// Files. Before it the start page shows; after it the server answers for
  /// whatever the query is, empty included.
  late bool _searched = widget.query.isNotEmpty || widget.files;

  SearchTab get _tab =>
      _picked ??
      (widget.files
          ? SearchTab.files
          : ref.watch(searchTabProvider).value ?? SearchTab.messages);

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
    setState(() {
      _query = text.trim();
      _searched = true;
    });
    _remember(_query);
  }

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
        if (_tab == SearchTab.messages) {
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
        _searched &&
        (requests == null ||
            requests.any(
              (r) =>
                  (_tab == SearchTab.messages
                          ? ref.watch(
                              serverPostResultsProvider(r.url, r.scope, _query),
                            )
                          : ref.watch(
                              serverFileResultsProvider(r.url, r.scope, _query),
                            ))
                      .isLoading,
            ));
    final foreground = Theme.of(context).appBarTheme.foregroundColor;
    // A channel's files are only searched and narrowed by type.
    final scopedFiles = widget.files && widget.scope?.channelId != null;
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
            (SearchTab.files, final where?) => 'Search files in $where',
            (SearchTab.files, null) => 'Search files',
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
            if (!scopedFiles) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.md,
                  Spacing.md,
                  0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<SearchTab>(
                    segments: const [
                      ButtonSegment(
                        value: SearchTab.messages,
                        label: Text('Messages'),
                        icon: Icon(Icons.chat_bubble_outline),
                      ),
                      ButtonSegment(
                        value: SearchTab.files,
                        label: Text('Files'),
                        icon: Icon(Icons.description_outlined),
                      ),
                    ],
                    selected: {_tab},
                    onSelectionChanged: (s) {
                      setState(() {
                        _picked = s.first;
                        _searched = true;
                      });
                      unawaited(
                        ref
                            .read(settingsStoreProvider)
                            .write(Settings.searchTab, s.first),
                      );
                    },
                  ),
                ),
              ),
              _ScopeChips(
                server: _server,
                servers: servers,
                pickServer: widget.url == null && servers.length > 1,
                scope: _scope,
                onChanged: (scope) => setState(() {
                  _scope = scope;
                  _searched = true;
                }),
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
            ],
            if (_tab == SearchTab.files)
              FileFilterChips(
                selected: _scope.fileFilter,
                onSelected: (kind) => setState(() {
                  _scope = _scope.copyWith(fileFilter: kind);
                  _searched = true;
                }),
              ),
            Expanded(
              child: !_searched
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
                      child: _tab == SearchTab.messages
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
                              filtered: _scope.fileFilter != null,
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
      initialEntryMode: dateEntryMode,
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

class _FileResults extends ConsumerWidget {
  const _FileResults({
    required this.requests,
    required this.names,
    required this.query,
    required this.filtered,
    required this.onRetry,
  });

  final List<SearchRequest> requests;
  final Map<String, String> names;
  final String query;

  /// A file type is picked, so an empty answer is not "no files yet".
  final bool filtered;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = <({String name, SearchView<FoundFile> view})>[
      for (final r in requests)
        _source<FoundFile>(
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
                (files) => [
                  for (final f in [
                    ...files,
                    ...ref.watch(moreFilesProvider(r.url, r.scope, query)).hits,
                  ])
                    (url: r.url, file: f),
                ],
              ),
          (f) => f.file.id,
        ),
    ];
    return switch (mergeSearch(sources)) {
      SearchLoading() => const FillScrollable(
        child: Center(child: CircularProgressIndicator()),
      ),
      SearchEmpty() when query.isEmpty && !filtered => const FillScrollable(
        child: EmptyState(
          icon: Icons.description_outlined,
          title: 'No files yet',
          body:
              'Pictures, videos and documents attached to messages show up '
              'here.',
        ),
      ),
      SearchEmpty() => _NoResults(query: query),
      SearchFailed(:final cause) => _Failed(cause: cause, onRetry: onRetry),
      SearchShown(:final results, :final more, :final failures) => _FileList(
        requests: requests,
        query: query,
        results: results,
        more: more,
        names: names,
        failures: failures,
        onRetry: onRetry,
      ),
    };
  }
}

class _FileList extends ConsumerStatefulWidget {
  const _FileList({
    required this.requests,
    required this.query,
    required this.results,
    required this.more,
    required this.names,
    required this.failures,
    required this.onRetry,
  });

  final List<SearchRequest> requests;
  final String query;
  final List<FoundFile> results;
  final List<FoundFile> more;
  final Map<String, String> names;
  final List<({String name, String cause})> failures;
  final VoidCallback onRetry;

  @override
  ConsumerState<_FileList> createState() => _FileListState();
}

class _FileListState extends ConsumerState<_FileList> {
  late List<List<String>> _arrivals = arrivalGroups(const [], _ready);

  Iterable<String> get _ready => {for (final f in widget.results) f.url};

  @override
  void didUpdateWidget(_FileList old) {
    super.didUpdateWidget(old);
    _arrivals = arrivalGroups(_arrivals, _ready);
  }

  @override
  Widget build(BuildContext context) {
    final names = widget.names;
    final failures = widget.failures;
    final now = ref.watch(todayProvider);
    DateTime? time(FoundFile f) => f.file.createAt;
    // Each server's hits are already newest first.
    List<List<FoundFile>> byServer(
      List<FoundFile> all,
      Iterable<String> urls,
    ) => [
      for (final url in urls)
        [
          for (final f in all)
            if (f.url == url) f,
        ],
    ];
    // Later arrivals are sections below, so nothing shown moves.
    final sections = <({String? label, List<FoundFile> items})>[];
    for (final (i, urls) in _arrivals.indexed) {
      final items = mergeNewestFirst(byServer(widget.results, urls), time);
      if (items.isEmpty) continue;
      sections.add((
        label: i > 0
            ? 'More from ${urls.map((u) => names[u] ?? u).join(', ')}'
            : null,
        items: items,
      ));
    }
    if (widget.more.isNotEmpty) {
      sections.add((
        label: 'More from the server',
        items: mergeNewestFirst(
          byServer(widget.more, [for (final r in widget.requests) r.url]),
          time,
        ),
      ));
    }
    final groups = [
      for (final section in sections)
        (
          label: section.label,
          groups: groupFiles<FoundFile>(
            section.items,
            timeOf: time,
            isMedia: (f) => f.file.postFile.isMedia,
            now: now,
          ),
        ),
    ];
    final media = [
      for (final section in groups)
        for (final group in section.groups) ...group.media,
    ];
    final count = widget.results.length + widget.more.length;
    final paging = [
      for (final r in widget.requests)
        ref.watch(moreFilesProvider(r.url, r.scope, widget.query)),
    ];
    final loadingMore = paging.any((p) => p.loading);
    final moreFailure = paging.map((p) => p.failure).nonNulls.firstOrNull;
    return LayoutBuilder(
      builder: (context, box) => NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.extentAfter < box.maxHeight) _loadMore();
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: PaneLabel('$count ${count == 1 ? 'file' : 'files'}'),
            ),
            if (failures.isNotEmpty)
              SliverToBoxAdapter(
                child: _Failures(failures: failures, onRetry: widget.onRetry),
              ),
            for (final section in groups) ...[
              if (section.label case final label?)
                SliverToBoxAdapter(child: PaneLabel(label)),
              for (final group in section.groups)
                FileGroupSliver(
                  group: group,
                  columns: mediaColumns(box.maxWidth - 2 * Spacing.md),
                  media: media,
                  names: names,
                ),
            ],
            if (loadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.lg),
                  child: LinearProgressIndicator(minHeight: 4),
                ),
              ),
            if (moreFailure != null)
              SliverToBoxAdapter(
                child: ListTile(
                  title: Text("Couldn't load more files. $moreFailure"),
                  trailing: TextButton(
                    onPressed: () => _loadMore(retry: true),
                    child: const Text('Retry'),
                  ),
                ),
              ),
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + Spacing.lg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Asks each server for its next page, unless one failed and the reader
  /// hasn't asked again.
  void _loadMore({bool retry = false}) {
    for (final r in widget.requests) {
      final provider = moreFilesProvider(r.url, r.scope, widget.query);
      if (!retry && ref.read(provider).failure != null) continue;
      unawaited(ref.read(provider.notifier).loadNext());
    }
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
