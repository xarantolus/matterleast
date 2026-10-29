import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/screens/open_page.dart';
import 'package:matterleast/ui/anchored_list.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/context_menu.dart';
import 'package:matterleast/ui/density.dart';
import 'package:matterleast/ui/markdown/code_highlight.dart';
import 'package:matterleast/ui/markdown/show_more.dart';
import 'package:matterleast/ui/message_display.dart';
import 'package:matterleast/ui/motion.dart';
import 'package:matterleast/ui/tokens.dart';

const _previewLines = 4;

const _desktopFullLines = 15;
const _desktopCutLines = 10;

TextStyle _codeStyle(BuildContext context) =>
    (Theme.of(context).textTheme.bodySmall ?? const TextStyle())
        .copyWith(
          fontFamily: 'monospace',
          color: context.tokens.text,
          height: 1.4,
        )
        .forMessages(context, fallbackSize: 12);

TextSpan _coloured(BuildContext context, String code, String language) {
  final base = _codeStyle(context);
  return CodeHighlighter.instance.spans(
        code,
        language,
        base,
        Theme.of(context).brightness,
      ) ??
      TextSpan(text: code, style: base);
}

/// The first lines of a code block with its language and a wrap toggle;
/// tap shows all of it. Desktop uses [DesktopCodeBlock].
class CodePreview extends StatefulWidget {
  const CodePreview({
    required this.code,
    required this.language,
    this.id,
    super.key,
  });

  final String code;
  final String language;

  /// Key in [ShowMoreMemory] for the desktop expanded state.
  final String? id;

  @override
  State<CodePreview> createState() => _CodePreviewState();
}

class _CodePreviewState extends State<CodePreview> {
  /// The reader's choice for this block; null follows the setting.
  bool? _wrap;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return DesktopCodeBlock(
        code: widget.code,
        language: widget.language,
        id: widget.id,
      );
    }
    final tokens = context.tokens;
    final wrap = _wrap ?? MessageDisplay.of(context).wrapCode;
    final lines = widget.code.split('\n');
    final shown = lines.take(_previewLines).join('\n');
    final more = lines.length - _previewLines;
    final label = languageLabel(widget.language);
    final text = Text.rich(
      _coloured(context, shown, widget.language),
      softWrap: wrap,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Material(
        color: tokens.codeBackground,
        borderRadius: BorderRadius.circular(context.density.radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          mouseCursor: clickCursor,
          onTap: () =>
              openCode(context, widget.code, widget.language, wrap: wrap),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: Spacing.sm,
              top: Spacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: Spacing.sm),
                  child: wrap
                      ? text
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: text,
                        ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: more > 0
                          ? Text(
                              more == 1 ? '+1 more line' : '+$more more lines',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: tokens.accent),
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (label.isNotEmpty)
                      Flexible(
                        child: Text(
                          label,
                          style: tokens.smallCaps,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    WrapToggle(
                      wrap: wrap,
                      onChanged: (on) => setState(() => _wrap = on),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A code block that expands in place, with copy on hover. No per-block
/// wrap switch: wide windows rarely need it and Shift+wheel scrolls.
class DesktopCodeBlock extends StatefulWidget {
  const DesktopCodeBlock({
    required this.code,
    required this.language,
    this.id,
    super.key,
  });

  final String code;
  final String language;

  final String? id;

  @override
  State<DesktopCodeBlock> createState() => _DesktopCodeBlockState();
}

class _DesktopCodeBlockState extends State<DesktopCodeBlock> {
  // The list rebuilds rows when it moves its anchor.
  late var _expanded =
      widget.id != null &&
      (ShowMoreMemory.of(context)?.contains(widget.id) ?? false);
  var _hovered = false;
  var _focused = false;

  void _toggle() {
    final expand = !_expanded;
    AnchoredList.keepTopOf(context, unlessAbove: !expand);
    if (widget.id case final id?) {
      final memory = ShowMoreMemory.of(context);
      if (expand) {
        memory?.add(id);
      } else {
        memory?.remove(id);
      }
    }
    setState(() => _expanded = expand);
  }

  void _copy() {
    unawaited(Clipboard.setData(ClipboardData(text: widget.code)));
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(const SnackBar(content: Text('Code copied')));
  }

  void _open() => openCode(context, widget.code, widget.language);

  Future<void> _menu(Offset at) async {
    final run = await showMenuAt<VoidCallback>(context, at, [
      MenuItem(
        value: _copy,
        child: const MenuEntry(icon: Icons.copy, label: 'Copy code'),
      ),
      MenuItem(
        value: _open,
        child: const MenuEntry(
          icon: Icons.open_in_full,
          label: 'Open in full view',
        ),
      ),
    ]);
    if (mounted) run?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final wrap = MessageDisplay.of(context).wrapCode;
    final count = '\n'.allMatches(widget.code).length + 1;
    final long = count > _desktopFullLines;
    final cut = long && !_expanded;
    final label = languageLabel(widget.language);
    final text = Text.rich(
      _coloured(context, widget.code, widget.language),
      softWrap: wrap,
      maxLines: cut ? _desktopCutLines : null,
      overflow: TextOverflow.clip,
    );
    final tools = _hovered || _focused;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onSecondaryTapUp: (d) => _menu(d.globalPosition),
          child: Material(
            color: tokens.codeBackground,
            borderRadius: BorderRadius.circular(context.density.radius),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.md,
                    Spacing.sm,
                    Spacing.md,
                    Spacing.xs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AnimatedSize(
                        duration: motion(
                          context,
                          const Duration(milliseconds: 200),
                        ),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: wrap
                            ? text
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: text,
                              ),
                      ),
                      Row(
                        children: [
                          if (long)
                            Flexible(
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: tokens.accent,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: _toggle,
                                icon: Icon(
                                  _expanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                label: Text(
                                  _expanded
                                      ? 'Show less'
                                      : 'Show more · ${count - _desktopCutLines} '
                                            'more lines',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          const Spacer(),
                          if (label.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Spacing.xs,
                              ),
                              child: Text(label, style: tokens.smallCaps),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                PositionedDirectional(
                  top: Spacing.xs,
                  end: Spacing.xs,
                  child: Focus(
                    canRequestFocus: false,
                    skipTraversal: true,
                    onFocusChange: (on) => setState(() => _focused = on),
                    child: AnimatedOpacity(
                      opacity: tools ? 1 : 0,
                      duration: motion(
                        context,
                        const Duration(milliseconds: 120),
                      ),
                      child: Material(
                        color: tokens.codeBackground,
                        borderRadius: BorderRadius.circular(
                          context.density.radius,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Open in full view',
                              visualDensity: VisualDensity.compact,
                              iconSize: 18,
                              icon: const Icon(Icons.open_in_full),
                              onPressed: _open,
                            ),
                            IconButton(
                              tooltip: 'Copy code',
                              visualDensity: VisualDensity.compact,
                              iconSize: 18,
                              icon: const Icon(Icons.copy),
                              onPressed: _copy,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Switches a code block between wrapped lines and sideways scrolling.
class WrapToggle extends StatelessWidget {
  const WrapToggle({required this.wrap, required this.onChanged, super.key});

  final bool wrap;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: wrap ? "Don't wrap lines" : 'Wrap lines',
    isSelected: wrap,
    visualDensity: VisualDensity.compact,
    iconSize: 20,
    icon: const Icon(Icons.wrap_text),
    onPressed: () => onChanged(!wrap),
  );
}

void openCode(
  BuildContext context,
  String code,
  String language, {
  bool? wrap,
}) => openPage(
  Navigator.of(context),
  CodeScreen(code: code, language: language, wrap: wrap),
);

/// A whole code block: selectable, with line numbers unless wrapped, a
/// wrap toggle and a copy action.
class CodeScreen extends StatefulWidget {
  const CodeScreen({
    required this.code,
    required this.language,
    this.title,
    this.actions = const [],
    this.wrap,
    super.key,
  });

  final String code;
  final String language;

  /// Extra app bar actions, such as a file's menu.
  final List<Widget> actions;

  /// Shown instead of the language, such as a file's name.
  final String? title;

  /// Whether lines start wrapped; null follows the setting.
  final bool? wrap;

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  late bool? _wrap = widget.wrap;
  final _selection = FocusNode(debugLabel: 'Code');

  @override
  void initState() {
    super.initState();
    // Ctrl+A and Ctrl+C work at once, without a click into the text.
    if (isDesktop) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _selection.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final code = widget.code;
    final label = languageLabel(widget.language);
    final wrap = _wrap ?? MessageDisplay.of(context).wrapCode;
    // Wrapped lines would no longer line up with their numbers.
    final lines = wrap ? 1 : '\n'.allMatches(code).length + 1;
    final style = _codeStyle(context);
    final text = Text.rich(
      _coloured(context, code, widget.language),
      softWrap: wrap,
    );
    return ContentPage(
      title: Text(widget.title ?? (label.isEmpty ? 'Code' : '$label code')),
      actions: [
        WrapToggle(wrap: wrap, onChanged: (on) => setState(() => _wrap = on)),
        IconButton(
          tooltip: 'Copy code',
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: code));
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Code copied')));
          },
        ),
        ...widget.actions,
      ],
      // Plain text reads like any other page; code keeps its panel.
      backgroundColor: widget.language.isEmpty ? null : tokens.codeBackground,
      body: SafeArea(
        top: false,
        // The content is at least as large as the viewport, so a drag
        // anywhere on the screen scrolls, in both directions.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final page = SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  maxWidth: wrap ? constraints.maxWidth : double.infinity,
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: SelectionArea(
                    focusNode: _selection,
                    child: lines > 1
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SelectionContainer.disabled(
                                child: Text(
                                  [for (var i = 1; i <= lines; i++) '$i']
                                      .join('\n'),
                                  textAlign: TextAlign.end,
                                  style: style.copyWith(color: tokens.muted),
                                ),
                              ),
                              const SizedBox(width: Spacing.md),
                              text,
                            ],
                          )
                        : text,
                  ),
                ),
              ),
            );
            return wrap
                ? page
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: page,
                  );
          },
        ),
      ),
    );
  }
}
