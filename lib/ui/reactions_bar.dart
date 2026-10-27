import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/person_tile.dart';
import 'package:matterleast/ui/tokens.dart';

/// The emoji people reacted with, each with how many; the user's own are
/// selected. Tap toggles the user's own reaction, long-press shows who
/// reacted. Without [onToggle] a tap shows who reacted too.
class ReactionsBar extends StatelessWidget {
  const ReactionsBar({
    required this.reactions,
    this.onToggle,
    this.onAdd,
    this.leading,
    super.key,
  });

  final List<ReactionGroup> reactions;

  /// Comes first in the row, such as the acknowledge button.
  final Widget? leading;
  final ValueChanged<String>? onToggle;
  final VoidCallback? onAdd;

  // Each chip keeps a 48 dp tap target, which is the gap between rows.
  @override
  Widget build(BuildContext context) {
    final chips = [for (final group in reactions) _chip(context, group)];
    final add = onAdd == null
        ? null
        : ActionChip(
            tooltip: 'Add reaction',
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            label: const Icon(Icons.add_reaction_outlined, size: 18),
            onPressed: onAdd,
          );
    return Wrap(
      spacing: Spacing.xs,
      children: [
        ?leading,
        if (add != null && chips.isNotEmpty) ...[
          ...chips.take(chips.length - 1),
          // The add button wraps together with the last reaction, never
          // onto a line of its own.
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.xs,
            children: [chips.last, add],
          ),
        ] else ...[
          ...chips,
          ?add,
        ],
      ],
    );
  }

  Widget _chip(BuildContext context, ReactionGroup group) {
    final scheme = Theme.of(context).colorScheme;
    final mine = group.mine;
    return GestureDetector(
      onLongPress: () => showReactions(context, reactions, group),
      child: FilterChip(
        showCheckmark: false,
        selected: mine,
        // A clear outline, so a lone own reaction reads as yours.
        side: BorderSide(
          color: mine ? scheme.primary : scheme.outlineVariant,
          width: mine ? 1.5 : 1,
        ),
        selectedColor: scheme.primaryContainer,
        labelStyle: mine
            ? TextStyle(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              )
            : null,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        label: Semantics(
          label: reactionLabel(group),
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                EmojiGlyph(name: group.emojiName, size: 18),
                const SizedBox(width: Spacing.xs),
                Text('${group.count}'),
              ],
            ),
          ),
        ),
        onSelected: (_) => onToggle != null
            ? onToggle!(group.emojiName)
            : showReactions(context, reactions, group),
      ),
    );
  }
}

/// What a screen reader says for a reaction chip: the emoji's name, how
/// many reacted and whether the user is one of them.
String reactionLabel(ReactionGroup group) => [
  group.emojiName.replaceAll('_', ' '),
  '${group.count}',
  if (group.mine) 'including you',
].join(', ');

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
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: context.tokens.muted),
                            ),
                          ),
                          for (final person in group.people)
                            if (env == null)
                              ListTile(title: Text(person.name))
                            else
                              PersonTile(
                                serverUrl: env.server.toString(),
                                userId: person.id,
                                name: person.name,
                                username: person.username,
                                pictureUpdate: person.pictureAt,
                              ),
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
