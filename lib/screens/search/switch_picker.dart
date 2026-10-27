import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/screens/search/quick_search.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/pane_label.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/tokens.dart';

/// A sheet to pick one item, narrowed by typing; null when dismissed. It
/// offers [items], or with [serverUrl] that server's stored items of
/// [kinds], kept up to date. With [findPeople], typing also finds people
/// stored and on the server, to start a direct message with.
Future<SwitchItem?> pickSwitchItem(
  BuildContext context, {
  required String title,
  required String hint,
  List<SwitchItem> items = const [],
  String? serverUrl,
  Set<SwitchKind> kinds = const {},
  bool findPeople = false,
}) => showAppSheet<SwitchItem>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => SwitchPicker(
    title: title,
    hint: hint,
    items: items,
    serverUrl: serverUrl,
    kinds: kinds,
    findPeople: findPeople,
  ),
);

class SwitchPicker extends ConsumerStatefulWidget {
  const SwitchPicker({
    required this.title,
    required this.hint,
    this.items = const [],
    this.serverUrl,
    this.kinds = const {},
    this.findPeople = false,
    super.key,
  });

  final String title;
  final String hint;
  final List<SwitchItem> items;
  final String? serverUrl;
  final Set<SwitchKind> kinds;
  final bool findPeople;

  @override
  ConsumerState<SwitchPicker> createState() => _SwitchPickerState();
}

class _SwitchPickerState extends ConsumerState<SwitchPicker> {
  var _term = '';
  var _remoteTerm = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _typed(String text) {
    setState(() => _term = text);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _remoteTerm = _term);
    });
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.serverUrl;
    final stored = url == null
        ? widget.items
        : ref.watch(switchItemsProvider(url)).value ?? const <SwitchItem>[];
    final offered = url == null
        ? stored
        : [
            for (final item in stored)
              if (widget.kinds.contains(item.kind)) item,
          ];
    final term = _term.trim();
    var searching = false;
    final List<Widget> rows;
    if (term.isEmpty) {
      final start = pickerStart(offered);
      rows = [
        if (start.recent.isNotEmpty) ...[
          const PaneLabel('Recent'),
          for (final item in start.recent) _tile(item),
          if (start.rest.isNotEmpty) const PaneLabel('All'),
        ],
        for (final item in start.rest) _tile(item),
      ];
    } else {
      final people = widget.findPeople && url != null;
      final local = rankSwitchItems(term, [
        ...offered,
        if (people)
          for (final item in stored)
            if (item.kind == SwitchKind.person) item,
      ], limit: 100);
      final remote = <SwitchItem>[];
      if (people) {
        searching = !ref.watch(offlineProvider) && _remoteTerm.trim() != term;
        final answer = ref.watch(switchRemoteProvider(url, _remoteTerm));
        if (answer.isLoading) searching = true;
        for (final item in answer.value ?? const <SwitchItem>[]) {
          if (item.kind == SwitchKind.person ||
              widget.kinds.contains(item.kind)) {
            remote.add(item);
          }
        }
      }
      final extra = extraRemoteItems(term, local, remote);
      rows = [
        for (final item in [...local, ...extra]) _tile(item),
        if (local.isEmpty && extra.isEmpty && !searching)
          Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Text(
              'Nothing matches "$term".',
              style: TextStyle(color: context.tokens.muted),
            ),
          ),
      ];
    }
    final insets = MediaQuery.viewInsetsOf(context).bottom;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: Padding(
        padding: EdgeInsets.only(bottom: insets),
        child: Column(
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: SearchBar(
                hintText: widget.hint,
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll(0),
                onChanged: _typed,
              ),
            ),
            ProgressSlot(active: searching),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom,
                ),
                children: rows,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(SwitchItem item) => SwitchTile(
    key: ValueKey(item.key),
    item: item,
    onTap: () => Navigator.of(context).pop(item),
  );
}
