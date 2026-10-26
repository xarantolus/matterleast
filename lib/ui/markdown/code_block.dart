import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/markdown/code_highlight.dart';
import 'package:matterleast/ui/message_display.dart';
import 'package:matterleast/ui/tokens.dart';

const _previewLines = 4;

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
/// tap shows all of it.
class CodePreview extends StatefulWidget {
  const CodePreview({required this.code, required this.language, super.key});

  final String code;
  final String language;

  @override
  State<CodePreview> createState() => _CodePreviewState();
}

class _CodePreviewState extends State<CodePreview> {
  /// The reader's choice for this block; null follows the setting.
  bool? _wrap;

  @override
  Widget build(BuildContext context) {
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
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
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
}) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => CodeScreen(code: code, language: language, wrap: wrap),
  ),
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
    return Scaffold(
      appBar: AppBar(
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
      ),
      backgroundColor: tokens.codeBackground,
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
