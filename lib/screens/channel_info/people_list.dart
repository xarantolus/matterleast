import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
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
    super.key,
  });

  final String url;

  /// Ids of one page; fewer than a full page means there is no more.
  final Future<List<String>> Function(int page) loadPage;
  final Future<List<String>> Function(String term) search;
  final ValueChanged<SwitchItem> onTap;
  final String emptyTitle;
  final String emptyBody;
  final Widget Function(SwitchItem)? trailing;

  /// Shown above the search field, such as the people picked so far.
  final Widget? header;

  @override
  ConsumerState<PeopleList> createState() => _PeopleListState();
}

class _PeopleListState extends ConsumerState<PeopleList> {
  final _ids = <String>[];
  var _page = 0;
  var _done = false;
  var _loading = false;
  Object? _error;

  var _term = '';
  List<String>? _found;
  var _searching = false;
  Timer? _debounce;
  void Function()? _unshow;
  var _rows = const <SwitchItem>[];

  static const _pageSize = 60;

  @override
  void initState() {
    super.initState();
    unawaited(_more());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _unshow?.call();
    super.dispose();
  }

  Future<void> _more() async {
    if (_loading || _done) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ids = await widget.loadPage(_page);
      if (!mounted) return;
      setState(() {
        _ids.addAll(ids.where((id) => !_ids.contains(id)));
        _page++;
        _done = ids.length < _pageSize;
        _loading = false;
      });
      unawaited(_showPresence());
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e;
      });
    }
  }

  void _typed(String text) {
    _debounce?.cancel();
    final term = text.trim();
    setState(() => _term = term);
    if (term.isEmpty) {
      setState(() => _found = null);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _searching = true);
      try {
        final ids = await widget.search(term);
        if (!mounted || term != _term) return;
        setState(() {
          _found = ids;
          _searching = false;
        });
        unawaited(_showPresence());
      } on Object catch (e) {
        if (!mounted || term != _term) return;
        setState(() {
          _searching = false;
          _found = const [];
          _error = e;
        });
      }
    });
  }

  /// Keeps the presence of the people shown fresh while the list is open.
  Future<void> _showPresence() async {
    final session = await ref.read(serverSessionProvider(widget.url).future);
    if (!mounted) return;
    final next = session.connection.presence.show({..._ids, ...?_found});
    _unshow?.call();
    _unshow = next;
  }

  @override
  Widget build(BuildContext context) {
    final shownIds = _found ?? _ids;
    // A new page is a new query; the rows shown stay until it answers.
    final rows = _rows =
        ref.watch(peopleRowsProvider(widget.url, shownIds.join(','))).value ??
        _rows;
    // Typing narrows what is loaded at once; the server's answer follows.
    final local = _term.isEmpty || _found != null
        ? rows
        : rankSwitchItems(_term, rows, limit: 200);
    final busy = _loading || _searching;
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
            onChanged: _typed,
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
                    : _error != null
                    ? EmptyState(
                        icon: Icons.cloud_off,
                        title: "Couldn't load people",
                        body: requestProblemText(
                          _error!,
                          Uri.parse(widget.url).host,
                        ),
                        action: FilledButton.tonal(
                          onPressed: _more,
                          child: const Text('Retry'),
                        ),
                      )
                    : EmptyState(
                        icon: Icons.person_search_outlined,
                        title: _term.isEmpty
                            ? widget.emptyTitle
                            : 'Nobody matches "$_term"',
                        body: _term.isEmpty
                            ? widget.emptyBody
                            : 'Check the spelling or try part of a name.',
                      )
              : NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (_found == null &&
                        n.metrics.extentAfter < 600 &&
                        !_loading) {
                      unawaited(_more());
                    }
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
