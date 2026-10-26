import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/domain/post_details.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/system_message.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/screens/you/user_profile_sheet.dart';
import 'package:matterleast/ui/attachment_card.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/link_preview_card.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/post_files.dart';
import 'package:matterleast/ui/reactions_bar.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

const _avatarSize = 36.0;
const _gutter = _avatarSize + Spacing.md;

/// One message: avatar, name and time, then the text and what comes with
/// it. A [compact] message continues the one above it from the same person.
class PostTile extends StatelessWidget {
  const PostTile({
    required this.post,
    this.compact = false,
    this.combined = const [],
    this.highlighted = false,
    this.onOpenThread,
    this.onDismiss,
    this.onToggleReaction,
    this.onAddReaction,
    super.key,
  });

  final PostItem post;
  final bool compact;

  /// Later membership messages told in the same line as [post].
  final List<PostItem> combined;
  final bool highlighted;

  /// Shows the replies bar under the first message of a thread.
  final VoidCallback? onOpenThread;

  /// Hides an ephemeral message.
  final VoidCallback? onDismiss;

  /// Adds or removes the user's reaction with that emoji.
  final ValueChanged<String>? onToggleReaction;
  final VoidCallback? onAddReaction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    if (post.isSystem && !post.deleted) {
      return _SystemLine(post: post, combined: combined);
    }
    final details = detailsOf(post);
    final env = PostEnvironment.maybeOf(context);
    final webhook = details.fromWebhook;
    final override = details.props.overrideUsername;
    final name =
        webhook &&
            (override?.isNotEmpty ?? false) &&
            (env?.usernameOverride ?? false)
        ? override!
        : post.authorName;
    final bot = post.authorIsBot || webhook || details.props.fromBot == 'true';
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!compact)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Spacing.sm,
            children: [
              _ToProfile(
                post: post,
                details: details,
                child: Text(
                  name,
                  style: text.titleSmall?.copyWith(color: tokens.text),
                ),
              ),
              if (bot)
                const _Tag('BOT')
              else if (post.authorIsGuest)
                const _Tag('GUEST'),
              Text(
                _time(context, post.createAt),
                style: text.bodySmall?.copyWith(color: tokens.muted),
              ),
              if (details.priority case final priority?)
                _PriorityLabel(priority: priority),
              if (post.isEphemeral)
                Text(
                  '(Only visible to you)',
                  style: text.bodySmall?.copyWith(color: tokens.muted),
                ),
              if (post.isEphemeral && onDismiss != null)
                InkWell(
                  onTap: onDismiss,
                  child: Text(
                    'Dismiss',
                    style: text.bodySmall?.copyWith(color: tokens.accent),
                  ),
                ),
            ],
          ),
        if (post.unreadable)
          _Unreadable(post: post)
        else
          PostText(post: post, details: details),
        if (details.files.isNotEmpty && !post.deleted)
          PostFiles(
            files: details.files,
            heroPrefix: 'post:${post.key}',
            author: name,
            sentAt: post.createAt,
          ),
        for (final (i, attachment) in details.props.attachments.indexed)
          AttachmentCard(
            attachment: attachment,
            keyPrefix: '${post.id}:${post.editAt?.millisecondsSinceEpoch}:$i',
            imageSizes: details.imageSizes,
          ),
        if (details.preview case final preview? when env?.linkPreviews ?? true)
          LinkPreviewCard(preview: preview),
        if (post.reactions.isNotEmpty && !post.deleted)
          ReactionsBar(
            reactions: post.reactions,
            onToggle: onToggleReaction,
            onAdd: onAddReaction,
          ),
        if (onOpenThread != null && !post.isReply && post.replyCount > 0)
          _ThreadBar(post: post, onPressed: onOpenThread!),
      ],
    );
    return Opacity(
      opacity: post.sendState == null ? 1 : 0.5,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: highlighted ? tokens.accentWash : Colors.transparent,
        padding: EdgeInsets.fromLTRB(
          Spacing.lg,
          compact ? 2 : Spacing.sm,
          Spacing.lg,
          2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (compact)
              const SizedBox(width: _gutter)
            else ...[
              _ToProfile(
                post: post,
                details: details,
                child: _Avatar(post: post, name: name, details: details),
              ),
              const SizedBox(width: Spacing.md),
            ],
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

/// In place of a message the app couldn't read: says so, and lets the
/// reader copy what a bug report needs.
class _Unreadable extends StatelessWidget {
  const _Unreadable({required this.post});

  final PostItem post;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: Spacing.sm,
      children: [
        Text(
          "This message couldn't be shown",
          style: text.bodyMedium?.copyWith(
            color: tokens.muted,
            fontStyle: FontStyle.italic,
          ),
        ),
        TextButton.icon(
          // Android confirms the copy itself.
          onPressed: () => unawaited(
            Clipboard.setData(ClipboardData(text: unreadableDetails(post))),
          ),
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copy details'),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.post,
    required this.name,
    required this.details,
  });

  final PostItem post;
  final String name;
  final PostDetails details;

  @override
  Widget build(BuildContext context) {
    final env = PostEnvironment.maybeOf(context);
    final icon = details.props.overrideIconUrl;
    final webhookIcon =
        details.fromWebhook &&
        (icon?.isNotEmpty ?? false) &&
        (env?.iconOverride ?? false);
    // A webhook post without its own icon is not the creator's to show.
    if (env == null || (details.fromWebhook && !webhookIcon)) {
      return InitialsBadge(name: name, size: _avatarSize, round: true);
    }
    return UserAvatar(
      serverUrl: env.server.toString(),
      userId: post.userId,
      name: name,
      lastPictureUpdate: post.authorPictureAt,
      size: _avatarSize,
      overrideIconUrl: webhookIcon ? icon : null,
    );
  }
}

/// Opens the author's profile on tap; a webhook's post has no author to
/// show.
class _ToProfile extends StatelessWidget {
  const _ToProfile({
    required this.post,
    required this.details,
    required this.child,
  });

  final PostItem post;
  final PostDetails details;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final env = PostEnvironment.maybeOf(context);
    if (env == null || details.fromWebhook || post.userId.isEmpty) {
      return child;
    }
    return Semantics(
      button: true,
      label: 'Profile',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showUserProfile(
          context,
          url: env.server.toString(),
          userId: post.userId,
        ),
        child: child,
      ),
    );
  }
}

/// A small label beside the author's name, such as BOT.
class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: tokens.muted, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PriorityLabel extends StatelessWidget {
  const _PriorityLabel({required this.priority});

  final PostPriorityLabel priority;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, icon, background, foreground) = switch (priority) {
      PostPriorityLabel.urgent => (
        'URGENT',
        Icons.error_outline,
        scheme.error,
        scheme.onError,
      ),
      PostPriorityLabel.important => (
        'IMPORTANT',
        Icons.info_outline,
        scheme.primary,
        scheme.onPrimary,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: foreground),
          const SizedBox(width: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// The message text, formatted.
class PostText extends StatelessWidget {
  const PostText({required this.post, required this.details, super.key});

  final PostItem post;
  final PostDetails details;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final style = Theme.of(context).textTheme.bodyMedium;
    if (post.deleted) {
      return Text(
        '(message deleted)',
        style: style?.copyWith(
          color: tokens.muted,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    if (post.message.isEmpty) {
      return post.edited
          ? Text(
              '(edited)',
              style: style?.copyWith(color: tokens.muted, fontSize: 12),
            )
          : const SizedBox.shrink();
    }
    return PostBody(
      postId: post.id,
      message: post.message,
      editAt: post.editAt,
      edited: post.edited,
      imageSizes: details.imageSizes,
      channelNames: details.props.channelMentions,
      unsafeLinks: details.unsafeLinks,
    );
  }
}

String _time(BuildContext context, DateTime at) =>
    timeLabel(at, use24: MediaQuery.alwaysUse24HourFormatOf(context));

class _SystemLine extends StatelessWidget {
  const _SystemLine({required this.post, required this.combined});

  final PostItem post;
  final List<PostItem> combined;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final activity = Activity.of(post.type);
    final line = activity != null
        ? activityText(activity, [
            for (final p in [post, ...combined])
              activityEntry(activity, detailsOf(p).props),
          ])
        : systemMessageText(post.type, detailsOf(post).props, post.message);
    final style = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: tokens.muted);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg + _gutter,
        Spacing.xs,
        Spacing.lg,
        Spacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: PostBody(
              postId: '${post.id}:system:${combined.length}',
              message: line,
              editAt: post.editAt,
              collapsible: false,
              style: style,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Text(_time(context, post.createAt), style: style),
        ],
      ),
    );
  }
}

class _ThreadBar extends ConsumerWidget {
  const _ThreadBar({required this.post, required this.onPressed});

  final PostItem post;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final count = post.replyCount;
    final unread = post.unreadReplies;
    final lastReply = post.lastReplyAt;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.sm, bottom: Spacing.xs),
      child: Material(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: Spacing.xs,
              ),
              child: Row(
                children: [
                  _Participants(people: post.participants.take(3).toList()),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: count == 1 ? '1 reply' : '$count replies',
                            style: TextStyle(
                              color: tokens.accent,
                              fontWeight: unread > 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          if (lastReply != null)
                            TextSpan(
                              text:
                                  '  Last reply ${whenLabel(lastReply, ref.watch(todayProvider), use24: MediaQuery.alwaysUse24HourFormatOf(context))}',
                              style: TextStyle(color: tokens.muted),
                            ),
                        ],
                      ),
                      style: text.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (unread > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: Spacing.sm),
                      child: Badge.count(count: unread),
                    ),
                  Icon(Icons.chevron_right, color: tokens.muted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Up to three people who replied, overlapping like a stack of cards.
class _Participants extends StatelessWidget {
  const _Participants({required this.people});

  final List<PostPerson> people;

  static const _size = 24.0;
  static const _step = 16.0;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();
    final page = context.tokens.panel;
    final server = PostEnvironment.maybeOf(context)?.server.toString();
    return Padding(
      padding: const EdgeInsets.only(right: Spacing.sm),
      child: SizedBox(
        width: _size + _step * (people.length - 1),
        height: _size,
        child: Stack(
          children: [
            for (final (i, person) in people.indexed)
              Positioned(
                left: i * _step,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: page, width: 1.5),
                  ),
                  child: server == null
                      ? InitialsBadge(
                          name: person.name,
                          size: _size,
                          round: true,
                        )
                      : UserAvatar(
                          serverUrl: server,
                          userId: person.id,
                          name: person.name,
                          lastPictureUpdate: person.pictureAt,
                          size: _size,
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "Today", "Yesterday" or the date, between days.
class DaySeparatorTile extends ConsumerWidget {
  const DaySeparatorTile({required this.day, super.key});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: Spacing.lg,
      vertical: Spacing.sm,
    ),
    child: Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Text(
            dayLabel(day, ref.watch(todayProvider)).toUpperCase(),
            style: context.tokens.smallCaps,
          ),
        ),
        const Expanded(child: Divider()),
      ],
    ),
  );
}

/// Marks where the messages the reader hasn't seen begin.
class NewMessagesTile extends StatelessWidget {
  const NewMessagesTile({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.xs,
      ),
      child: Row(
        children: [
          Expanded(child: Divider(color: color)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
            child: Text(
              'New messages',
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: color),
            ),
          ),
          Expanded(child: Divider(color: color)),
        ],
      ),
    );
  }
}

/// A row that arrived while the reader watched: it opens up and fades in
/// once.
class AppearOnce extends StatefulWidget {
  const AppearOnce({required this.animate, required this.child, super.key});

  final bool animate;
  final Widget child;

  @override
  State<AppearOnce> createState() => _AppearOnceState();
}

class _AppearOnceState extends State<AppearOnce>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: widget.animate ? 0 : 1,
  );
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.forward();
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizeTransition(
    sizeFactor: _curve,
    alignment: AlignmentDirectional.topStart,
    child: FadeTransition(opacity: _curve, child: widget.child),
  );
}
