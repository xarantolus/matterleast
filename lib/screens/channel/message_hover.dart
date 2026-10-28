import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/screens/channel/message_menu.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/emoji_picker.dart';
import 'package:matterleast/ui/tokens.dart';

/// A message with a mouse: tinted while the pointer is over it, with a
/// small toolbar floating at its top right, and the message menu at the
/// pointer on a right click. Keyboard focus shows the toolbar too; Esc
/// leaves it. Hover and focus live here, so only this row rebuilds.
class MessageHover extends ConsumerStatefulWidget {
  const MessageHover({required this.target, required this.child, super.key});

  final MessageTarget target;
  final Widget child;

  @override
  ConsumerState<MessageHover> createState() => _MessageHoverState();
}

class _MessageHoverState extends ConsumerState<MessageHover> {
  final _toolbar = OverlayPortalController();
  final _focus = FocusNode(debugLabel: 'Message');
  final _toolbarFocus = FocusNode(
    debugLabel: 'Message toolbar',
    canRequestFocus: false,
    skipTraversal: true,
  );
  var _overRow = false;
  var _overToolbar = false;
  var _focused = false;

  bool get _hovered => _overRow || _overToolbar || _focused;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_focusChanged);
    _toolbarFocus.addListener(_focusChanged);
  }

  @override
  void dispose() {
    _focus.dispose();
    _toolbarFocus.dispose();
    super.dispose();
  }

  // Not the text selection inside the message, which a tap focuses.
  void _focusChanged() {
    final focused = _focus.hasPrimaryFocus || _toolbarFocus.hasFocus;
    if (focused != _focused) _pointer(focused: focused);
  }

  void _pointer({bool? row, bool? toolbar, bool? focused}) {
    final was = _hovered;
    _overRow = row ?? _overRow;
    _overToolbar = toolbar ?? _overToolbar;
    _focused = focused ?? _focused;
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

  /// Alt+click, as on the web: marks the message and what follows unread.
  Future<void> _markUnread() async {
    final target = widget.target;
    final facts = await ref.read(
      postMenuFactsProvider(target.url, target.post, target.teamId).future,
    );
    if (!mounted) return;
    final action = messageActions(
      target,
      facts,
    ).where((a) => a.kind == MessageActionKind.markUnread).firstOrNull;
    if (action != null) await action.run(context);
  }

  void _menuAt(Offset position) =>
      unawaited(showMessageContextMenu(context, widget.target, position));

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape) {
      return KeyEventResult.ignored;
    }
    final list = _focus.ancestors
        .where((n) => n.canRequestFocus && n is! FocusScopeNode)
        .firstOrNull;
    if (list != null) {
      list.requestFocus();
    } else {
      _focus.unfocus();
    }
    return KeyEventResult.handled;
  }

  // The toolbar floats above the message; reading order would put it first.
  @override
  Widget build(BuildContext context) => FocusTraversalGroup(
    policy: OrderedTraversalPolicy(),
    child: FocusTraversalOrder(
      order: const NumericFocusOrder(0),
      child: Focus(focusNode: _focus, onKeyEvent: _key, child: _row(context)),
    ),
  );

  Widget _row(BuildContext context) => OverlayPortal.overlayChildLayoutBuilder(
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
          child: Focus(
            focusNode: _toolbarFocus,
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(1),
              child: MessageToolbar(
                target: widget.target,
                onRun: _run,
                onMore: _menuAt,
              ),
            ),
          ),
        ),
      );
    },
    child: MouseRegion(
      onEnter: (_) => _pointer(row: true),
      onExit: (_) => _pointer(row: false),
      child: Listener(
        onPointerDown: (event) {
          if (event.buttons == kPrimaryButton &&
              HardwareKeyboard.instance.isAltPressed) {
            unawaited(_markUnread());
          }
        },
        child: GestureDetector(
          onSecondaryTapUp: (d) => _menuAt(d.globalPosition),
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              color: _hovered ? Theme.of(context).hoverColor : null,
            ),
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(2),
              child: widget.child,
            ),
          ),
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
              Builder(
                builder: (button) => IconButton(
                  visualDensity: density,
                  tooltip: react.label,
                  onPressed: () {
                    final anchor = globalRectOf(button);
                    onRun(
                      (context) =>
                          pickReaction(context, url, post, anchor: anchor),
                    );
                  },
                  icon: Icon(react.icon, size: 20),
                ),
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
