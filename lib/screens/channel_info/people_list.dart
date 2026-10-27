import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/paged_search.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/channel_info/paged_search_controller.dart';
import 'package:matterleast/screens/search/quick_search.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/tokens.dart';

/// A searchable list of people from the server, a page at a time, with
/// names and presence from the database.
class PeopleList extends ConsumerStatefulWidget {
  const PeopleList({
    required this.url,
    required this.loadPage,
    required this.search,
    required this.onTap,
    required this.emptyTitle,
    required this.emptyBody,
    this.trailing,
    this.header,
    this.hidden = const {},
    super.key,
  });

  final String url;

  /// Ids of one page, and whether more may follow.
  final Future<ServerPage<String>> Function(int page) loadPage;
  final Future<List<String>> Function(String term) search;
  final ValueChanged<SwitchItem> onTap;
  final String emptyTitle;
  final String emptyBody;
  final Widget Function(SwitchItem)? trailing;

  /// Shown above the search field, such as the people picked so far.
  final Widget? header;

  /// People left out of the rows, such as ones just removed.
  final Set<String> hidden;

  @override
  ConsumerState<PeopleList> createState() => _PeopleListState();
}

class _PeopleListState extends ConsumerState<PeopleList> {
  late final _list = PagedSearchController<String>(
    loadPage: widget.loadPage,
    search: widget.search,
    keyOf: (id) => id,
  )..addListener(_listed);
  void Function()? _unshow;
  var _rows = const <SwitchItem>[];
  var _shownIds = const <String>[];

  @override
  void initState() {
    super.initState();
    unawaited(_list.more());
  }

  @override
  void dispose() {
    _list.dispose();
    _unshow?.call();
    super.dispose();
  }

  void _listed() {
    final ids = _list.value.found ?? _list.value.items;
    if (!identical(ids, _shownIds)) {
      _shownIds = ids;
      unawaited(_showPresence());
    }
    setState(() {});
  }

  /// Keeps the presence of the people shown fresh while the list is open.
  Future<void> _showPresence() async {
    final session = await ref.read(serverSessionProvider(widget.url).future);
    if (!mounted) return;
    final v = _list.value;
    final next = session.connection.presence.show({...v.items, ...?v.found});
    _unshow?.call();
    _unshow = next;
  }

  @override
  Widget build(BuildContext context) {
    final list = _list.value;
    final shownIds = [
      for (final id in list.found ?? list.items)
        if (!widget.hidden.contains(id)) id,
    ];
    final term = list.term;
    // A new page is a new query; the rows shown stay until it answers.
    final rows = _rows =
        ref.watch(peopleRowsProvider(widget.url, shownIds.join(','))).value ??
        _rows;
    // Typing narrows what is loaded at once; the server's answer follows.
    final local = term.isEmpty || list.found != null
        ? rows
        : rankSwitchItems(term, rows, limit: 200);
    final busy = list.busy;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Column(
      children: [
        ?widget.header,
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.sm,
            Spacing.md,
            Spacing.sm,
          ),
          child: SearchBar(
            hintText: 'Search people',
            leading: const Icon(Icons.search),
            elevation: const WidgetStatePropertyAll(0),
            onChanged: _list.typed,
          ),
        ),
        SizedBox(
          height: 3,
          child: busy && local.isNotEmpty
              ? const LinearProgressIndicator(minHeight: 3)
              : null,
        ),
        Expanded(
          child: local.isEmpty
              ? busy
                    ? const Center(child: CircularProgressIndicator())
                    : list.error != null
                    ? EmptyState(
                        icon: Icons.cloud_off,
                        title: "Couldn't load people",
                        body: requestProblemText(
                          list.error!,
                          Uri.parse(widget.url).host,
                        ),
                        action: FilledButton.tonal(
                          onPressed: _list.retry,
                          child: const Text('Retry'),
                        ),
                      )
                    : EmptyState(
                        icon: Icons.person_search_outlined,
                        title: term.isEmpty
                            ? widget.emptyTitle
                            : 'Nobody matches "$term"',
                        body: term.isEmpty
                            ? widget.emptyBody
                            : 'Check the spelling or try part of a name.',
                      )
              : NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.extentAfter < 600) unawaited(_list.more());
                    return false;
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: bottom + Spacing.lg),
                    itemCount: local.length,
                    itemBuilder: (context, i) => SwitchTile(
                      item: local[i],
                      onTap: () => widget.onTap(local[i]),
                      trailing: widget.trailing?.call(local[i]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
