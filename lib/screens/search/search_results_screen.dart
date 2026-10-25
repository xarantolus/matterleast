import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/message_search.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/server_status.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/screens/search/switch_picker.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/fill_scrollable.dart';
import 'package:matterleast/ui/message_preview_tile.dart';
import 'package:matterleast/ui/pane_label.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/tokens.dart';

enum _Tab { messages, files }

/// Messages and files found on one server, narrowed by team, channel,
/// person and dates.
class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({
    required this.url,
    required this.teamId,
    required this.query,
    this.scope,
    this.files = false,
    super.key,
  });

  final String url;
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
  late SearchScope _scope = widget.scope ?? SearchScope(teamId: widget.teamId);
  late _Tab _tab = widget.files ? _Tab.files : _Tab.messages;

  String get _host => Uri.parse(widget.url).host;

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

  void _remember(String query) {
    if (query.trim().isEmpty) return;
    unawaited(
      ref
          .read(messageSearchProvider(widget.url).future)
          .then((search) => search.remember(_scope.teamId, query))
          .catchError((Object _) {}),
    );
  }

  void _submit(String text) {
    setState(() => _query = text.trim());
    _remember(_query);
  }

  bool get _hasTerms => searchTerms(_query, _scope).isNotEmpty;

  Future<void> _refresh() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (_tab == _Tab.messages) {
        final server = serverPostResultsProvider(widget.url, _scope, _query);
        ref
          ..invalidate(localPostResultsProvider(widget.url, _scope, _query))
          ..invalidate(server);
        await ref.read(server.future);
      } else {
        final server = serverFileResultsProvider(widget.url, _scope, _query);
        ref
          ..invalidate(localFileResultsProvider(widget.url, _scope, _query))
          ..invalidate(server);
        await ref.read(server.future);
      }
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(requestProblemText(e, _host))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final refreshing =
        _hasTerms &&
        (_tab == _Tab.messages
                ? ref.watch(
                    serverPostResultsProvider(widget.url, _scope, _query),
                  )
                : ref.watch(
                    serverFileResultsProvider(widget.url, _scope, _query),
                  ))
            .isLoading;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _text,
          textInputAction: TextInputAction.search,
          onSubmitted: _submit,
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          cursorColor: Theme.of(context).appBarTheme.foregroundColor,
          decoration: InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(context).appBarTheme.foregroundColor
                  ?.withValues(alpha: 0.7),
            ),
          ),
        ),
        bottom: ProgressSlot(active: refreshing),
      ),
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
              url: widget.url,
              scope: _scope,
              onChanged: (scope) => setState(() => _scope = scope),
            ),
            if (_tab == _Tab.files)
              _FileKindChips(
                selected: _scope.fileKind,
                onSelected: (kind) =>
                    setState(() => _scope = _scope.copyWith(fileKind: kind)),
              ),
            Expanded(
              child: !_hasTerms
                  ? const EmptyState(
                      icon: Icons.search,
                      title: 'Search messages and files',
                      body:
                          'Type words to find, or pick a channel, a person or '
                          'a date above.',
                    )
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: _tab == _Tab.messages
                          ? _MessageResults(
                              url: widget.url,
                              scope: _scope,
                              query: _query,
                              host: _host,
                              onRetry: _refresh,
                            )
                          : _FileResults(
                              url: widget.url,
                              scope: _scope,
                              query: _query,
                              host: _host,
                              onRetry: _refresh,
                            ),
                    ),
            ),
          ],
        ),
      ),
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
          label: const Text('All types'),
          selected: selected == null,
          onSelected: (_) => onSelected(null),
        ),
        for (final kind in FileKind.values)
          ChoiceChip(
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
    required this.url,
    required this.scope,
    required this.onChanged,
  });

  final String url;
  final SearchScope scope;
  final ValueChanged<SearchScope> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(railTeamsProvider(url)).value ?? const [];
    final team = teams.where((t) => t.id == scope.teamId).firstOrNull;
    final items = ref.watch(switchItemsProvider(url)).value ?? const [];
    final strings = MaterialLocalizations.of(context);
    String day(DateTime d) => strings.formatShortMonthDay(d);

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
          if (teams.length > 1)
            chip(
              icon: Icons.groups_outlined,
              label: scope.allTeams ? 'All teams' : team?.displayName ?? 'Team',
              set: false,
              onClear: () {},
              onPressed: () async {
                final picked = await pickSwitchItem(
                  context,
                  title: 'Search in team',
                  hint: 'Find a team',
                  items: [
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

class _MessageResults extends ConsumerWidget {
  const _MessageResults({
    required this.url,
    required this.scope,
    required this.query,
    required this.host,
    required this.onRetry,
  });

  final String url;
  final SearchScope scope;
  final String query;
  final String host;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = ref.watch(localPostResultsProvider(url, scope, query));
    final server = ref.watch(serverPostResultsProvider(url, scope, query));
    final view = searchView(
      local: local.value,
      server: server.value,
      serverLoading: server.isLoading,
      serverError: server.hasError
          ? requestProblemText(server.error!, host)
          : null,
    );
    return switch (view) {
      SearchLoading() => const FillScrollable(
        child: Center(child: CircularProgressIndicator()),
      ),
      SearchEmpty() => _NoResults(query: query),
      SearchFailed(:final cause) => _Failed(cause: cause, onRetry: onRetry),
      SearchShown(:final results, :final notice) => _PostList(
        url: url,
        ids: results,
        notice: notice,
      ),
    };
  }
}

class _PostList extends ConsumerWidget {
  const _PostList({required this.url, required this.ids, this.notice});

  final String url;
  final List<String> ids;
  final String? notice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items =
        ref.watch(searchPostItemsProvider(url, ids.join(','))).value ??
        const <InboxItem>[];
    final rows = withDays(items, (i) => i.time);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: bottom + Spacing.lg),
      itemCount: rows.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return PaneLabel(
            [
              '${items.length} ${items.length == 1 ? 'result' : 'results'}',
              ?notice,
            ].join(' · '),
          );
        }
        return switch (rows[i - 1]) {
          final DateTime day => _DayHeader(day: day),
          final InboxItem item => MessagePreviewTile(
            item: item,
            onTap: () => openChannel(
              Navigator.of(context),
              ref,
              url: url,
              channelId: item.channelId,
              title: item.title.split(' · ').first.replaceFirst('#', ''),
              teamId: item.teamId,
              highlightPostId: item.postId,
              rootId: item.rootId,
            ),
          ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}

class _FileResults extends ConsumerWidget {
  const _FileResults({
    required this.url,
    required this.scope,
    required this.query,
    required this.host,
    required this.onRetry,
  });

  final String url;
  final SearchScope scope;
  final String query;
  final String host;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = ref.watch(localFileResultsProvider(url, scope, query));
    final server = ref.watch(serverFileResultsProvider(url, scope, query));
    final view = searchView(
      local: local.value,
      server: server.value,
      serverLoading: server.isLoading,
      serverError: server.hasError
          ? requestProblemText(server.error!, host)
          : null,
    );
    final bottom = MediaQuery.paddingOf(context).bottom;
    return switch (view) {
      SearchLoading() => const FillScrollable(
        child: Center(child: CircularProgressIndicator()),
      ),
      SearchEmpty() => _NoResults(query: query),
      SearchFailed(:final cause) => _Failed(cause: cause, onRetry: onRetry),
      SearchShown(:final results, :final notice) => () {
        final rows = withDays(results, (f) => f.createAt);
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: bottom + Spacing.lg),
          itemCount: rows.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return PaneLabel(
                [
                  '${results.length} '
                      '${results.length == 1 ? 'file' : 'files'}',
                  ?notice,
                ].join(' · '),
              );
            }
            return switch (rows[i - 1]) {
              final DateTime day => _DayHeader(day: day),
              final FileHit file => _FileTile(
                file: file,
                onTap: () => openChannel(
                  Navigator.of(context),
                  ref,
                  url: url,
                  channelId: file.channelId,
                  title: file.place.replaceFirst('#', ''),
                  teamId: scope.teamId,
                  highlightPostId: file.postId,
                ),
              ),
              _ => const SizedBox.shrink(),
            };
          },
        );
      }(),
    };
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      Spacing.lg,
      Spacing.md,
      Spacing.lg,
      Spacing.xs,
    ),
    child: Text(
      MaterialLocalizations.of(context).formatMediumDate(day).toUpperCase(),
      style: context.tokens.smallCaps,
    ),
  );
}

class _FileTile extends StatelessWidget {
  const _FileTile({required this.file, required this.onTap});

  final FileHit file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: SizedBox(
      width: 40,
      child: Icon(fileIcon(file.mimeType, file.extension)),
    ),
    title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: Text(
      [fileSize(file.size), if (file.place.isNotEmpty) file.place].join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: context.tokens.muted),
    ),
  );
}

/// An icon for a file by its type.
IconData fileIcon(String mimeType, String extension) {
  final ext = extension.toLowerCase();
  if (mimeType.startsWith('image/')) return Icons.image_outlined;
  if (mimeType.startsWith('video/')) return Icons.movie_outlined;
  if (mimeType.startsWith('audio/')) return Icons.audio_file_outlined;
  if (ext == 'pdf') return Icons.picture_as_pdf_outlined;
  if (const {'zip', 'gz', 'tar', '7z', 'rar'}.contains(ext)) {
    return Icons.folder_zip_outlined;
  }
  if (const {'xls', 'xlsx', 'csv', 'ods'}.contains(ext)) {
    return Icons.table_chart_outlined;
  }
  return Icons.description_outlined;
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) => FillScrollable(
    child: EmptyState(
      icon: Icons.search_off,
      title: query.isEmpty ? 'No results' : 'No results for "$query"',
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
