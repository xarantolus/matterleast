import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/channel_info/edit_channel_screen.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/search/quick_search.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/tokens.dart';

/// The team's public channels the user is not in, or its archived ones,
/// a page at a time; joining asks first.
class BrowseChannelsScreen extends ConsumerStatefulWidget {
  const BrowseChannelsScreen({
    required this.url,
    required this.teamId,
    super.key,
  });

  final String url;
  final String teamId;

  @override
  ConsumerState<BrowseChannelsScreen> createState() =>
      _BrowseChannelsScreenState();
}

class _BrowseChannelsScreenState extends ConsumerState<BrowseChannelsScreen> {
  var _archived = false;
  final _items = <SwitchItem>[];
  var _page = 0;
  var _done = false;
  var _loading = false;
  Object? _error;
  var _term = '';
  List<SwitchItem>? _found;
  Timer? _debounce;
  var _working = false;

  String get _host => Uri.parse(widget.url).host;

  @override
  void initState() {
    super.initState();
    unawaited(_more());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _more() async {
    if (_loading || _done) return;
    final archived = _archived;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final directory = await ref.read(directoryProvider(widget.url).future);
      final page = await directory.channels(
        widget.teamId,
        archived: archived,
        page: _page,
      );
      if (!mounted || archived != _archived) return;
      setState(() {
        _items.addAll(
          page.items.where((c) => !_items.any((i) => i.id == c.id)),
        );
        _page++;
        _done = !page.more;
        _loading = false;
      });
      // Joined channels are left out, so a page can show little or nothing.
      if (page.more && page.items.length < 10) unawaited(_more());
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e;
      });
    }
  }

  void _switch(bool archived) {
    setState(() {
      _archived = archived;
      _items.clear();
      _page = 0;
      _done = false;
      _loading = false;
      _found = null;
    });
    if (_term.isNotEmpty) _typed(_term);
    unawaited(_more());
  }

  void _typed(String text) {
    _debounce?.cancel();
    final term = text.trim();
    setState(() {
      _term = term;
      _found = null;
    });
    // Archived channels are few; the loaded ones are narrowed locally.
    if (term.isEmpty || _archived) return;
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final directory = await ref.read(directoryProvider(widget.url).future);
        final found = await directory.searchChannels(widget.teamId, term);
        if (mounted && term == _term) setState(() => _found = found);
      } on Object catch (e) {
        if (mounted && term == _term) setState(() => _error = e);
      }
    });
  }

  Future<void> _open(SwitchItem item) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!_archived && !await confirmJoin(context, item.title)) return;
    setState(() => _working = true);
    try {
      final actions = await ref.read(channelActionsProvider(widget.url).future);
      if (!_archived) await actions.join(item.id);
      if (!mounted) return;
      unawaited(
        openConversation(
          navigator,
          url: widget.url,
          channelId: item.id,
          title: item.title,
          teamId: widget.teamId,
        ),
      );
      navigator.pop();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _working = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't join ${item.title}. ${requestProblemText(e, _host)}",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rights = ref.watch(teamRightsProvider(widget.url, widget.teamId));
    final archivedShown =
        ref.watch(featuresProvider(widget.url)).value?.archivedChannels ?? true;
    final canCreate =
        (rights.value?.public ?? false) || (rights.value?.private ?? false);
    final shown =
        _found ??
        (_term.isEmpty ? _items : rankSwitchItems(_term, _items, limit: 200));
    final busy = _loading || _working;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse channels'),
        actions: [
          if (canCreate)
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
              ),
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      EditChannelScreen(url: widget.url, teamId: widget.teamId),
                ),
              ),
              child: const Text('Create'),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.sm,
                Spacing.md,
                0,
              ),
              child: SearchBar(
                hintText: 'Search channels',
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll(0),
                onChanged: _typed,
              ),
            ),
            if (archivedShown)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FilterChip(
                    avatar: const Icon(Icons.archive_outlined, size: 18),
                    label: const Text('Archived channels'),
                    selected: _archived,
                    onSelected: _switch,
                  ),
                ),
              ),
            SizedBox(
              height: 3,
              child: busy && shown.isNotEmpty
                  ? const LinearProgressIndicator(minHeight: 3)
                  : null,
            ),
            Expanded(
              child: shown.isEmpty
                  ? busy || (_term.isNotEmpty && _found == null && !_archived)
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                        ? EmptyState(
                            icon: Icons.cloud_off,
                            title: "Couldn't load channels",
                            body: requestProblemText(_error!, _host),
                            action: FilledButton.tonal(
                              onPressed: _more,
                              child: const Text('Retry'),
                            ),
                          )
                        : EmptyState(
                            icon: _archived
                                ? Icons.archive_outlined
                                : Icons.travel_explore,
                            title: _term.isNotEmpty
                                ? 'No channels match "$_term"'
                                : _archived
                                ? 'No archived channels'
                                : 'No more channels to join',
                            body: _archived
                                ? 'Channels show up here once they are '
                                      'archived.'
                                : "You're in every public channel of this "
                                      'team. Create one to start something '
                                      'new.',
                          )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (_found == null && n.metrics.extentAfter < 600) {
                          unawaited(_more());
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: bottom + Spacing.lg),
                        itemCount: shown.length,
                        itemBuilder: (context, i) => SwitchTile(
                          item: shown[i],
                          onTap: busy ? () {} : () => _open(shown[i]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
