import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/emoji_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/domain/preference_keys.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
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

/// Lets the user pick an emoji; completes with its name, or null.
Future<String?> showEmojiPicker(BuildContext context, String url) =>
    showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheet) => SizedBox(
        height: MediaQuery.sizeOf(sheet).height * 0.7,
        child: EmojiPicker(url: url),
      ),
    );

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

/// Search, a category bar and every emoji in one list, by category.
class EmojiPicker extends ConsumerStatefulWidget {
  const EmojiPicker({required this.url, super.key});

  final String url;

  @override
  ConsumerState<EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends ConsumerState<EmojiPicker> {
  final _scroll = ScrollController();
  var _query = '';
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
  }

  @override
  void dispose() {
    _scroll.dispose();
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

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(customEmojiCatalogProvider(widget.url)).isLoading;
    final recent = ref.watch(recentEmojiProvider(widget.url)).value ?? const [];
    final custom = ref.watch(customEmojiProvider(widget.url)).value ?? const {};
    final tone = ref.watch(skinToneProvider(widget.url)).value ?? 0;
    final sections = _sectionsFor(recent, custom);
    final query = _query.trim().toLowerCase().replaceAll(':', '');
    final headerExtent = MediaQuery.textScalerOf(context).scale(20) + 16;
    final bottom = MediaQuery.paddingOf(context).bottom;

    Widget cell(String name) {
      final shown = custom.containsKey(name) ? name : withSkinTone(name, tone);
      // Read by its name once, not as the tooltip and the glyph.
      return Semantics(
        button: true,
        label: name.replaceAll('_', ' '),
        excludeSemantics: true,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.of(context).pop(shown),
          child: Tooltip(
            message: ':$name:',
            child: Center(
              child: EmojiGlyph(name: shown, size: 28, serverUrl: widget.url),
            ),
          ),
        ),
      );
    }

    final Widget body;
    if (query.isNotEmpty) {
      final names = {
        for (final n in _custom ?? const <String>[])
          if (n.contains(query)) n,
        for (final n in systemEmojiNames())
          if (n.contains(query)) canonicalName(n),
      }.toList();
      body = names.isEmpty
          ? const Center(child: Text('No emoji match.'))
          : GridView.builder(
              padding: EdgeInsets.fromLTRB(
                Spacing.sm,
                Spacing.sm,
                Spacing.sm,
                Spacing.sm + bottom,
              ),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: _cell,
              ),
              itemCount: names.length,
              itemBuilder: (_, i) => cell(names[i]),
            );
    } else {
      body = LayoutBuilder(
        builder: (context, constraints) {
          final columns = ((constraints.maxWidth - 2 * Spacing.sm) / _cell)
              .floor()
              .clamp(1, 1000);
          _offsets = sectionOffsets(
            sections,
            columns: columns,
            rowExtent: _cell,
            headerExtent: headerExtent,
          );
          return CustomScrollView(
            controller: _scroll,
            slivers: [
              for (final section in sections) ...[
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: headerExtent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.lg,
                      ),
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
                    itemBuilder: (_, i) => cell(section.names[i]),
                  ),
                ),
              ],
              SliverPadding(padding: EdgeInsets.only(bottom: bottom)),
            ],
          );
        },
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            children: [
              Expanded(
                child: SearchBar(
                  hintText: 'Search emoji',
                  leading: const Icon(Icons.search),
                  elevation: const WidgetStatePropertyAll(0),
                  onChanged: (q) => setState(() => _query = q),
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
                    PopupMenuItem(
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
        Expanded(child: body),
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
