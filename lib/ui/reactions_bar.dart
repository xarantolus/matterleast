import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/tokens.dart';

/// The emoji people reacted with, each with how many; the user's own are
/// selected. Tap toggles the user's own reaction, long-press shows who
/// reacted.
class ReactionsBar extends StatelessWidget {
  const ReactionsBar({
    required this.reactions,
    this.onToggle,
    this.onAdd,
    super.key,
  });

  final List<ReactionGroup> reactions;
  final ValueChanged<String>? onToggle;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Spacing.xs),
    child: Wrap(
      spacing: Spacing.xs,
      runSpacing: Spacing.xs,
      children: [
        for (final group in reactions)
          GestureDetector(
            onLongPress: () => showReactions(context, reactions, group),
            child: FilterChip(
              showCheckmark: false,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              selected: group.mine,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EmojiGlyph(name: group.emojiName, size: 18),
                  const SizedBox(width: Spacing.xs),
                  Text('${group.count}'),
                ],
              ),
              onSelected: (_) => onToggle != null
                  ? onToggle!(group.emojiName)
                  : showReactions(context, reactions, group),
            ),
          ),
        if (onAdd != null)
          ActionChip(
            tooltip: 'Add reaction',
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            label: const Icon(Icons.add_reaction_outlined, size: 18),
            onPressed: onAdd,
          ),
      ],
    ),
  );
}

/// Who reacted, one tab per emoji, starting at [initial].
void showReactions(
  BuildContext context,
  List<ReactionGroup> reactions,
  ReactionGroup initial,
) {
  final env = PostEnvironment.maybeOf(context);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheet) {
      final body = DefaultTabController(
        length: reactions.length,
        initialIndex: reactions.indexOf(initial).clamp(0, reactions.length - 1),
        child: SizedBox(
          height: MediaQuery.sizeOf(sheet).height * 0.5,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  for (final group in reactions)
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          EmojiGlyph(name: group.emojiName, size: 20),
                          const SizedBox(width: Spacing.xs),
                          Text('${group.count}'),
                        ],
                      ),
                    ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    for (final group in reactions)
                      ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              Spacing.lg,
                              Spacing.md,
                              Spacing.lg,
                              Spacing.xs,
                            ),
                            child: Text(
                              ':${group.emojiName}:',
                              style: context.tokens.smallCaps,
                            ),
                          ),
                          for (final name in group.names)
                            ListTile(title: Text(name)),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      return env == null
          ? body
          : PostEnvironment(
              server: env.server,
              options: env.options,
              myUsername: env.myUsername,
              onMention: env.onMention,
              onChannel: env.onChannel,
              onLink: env.onLink,
              customEmoji: env.customEmoji,
              image: env.image,
              child: body,
            );
    },
  );
}
