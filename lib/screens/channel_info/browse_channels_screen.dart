import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/paged_search.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/channel_info/edit_channel_screen.dart';
import 'package:matterleast/screens/channel_info/paged_search_controller.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/search/quick_search.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/slide_route.dart';
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
  // Joined channels are left out, so a page can show little or nothing.
  late final _list = PagedSearchController<SwitchItem>(
    loadPage: _loadPage,
    search: _search,
    keyOf: (c) => c.id,
    keepLoadingBelow: 10,
  )..addListener(_listed);
  var _working = false;

  String get _host => Uri.parse(widget.url).host;

  @override
  void initState() {
    super.initState();
    unawaited(_list.more());
  }

  @override
  void dispose() {
    _list.dispose();
    super.dispose();
  }

  void _listed() => setState(() {});

  Future<ServerPage<SwitchItem>> _loadPage(int page) async {
    final archived = _archived;
    final directory = await ref.read(directoryProvider(widget.url).future);
    return directory.channels(widget.teamId, archived: archived, page: page);
  }

  Future<List<SwitchItem>> _search(String term) async {
    final directory = await ref.read(directoryProvider(widget.url).future);
    return directory.searchChannels(widget.teamId, term);
  }

  void _switch(bool archived) {
    setState(() => _archived = archived);
    // Archived channels are few; the loaded ones are narrowed locally.
    _list.search = archived ? null : _search;
    unawaited(_list.restart());
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
      setState(() => _working = false);
      // This screen goes first, so the conversation opens over the list.
      navigator.pop();
      unawaited(
        openConversation(
          navigator,
          url: widget.url,
          channelId: item.id,
          title: item.title,
          teamId: widget.teamId,
        ),
      );
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

  void _create() => unawaited(
    Navigator.of(context).pushReplacement(
      SlideRoute<void>(
        builder: (_) =>
            EditChannelScreen(url: widget.url, teamId: widget.teamId),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final rights = ref.watch(teamRightsProvider(widget.url, widget.teamId));
    final archivedShown =
        ref.watch(featuresProvider(widget.url)).value?.archivedChannels ?? true;
    final canCreate =
        (rights.value?.public ?? false) || (rights.value?.private ?? false);
    final list = _list.value;
    final term = list.term;
    final shown =
        list.found ??
        (term.isEmpty
            ? list.items
            : rankSwitchItems(term, list.items, limit: 200));
    final busy = list.busy || _working;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse channels'),
        actions: [
          if (canCreate)
            TextButton(
              style: context.barButtonStyle,
              onPressed: _create,
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
                onChanged: _list.typed,
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
                    mouseCursor: clickCursor,
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
                  ? busy ||
                            (term.isNotEmpty &&
                                list.found == null &&
                                !_archived)
                        ? const Center(child: CircularProgressIndicator())
                        : list.error != null
                        ? EmptyState(
                            icon: Icons.cloud_off,
                            title: "Couldn't load channels",
                            body: requestProblemText(list.error!, _host),
                            action: FilledButton.tonal(
                              onPressed: _list.retry,
                              child: const Text('Retry'),
                            ),
                          )
                        : EmptyState(
                            icon: _archived
                                ? Icons.archive_outlined
                                : Icons.travel_explore,
                            title: term.isNotEmpty
                                ? 'No channels match "$term"'
                                : _archived
                                ? 'No archived channels'
                                : 'No more channels to join',
                            body: _archived
                                ? 'Channels show up here once they are '
                                      'archived.'
                                : "You're in every public channel of this "
                                      'team. Create one to start something '
                                      'new.',
                            action: canCreate && !_archived && term.isEmpty
                                ? FilledButton.tonal(
                                    onPressed: _create,
                                    child: const Text('Create channel'),
                                  )
                                : null,
                          )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n.metrics.extentAfter < 600) {
                          unawaited(_list.more());
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: bottom + Spacing.lg),
                        itemCount: shown.length,
                        itemBuilder: (context, i) => SwitchTile(
                          item: shown[i],
                          markKind: false,
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
