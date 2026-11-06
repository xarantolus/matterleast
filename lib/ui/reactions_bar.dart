import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/density.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/person_tile.dart';
import 'package:matterleast/ui/post_semantics.dart';
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

  /// Opens the picker; it gets the add button's global rect.
  final ValueChanged<Rect?>? onAdd;

  // Each chip keeps a 48 dp tap target, which is the gap between rows.
  @override
  Widget build(BuildContext context) {
    final density = context.density;
    final chips = [for (final group in reactions) _chip(context, group)];
    final add = onAdd == null
        ? null
        : Builder(
            builder: (chip) => _fixed(
              density,
              ActionChip(
                mouseCursor: clickCursor,
                tooltip: 'Add reaction',
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                label: Icon(
                  Icons.add_reaction_outlined,
                  size: density.chipHeight == null ? 22 : 18,
                ),
                onPressed: () => onAdd!(globalRectOf(chip)),
              ),
            ),
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

  Widget _fixed(AppDensity density, Widget chip) => density.chipHeight == null
      ? chip
      : SizedBox(height: density.chipHeight, child: chip);

  Widget _chip(BuildContext context, ReactionGroup group) {
    final density = context.density;
    final small = density.chipHeight != null;
    final scheme = Theme.of(context).colorScheme;
    final mine = group.mine;
    return _fixed(
      density,
      GestureDetector(
        onLongPress: isDesktop
            ? null
            : () => showReactions(context, reactions, group),
        onSecondaryTapUp: isDesktop
            ? (d) => showReactions(
                context,
                reactions,
                group,
                anchor: d.globalPosition & Size.zero,
              )
            : null,
        child: FilterChip(
          mouseCursor: clickCursor,
          // A long press on a phone shows who reacted instead.
          tooltip: isDesktop
              ? reactionTooltip(
                  group,
                  myUsername:
                      PostEnvironment.maybeOf(context)?.myUsername ?? '',
                )
              : null,
          showCheckmark: false,
          selected: mine,
          // Colour alone marks an own reaction; its size never changes.
          side: BorderSide(
            color: mine ? scheme.primary : scheme.outlineVariant,
          ),
          selectedColor: scheme.primaryContainer,
          labelStyle: TextStyle(
            color: mine ? scheme.onPrimaryContainer : null,
            fontSize: small ? 13 : 17,
          ),
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          label: Semantics(
            label: reactionLabel(group),
            child: ExcludeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EmojiGlyph(name: group.emojiName, size: small ? 18 : 22),
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
      ),
    );
  }
}

/// What a screen reader says for a reaction chip: the emoji's name, how
/// many reacted and whether the user is one of them.
String reactionLabel(ReactionGroup group) => [
  emojiWords(group.emojiName),
  '${group.count}',
  if (group.mine) 'including you',
].join(', ');

/// Pure: who reacted, for the tooltip on desktop: "You, Wren and 2 others
/// reacted with :tada:". People not loaded yet count among the others.
String reactionTooltip(ReactionGroup group, {required String myUsername}) {
  const shown = 3;
  final named = [
    if (group.mine) 'You',
    for (final person in group.people)
      if (!(group.mine && person.username == myUsername))
        if (person.name.isNotEmpty ? person.name : person.username
            case final name when name.isNotEmpty)
          name,
  ];
  final names = named.take(shown).toList();
  final rest = group.count - names.length;
  final who = rest > 0
      ? '${names.join(', ')} and $rest ${rest == 1 ? 'other' : 'others'}'
      : names.length == 1
      ? names.single
      : '${names.take(names.length - 1).join(', ')} and ${names.last}';
  return '${names.isEmpty ? '$rest ${rest == 1 ? 'person' : 'people'}' : who}'
      ' reacted with :${group.emojiName}:';
}

/// The height of the who-reacted sheet: half the window on a phone, on
/// desktop as tall as its longest list of [people] needs, up to that.
double reactionsHeight({required int people, required double window}) {
  final most = window * 0.5;
  if (!isDesktop) return most;
  const tabBar = 48.0;
  const label = 40.0;
  const row = 56.0;
  return math.min(most, tabBar + label + people * row);
}

/// Who reacted, one tab per emoji, starting at [initial].
void showReactions(
  BuildContext context,
  List<ReactionGroup> reactions,
  ReactionGroup initial, {
  Rect? anchor,
}) {
  final env = PostEnvironment.maybeOf(context);
  showAppSheet<void>(
    context: context,
    anchor: anchor,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheet) {
      final body = DefaultTabController(
        length: reactions.length,
        initialIndex: reactions.indexOf(initial).clamp(0, reactions.length - 1),
        child: SizedBox(
          height: reactionsHeight(
            people: reactions.fold(0, (a, g) => math.max(a, g.people.length)),
            window: MediaQuery.sizeOf(sheet).height,
          ),
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
                              _Reactor(
                                url: env.server.toString(),
                                person: person,
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

/// One person who reacted. Someone the conversation had no profile for yet
/// is looked up here, so the open sheet names them once they arrive.
class _Reactor extends ConsumerWidget {
  const _Reactor({required this.url, required this.person});

  final String url;
  final PostPerson person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final known = person.username.isNotEmpty;
    if (!known) ref.watch(profileRefreshProvider(url, person.id));
    final profile = known
        ? null
        : ref.watch(userProfileProvider(url, person.id)).value;
    return PersonTile(
      serverUrl: url,
      userId: person.id,
      name: profile?.name ?? person.name,
      username: profile?.username ?? person.username,
      pictureUpdate: profile?.pictureUpdate ?? person.pictureAt,
    );
  }
}
