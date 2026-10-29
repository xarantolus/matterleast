import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/context_menu.dart';
import 'package:matterleast/app/emoji_providers.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/domain/preference_keys.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'emoji_picker.g.dart';

/// Emoji the user picked or wrote lately, newest first.
@riverpod
Future<List<String>> recentEmoji(Ref ref, String url) async =>
    (await ref.watch(serverSessionProvider(url).future)).store.recentEmoji();

/// The skin tone the picker applies, 0 for none, as the user's preference
/// on [url] has it.
@riverpod
Stream<int> skinTone(Ref ref, String url) async* {
  final db = (await ref.watch(serverSessionProvider(url).future)).db;
  yield* db.watchPreference(Prefs.skinTone).map(skinToneOf);
}

/// Lets the user pick an emoji; completes with its name, or null. On
/// desktop it opens as a popup next to [anchor] (global), the button that
/// opened it.
Future<String?> showEmojiPicker(
  BuildContext context,
  String url, {
  Rect? anchor,
}) => showAppSheet<String>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  useSafeArea: true,
  anchor: anchor,
  constraints: isDesktop ? BoxConstraints.tight(desktopPickerSize) : null,
  builder: (sheet) => isDesktop
      ? EmojiPicker(url: url, keyboard: true)
      : SizedBox(
          height: MediaQuery.sizeOf(sheet).height * 0.7,
          child: EmojiPicker(url: url),
        ),
);

const desktopPickerSize = Size(360, 420);

const _recent = 'recent';
const _custom = 'custom';

/// The picker's sections in order: the server's own emoji first, then the
/// recent ones, then the standard categories.
const _categories = <String, (String, IconData)>{
  _custom: ('Custom', Icons.auto_awesome_outlined),
  _recent: ('Recent', Icons.schedule),
  'smileys-emotion': ('Smileys and emotion', Icons.emoji_emotions_outlined),
  'people-body': ('People and body', Icons.emoji_people),
  'animals-nature': ('Animals and nature', Icons.emoji_nature),
  'food-drink': ('Food and drink', Icons.emoji_food_beverage_outlined),
  'travel-places': ('Travel and places', Icons.emoji_transportation),
  'activities': ('Activities', Icons.emoji_events_outlined),
  'objects': ('Objects', Icons.emoji_objects_outlined),
  'symbols': ('Symbols', Icons.emoji_symbols),
  'flags': ('Flags', Icons.emoji_flags_outlined),
};

typedef EmojiSection = ({String category, List<String> names});

/// Pure: the picker's sections, empty ones left out.
List<EmojiSection> emojiSections({
  required List<String> recent,
  required List<String> custom,
}) => [
  for (final category in _categories.keys)
    (
      category: category,
      names: switch (category) {
        _custom => custom,
        _recent => recent,
        _ => namesInCategory(category),
      },
    ),
].where((s) => s.names.isNotEmpty).toList();

/// Pure: where each of [sections] starts in a list of [columns] emoji per
/// row of [rowExtent], each section under a header of [headerExtent].
List<double> sectionOffsets(
  List<EmojiSection> sections, {
  required int columns,
  required double rowExtent,
  required double headerExtent,
}) {
  final offsets = <double>[];
  var at = 0.0;
  for (final s in sections) {
    offsets.add(at);
    at += headerExtent + (s.names.length / columns).ceil() * rowExtent;
  }
  return offsets;
}

/// At least 48 dp a cell on a 360 dp phone.
const _cell = 52.0;

/// Pure: how many cells a row of [width] holds.
int emojiColumns(double width) =>
    ((width - 2 * Spacing.sm) / _cell).floor().clamp(1, 1000);

/// Pure: the cell [step] away from [from] in a grid of [count] cells in
/// [columns] columns, or null when that leaves the grid. Left and right
/// wrap into the next row; up and down keep the column.
int? movedCell(
  int from,
  LogicalKeyboardKey key, {
  required int columns,
  required int count,
}) {
  final to = switch (key) {
    LogicalKeyboardKey.arrowLeft => from - 1,
    LogicalKeyboardKey.arrowRight => from + 1,
    LogicalKeyboardKey.arrowUp => from - columns,
    LogicalKeyboardKey.arrowDown => from + columns,
    _ => from,
  };
  return to < 0 || to >= count ? null : to;
}

/// Pure: where the row of the cell [index] of the sections starts, in
/// the scrolled list.
double cellTop(
  List<EmojiSection> sections,
  int index, {
  required int columns,
  required double headerExtent,
}) {
  final offsets = sectionOffsets(
    sections,
    columns: columns,
    rowExtent: _cell,
    headerExtent: headerExtent,
  );
  var first = 0;
  for (var i = 0; i < sections.length; i++) {
    final end = first + sections[i].names.length;
    if (index < end) {
      return offsets[i] + headerExtent + ((index - first) ~/ columns) * _cell;
    }
    first = end;
  }
  return 0;
}

/// Search, a category bar and every emoji in one list, by category.
class EmojiPicker extends ConsumerStatefulWidget {
  const EmojiPicker({required this.url, this.keyboard = false, super.key});

  final String url;

  /// Used with a keyboard: search has the focus from the start and Enter
  /// picks the first match.
  final bool keyboard;

  @override
  ConsumerState<EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends ConsumerState<EmojiPicker> {
  final _scroll = ScrollController();
  final _searchFocus = FocusNode(debugLabel: 'Emoji search');
  final _gridFocus = FocusNode(debugLabel: 'Emoji grid');
  var _query = '';

  /// The cell the arrow keys are on, an index into the cells shown.
  var _cursor = 0;
  var _current = 0;
  var _offsets = const <double>[];

  /// The custom emoji shown; it only changes while the list is at its top,
  /// so emoji arriving from the server never move what is being read.
  List<String>? _custom;
  List<String>? _recentShown;
  List<EmojiSection>? _sections;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_scrolled);
    _gridFocus.addListener(_gridFocusChanged);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchFocus.dispose();
    _gridFocus.dispose();
    super.dispose();
  }

  void _scrolled() {
    final at = _scroll.offset + 1;
    var current = 0;
    for (var i = 0; i < _offsets.length; i++) {
      if (_offsets[i] <= at) current = i;
    }
    if (current != _current) setState(() => _current = current);
  }

  // The ring shows on the cursor's cell only while the grid has the focus.
  void _gridFocusChanged() => setState(() {});

  String get _search => _query.trim().toLowerCase().replaceAll(':', '');

  /// The names of the cells shown, in reading order.
  List<String> _shownNames() => _search.isNotEmpty
      ? _matches(_search)
      : [for (final s in _sections ?? const <EmojiSection>[]) ...s.names];

  String? _pickable(int index) {
    final names = _shownNames();
    if (index < 0 || index >= names.length) return null;
    final custom = ref.read(customEmojiProvider(widget.url)).value ?? const {};
    final tone = ref.read(skinToneProvider(widget.url)).value ?? 0;
    return _withTone(names[index], custom, tone);
  }

  KeyEventResult _searchKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent ||
        event.logicalKey != LogicalKeyboardKey.arrowDown ||
        _shownNames().isEmpty) {
      return KeyEventResult.ignored;
    }
    setState(() => _cursor = 0);
    _gridFocus.requestFocus();
    _scrollToCursor();
    return KeyEventResult.handled;
  }

  KeyEventResult _gridKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      if (_pickable(_cursor) case final name?) Navigator.of(context).pop(name);
      return KeyEventResult.handled;
    }
    if (![
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowDown,
    ].contains(key)) {
      return KeyEventResult.ignored;
    }
    final columns = emojiColumns(context.size?.width ?? 0);
    final to = movedCell(
      _cursor,
      key,
      columns: columns,
      count: _shownNames().length,
    );
    if (to != null) {
      setState(() => _cursor = to);
      _scrollToCursor();
    } else if (key == LogicalKeyboardKey.arrowUp && _cursor < columns) {
      _searchFocus.requestFocus();
    }
    return KeyEventResult.handled;
  }

  /// Scrolls the cursor's row into view.
  void _scrollToCursor() {
    if (!_scroll.hasClients) return;
    final columns = emojiColumns(context.size?.width ?? 0);
    final top = _search.isNotEmpty
        ? (_cursor ~/ columns) * _cell
        : cellTop(
            _sections ?? const [],
            _cursor,
            columns: columns,
            headerExtent: MediaQuery.textScalerOf(context).scale(20) + 16,
          );
    final view = _scroll.position.viewportDimension;
    if (top < _scroll.offset) {
      _scroll.jumpTo(top);
    } else if (top + _cell > _scroll.offset + view) {
      _scroll.jumpTo(top + _cell - view);
    }
  }

  void _jump(int index) {
    if (index >= _offsets.length || !_scroll.hasClients) return;
    _scroll.jumpTo(_offsets[index].clamp(0, _scroll.position.maxScrollExtent));
    setState(() => _current = index);
  }

  Future<void> _setSkinTone(int tone) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final session = await ref.read(serverSessionProvider(widget.url).future);
      await session.settings.savePreference(Prefs.skinTone, skinToneCode(tone));
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't save the skin tone. "
            '${requestProblemText(e, Uri.parse(widget.url).host)}',
          ),
        ),
      );
    }
  }

  List<EmojiSection> _sectionsFor(
    List<String> recent,
    Map<String, String> custom,
  ) {
    final atTop = !_scroll.hasClients || _scroll.offset <= 0;
    if (_custom == null || atTop) {
      final names = custom.keys.toList()..sort();
      if (!listEquals(names, _custom)) {
        _custom = names;
        _sections = null;
      }
    }
    if (!identical(recent, _recentShown)) {
      _recentShown = recent;
      _sections = null;
    }
    return _sections ??= emojiSections(recent: recent, custom: _custom!);
  }

  List<String> _matches(String query) => {
    for (final n in _custom ?? const <String>[])
      if (n.contains(query)) n,
    for (final n in systemEmojiNames())
      if (n.contains(query)) canonicalName(n),
  }.toList();

  String _withTone(String name, Map<String, String> custom, int tone) =>
      custom.containsKey(name) ? name : withSkinTone(name, tone);

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(customEmojiCatalogProvider(widget.url)).isLoading;
    final recent = ref.watch(recentEmojiProvider(widget.url)).value ?? const [];
    final custom = ref.watch(customEmojiProvider(widget.url)).value ?? const {};
    final tone = ref.watch(skinToneProvider(widget.url)).value ?? 0;
    final sections = _sectionsFor(recent, custom);
    final query = _search;
    final headerExtent = MediaQuery.textScalerOf(context).scale(20) + 16;
    final bottom = MediaQuery.paddingOf(context).bottom;

    Widget cell(String name, int index) {
      final shown = _withTone(name, custom, tone);
      final ringed = index == _cursor && _gridFocus.hasFocus;
      // Read by its name once, not as the tooltip and the glyph.
      return Semantics(
        button: true,
        label: name.replaceAll('_', ' '),
        excludeSemantics: true,
        child: InkWell(
          mouseCursor: clickCursor,
          customBorder: const CircleBorder(),
          canRequestFocus: false,
          onTap: () => Navigator.of(context).pop(shown),
          child: Tooltip(
            message: ':$name:',
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: ringed
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : null,
              ),
              child: Center(
                child: EmojiGlyph(name: shown, size: 28, serverUrl: widget.url),
              ),
            ),
          ),
        ),
      );
    }

    final Widget body = LayoutBuilder(
      builder: (context, constraints) {
        final columns = emojiColumns(constraints.maxWidth);
        if (query.isNotEmpty) {
          final names = _matches(query);
          return names.isEmpty
              ? const Center(child: Text('No emoji match.'))
              : GridView.builder(
                  controller: _scroll,
                  padding: EdgeInsets.fromLTRB(
                    Spacing.sm,
                    Spacing.sm,
                    Spacing.sm,
                    Spacing.sm + bottom,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: _cell,
                  ),
                  itemCount: names.length,
                  itemBuilder: (_, i) => cell(names[i], i),
                );
        }
        _offsets = sectionOffsets(
          sections,
          columns: columns,
          rowExtent: _cell,
          headerExtent: headerExtent,
        );
        final starts = <int>[];
        var count = 0;
        for (final section in sections) {
          starts.add(count);
          count += section.names.length;
        }
        return CustomScrollView(
          controller: _scroll,
          slivers: [
            for (final (k, section) in sections.indexed) ...[
              SliverToBoxAdapter(
                child: SizedBox(
                  height: headerExtent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                    child: Align(
                      alignment: AlignmentDirectional.bottomStart,
                      child: Text(
                        _categories[section.category]!.$1.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.tokens.smallCaps,
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: _cell,
                  ),
                  itemCount: section.names.length,
                  itemBuilder: (_, i) => cell(section.names[i], starts[k] + i),
                ),
              ),
            ],
            SliverPadding(padding: EdgeInsets.only(bottom: bottom)),
          ],
        );
      },
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Focus(
                  canRequestFocus: false,
                  skipTraversal: true,
                  onKeyEvent: _searchKey,
                  child: SearchBar(
                    focusNode: _searchFocus,
                    autoFocus: widget.keyboard,
                    onSubmitted: widget.keyboard
                        ? (_) {
                            final first = _matches(query).firstOrNull;
                            if (query.isEmpty || first == null) return;
                            Navigator.of(context)
                                .pop(_withTone(first, custom, tone));
                          }
                        : null,
                    hintText: 'Search emoji',
                    leading: const Icon(Icons.search),
                    elevation: const WidgetStatePropertyAll(0),
                    onChanged: (q) => setState(() {
                      _query = q;
                      _cursor = 0;
                    }),
                  ),
                ),
              ),
              PopupMenuButton<int>(
                tooltip: 'Skin tone',
                initialValue: tone,
                onSelected: _setSkinTone,
                icon: Text(
                  unicodeForName(withSkinTone('hand', tone)) ?? '✋',
                  style: const TextStyle(fontSize: 24),
                ),
                itemBuilder: (_) => [
                  for (var t = 0; t <= skinToneSuffixes.length; t++)
                    MenuItem(
                      value: t,
                      child: Text(
                        unicodeForName(withSkinTone('hand', t)) ?? '✋',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (query.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            child: Row(
              children: [
                for (var i = 0; i < sections.length; i++)
                  Expanded(
                    child: _CategoryButton(
                      label: _categories[sections[i].category]!.$1,
                      icon: _categories[sections[i].category]!.$2,
                      selected: i == _current,
                      onTap: () => _jump(i),
                    ),
                  ),
              ],
            ),
          ),
        ProgressSlot(active: loading),
        Expanded(
          child: Focus(
            focusNode: _gridFocus,
            onKeyEvent: _gridKey,
            child: body,
          ),
        ),
      ],
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          mouseCursor: clickCursor,
          borderRadius: BorderRadius.circular(Spacing.sm),
          onTap: onTap,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 2,
                  color: selected ? colors.primary : Colors.transparent,
                ),
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: selected ? colors.primary : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
