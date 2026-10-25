import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/tokens.dart';

const _avatarSize = 36.0;
const _gutter = _avatarSize + Spacing.md;

/// One message: avatar, name and time, then the text. A [compact] message
/// continues the one above it from the same person.
class PostTile extends StatelessWidget {
  const PostTile({
    required this.post,
    this.compact = false,
    this.highlighted = false,
    this.onOpenThread,
    super.key,
  });

  final PostItem post;
  final bool compact;
  final bool highlighted;

  /// Shows the "N replies" button on a first message of a thread.
  final VoidCallback? onOpenThread;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    if (post.isSystem && !post.deleted) return _SystemLine(post: post);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: post.authorName,
                  style: text.titleSmall?.copyWith(color: tokens.text),
                ),
                TextSpan(
                  text: '  ${_time(context, post.createAt)}',
                  style: text.bodySmall?.copyWith(color: tokens.muted),
                ),
              ],
            ),
          ),
        PostText(post: post),
        if (onOpenThread != null && !post.isReply && post.replyCount > 0)
          _RepliesButton(post: post, onPressed: onOpenThread!),
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
              InitialsBadge(
                name: post.authorName,
                size: _avatarSize,
                round: true,
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

/// The message text. Plain for now; formatted text replaces it.
class PostText extends StatelessWidget {
  const PostText({required this.post, super.key});

  final PostItem post;

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
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: post.message),
          if (post.edited)
            TextSpan(
              text: ' (edited)',
              style: style?.copyWith(color: tokens.muted, fontSize: 12),
            ),
        ],
      ),
      style: style?.copyWith(color: tokens.text),
    );
  }
}

String _time(BuildContext context, DateTime at) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(at.toLocal()),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

class _SystemLine extends StatelessWidget {
  const _SystemLine({required this.post});

  final PostItem post;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg + _gutter,
        Spacing.xs,
        Spacing.lg,
        Spacing.xs,
      ),
      child: Text(
        '${post.message}  ${_time(context, post.createAt)}',
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: tokens.muted),
      ),
    );
  }
}

class _RepliesButton extends StatelessWidget {
  const _RepliesButton({required this.post, required this.onPressed});

  final PostItem post;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final people = post.participants.take(3).toList();
    final count = post.replyCount;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
          visualDensity: VisualDensity.compact,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final name in people)
              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: InitialsBadge(name: name, size: 22, round: true),
              ),
            if (people.isNotEmpty) const SizedBox(width: Spacing.xs),
            Text(count == 1 ? '1 reply' : '$count replies'),
          ],
        ),
      ),
    );
  }
}

/// "Today", "Yesterday" or the date, between days.
class DaySeparatorTile extends StatelessWidget {
  const DaySeparatorTile({required this.day, super.key});

  final DateTime day;

  @override
  Widget build(BuildContext context) => Padding(
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
            dayLabel(day, DateTime.now()).toUpperCase(),
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
