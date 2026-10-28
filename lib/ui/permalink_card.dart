import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/markdown/links.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

const _maxCharacters = 150;

/// Pure: the start of a linked message as its card quotes it.
String linkedExcerpt(String message) {
  final text = message.trim();
  if (text.length <= _maxCharacters) return text;
  return '${text.substring(0, _maxCharacters).trimRight()}…';
}

/// Opens the message [linked] points to in its conversation.
void openLinkedPost(PostEnvironment env, LinkedPostPreview linked) {
  final team = linked.teamName.isEmpty ? '_' : linked.teamName;
  env.onLink(
    LinkTarget.uri(serverUri(env.server, '$team/pl/${linked.postId}')),
  );
}

/// A card of the message a link in this one points to: who wrote it, when
/// and where, and how it starts. A tap opens it in its conversation.
class PermalinkCard extends ConsumerStatefulWidget {
  const PermalinkCard({required this.linked, super.key});

  final LinkedPostPreview linked;

  @override
  ConsumerState<PermalinkCard> createState() => _PermalinkCardState();
}

class _PermalinkCardState extends ConsumerState<PermalinkCard> {
  @override
  void initState() {
    super.initState();
    final env = context.getInheritedWidgetOfExactType<PostEnvironment>();
    final authorId = widget.linked.authorId;
    if (env == null || authorId.isEmpty) return;
    // The author may be someone no stored message brought in yet.
    unawaited(
      ref
          .read(serverSessionProvider(env.server.toString()).future)
          .then((session) => session.users.ensure([authorId]))
          .catchError((Object _) {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final linked = widget.linked;
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final env = PostEnvironment.maybeOf(context);
    final excerpt = linkedExcerpt(linked.message);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: Card.outlined(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          mouseCursor: clickCursor,
          onTap: env == null ? null : () => openLinkedPost(env, linked),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (env != null) ...[
                      UserAvatar(
                        serverUrl: env.server.toString(),
                        userId: linked.authorId,
                        name: linked.authorName,
                        lastPictureUpdate: linked.authorPictureAt,
                        size: 24,
                      ),
                      const SizedBox(width: Spacing.sm),
                    ],
                    Flexible(
                      child: Text(
                        linked.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall?.copyWith(color: tokens.text),
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Text(
                      momentLabel(
                        linked.createAt,
                        ref.watch(todayProvider),
                        use24: MediaQuery.alwaysUse24HourFormatOf(context),
                      ),
                      style: text.bodySmall?.copyWith(color: tokens.muted),
                    ),
                  ],
                ),
                if (excerpt.isNotEmpty) ...[
                  const SizedBox(height: Spacing.xs),
                  PostBody(
                    postId: 'linked:${linked.postId}:${excerpt.hashCode}',
                    message: excerpt,
                    collapsible: false,
                  ),
                ],
                const SizedBox(height: Spacing.xs),
                Text.rich(
                  TextSpan(
                    text: 'Originally posted in ',
                    children: [
                      TextSpan(
                        text: '~${linked.channelName}',
                        style: TextStyle(
                          color: tokens.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(color: tokens.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
