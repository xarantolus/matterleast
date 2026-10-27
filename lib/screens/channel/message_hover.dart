import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/screens/channel/message_menu.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/emoji_picker.dart';
import 'package:matterleast/ui/tokens.dart';

/// A message with a mouse: tinted while the pointer is over it, with a
/// small toolbar floating at its top right, and the message menu at the
/// pointer on a right click. The hover lives here, so only this row
/// rebuilds when it changes.
class MessageHover extends StatefulWidget {
  const MessageHover({required this.target, required this.child, super.key});

  final MessageTarget target;
  final Widget child;

  @override
  State<MessageHover> createState() => _MessageHoverState();
}

class _MessageHoverState extends State<MessageHover> {
  final _toolbar = OverlayPortalController();
  var _overRow = false;
  var _overToolbar = false;

  bool get _hovered => _overRow || _overToolbar;

  void _pointer({bool? row, bool? toolbar}) {
    final was = _hovered;
    _overRow = row ?? _overRow;
    _overToolbar = toolbar ?? _overToolbar;
    if (_hovered == was) return;
    // Leaving the row for the toolbar hides and shows it again before the
    // next frame, so it never flickers.
    if (_hovered) {
      _toolbar.show();
    } else {
      _toolbar.hide();
    }
    setState(() {});
  }

  /// Runs with this row's context, which outlives the toolbar.
  void _run(MessageRun run) => unawaited(run(context));

  void _menuAt(Offset position) =>
      unawaited(showMessageContextMenu(context, widget.target, position));

  @override
  Widget build(BuildContext context) => OverlayPortal.overlayChildLayoutBuilder(
    controller: _toolbar,
    overlayChildBuilder: (context, info) {
      final row = MatrixUtils.transformRect(
        info.childPaintTransform,
        Offset.zero & info.childSize,
      );
      // Half over the message above, like on the web, but never outside the
      // list.
      final top = math.max(0.0, row.top - _toolbarOverlap);
      return Positioned(
        top: top,
        right: info.overlaySize.width - row.right + Spacing.lg,
        child: MouseRegion(
          onEnter: (_) => _pointer(toolbar: true),
          onExit: (_) => _pointer(toolbar: false),
          child: MessageToolbar(
            target: widget.target,
            onRun: _run,
            onMore: _menuAt,
          ),
        ),
      );
    },
    child: MouseRegion(
      onEnter: (_) => _pointer(row: true),
      onExit: (_) => _pointer(row: false),
      child: GestureDetector(
        onSecondaryTapUp: (d) => _menuAt(d.globalPosition),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            color: _hovered ? Theme.of(context).hoverColor : null,
          ),
          child: widget.child,
        ),
      ),
    ),
  );
}

const _toolbarOverlap = 16.0;

/// Quick reaction, add reaction, reply and the full menu, taken from the
/// message's actions. [onRun] runs a pick where it outlives the toolbar;
/// [onMore] opens the menu at a global position.
class MessageToolbar extends ConsumerWidget {
  const MessageToolbar({
    required this.target,
    required this.onRun,
    required this.onMore,
    super.key,
  });

  final MessageTarget target;
  final ValueChanged<MessageRun> onRun;
  final ValueChanged<Offset> onMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = target.url;
    final post = target.post;
    final facts = ref
        .watch(postMenuFactsProvider(url, post, target.teamId))
        .value;
    final recent = ref.watch(recentEmojiProvider(url)).value ?? const [];
    final actions = facts == null
        ? const <MessageAction>[]
        : messageActions(target, facts);
    MessageAction? of(MessageActionKind kind) =>
        actions.where((a) => a.kind == kind).firstOrNull;
    final react = of(MessageActionKind.react);
    final reply = of(MessageActionKind.reply);
    final quick = quickReactions(recent, 1).first;
    const density = VisualDensity.compact;
    return Material(
      elevation: 2,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.sm),
        side: BorderSide(color: context.tokens.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (react != null) ...[
              IconButton(
                visualDensity: density,
                tooltip: ':$quick:',
                onPressed: () => onRun(
                  (context) => toggleReaction(context, url, post, quick),
                ),
                icon: EmojiGlyph(name: quick, size: 20, serverUrl: url),
              ),
              IconButton(
                visualDensity: density,
                tooltip: react.label,
                onPressed: () => onRun(react.run),
                icon: Icon(react.icon, size: 20),
              ),
            ],
            if (reply != null)
              IconButton(
                visualDensity: density,
                tooltip: reply.label,
                onPressed: () => onRun(reply.run),
                icon: Icon(reply.icon, size: 20),
              ),
            Builder(
              builder: (button) => IconButton(
                visualDensity: density,
                tooltip: 'More actions',
                onPressed: () {
                  final box = button.findRenderObject()! as RenderBox;
                  onMore(box.localToGlobal(box.size.bottomLeft(Offset.zero)));
                },
                icon: const Icon(Icons.more_horiz, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
