import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/emoji_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/data/emoji/emoji_table.g.dart';
import 'package:matterleast/ui/custom_emoji_image.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'emoji_picker.g.dart';

/// Emoji the user picked or wrote lately, newest first.
@riverpod
Future<List<String>> recentEmoji(Ref ref, String url) async =>
    (await ref.watch(serverSessionProvider(url).future)).store.recentEmoji();

/// The skin tone the picker applies, 0 for none; kept while the app runs.
@Riverpod(keepAlive: true)
class SkinTone extends _$SkinTone {
  @override
  int build() => 0;

  void set(int tone) => state = tone;
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

const _categoryLabels = {
  _recent: 'Recent',
  'smileys-emotion': 'Smileys',
  'people-body': 'People',
  'animals-nature': 'Nature',
  'food-drink': 'Food',
  'travel-places': 'Travel',
  'activities': 'Activities',
  'objects': 'Objects',
  'symbols': 'Symbols',
  'flags': 'Flags',
  _custom: 'Custom',
};

/// Search, category chips and a grid of emoji.
class EmojiPicker extends ConsumerStatefulWidget {
  const EmojiPicker({required this.url, super.key});

  final String url;

  @override
  ConsumerState<EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends ConsumerState<EmojiPicker> {
  String? _category;
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final recent = ref.watch(recentEmojiProvider(widget.url)).value ?? [];
    final custom = ref.watch(customEmojiProvider(widget.url)).value ?? {};
    final tone = ref.watch(skinToneProvider);
    final categories = [
      if (recent.isNotEmpty) _recent,
      for (final c in emojiCategories)
        if (_categoryLabels.containsKey(c)) c,
      if (custom.isNotEmpty) _custom,
    ];
    final category = _category ?? categories.first;
    final query = _query.trim().toLowerCase().replaceAll(':', '');
    final names = query.isNotEmpty
        ? {
            for (final n in systemEmojiNames())
              if (n.contains(query)) canonicalName(n),
            for (final n in custom.keys)
              if (n.contains(query)) n,
          }.toList()
        : switch (category) {
            _recent => recent,
            _custom => (custom.keys.toList()..sort()),
            _ => namesInCategory(category),
          };
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
                onSelected: ref.read(skinToneProvider.notifier).set,
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
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.sm,
              ),
              children: [
                for (final c in categories)
                  Padding(
                    padding: const EdgeInsets.only(right: Spacing.sm),
                    child: ChoiceChip(
                      label: Text(_categoryLabels[c]!),
                      selected: c == category,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: names.isEmpty
              ? const Center(child: Text('No emoji match.'))
              : CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        Spacing.sm,
                        Spacing.sm,
                        Spacing.sm,
                        Spacing.sm + MediaQuery.paddingOf(context).bottom,
                      ),
                      sliver: SliverGrid.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 48,
                            ),
                        itemCount: names.length,
                        itemBuilder: (context, i) {
                          final name = names[i];
                          final id = custom[name];
                          final shown = id == null
                              ? withSkinTone(name, tone)
                              : name;
                          return InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.of(context).pop(shown),
                            child: Tooltip(
                              message: ':$name:',
                              child: Center(
                                child: id != null
                                    ? CustomEmojiImage(
                                        serverUrl: widget.url,
                                        emojiId: id,
                                        size: 28,
                                        fallback: Text(':$name:'),
                                      )
                                    : Text(
                                        unicodeForName(shown) ?? ':$name:',
                                        textScaler: TextScaler.noScaling,
                                        style: const TextStyle(fontSize: 26),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
