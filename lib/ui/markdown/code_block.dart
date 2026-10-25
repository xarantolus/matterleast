import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/markdown/code_highlight.dart';
import 'package:matterleast/ui/tokens.dart';

const _previewLines = 4;

TextStyle _codeStyle(BuildContext context) =>
    (Theme.of(context).textTheme.bodySmall ?? const TextStyle()).copyWith(
      fontFamily: 'monospace',
      color: context.tokens.text,
      height: 1.4,
    );

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

/// The first lines of a code block with its language; tap shows all of it.
class CodePreview extends StatelessWidget {
  const CodePreview({required this.code, required this.language, super.key});

  final String code;
  final String language;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final lines = code.split('\n');
    final shown = lines.take(_previewLines).join('\n');
    final more = lines.length - _previewLines;
    final label = languageLabel(language);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Material(
        color: tokens.codeBackground,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openCode(context, code, language),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text.rich(
                    _coloured(context, shown, language),
                    softWrap: false,
                  ),
                ),
                if (more > 0 || label.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.xs),
                    child: Row(
                      children: [
                        if (more > 0)
                          Expanded(
                            child: Text(
                              more == 1 ? '+1 more line' : '+$more more lines',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: tokens.accent),
                            ),
                          )
                        else
                          const Spacer(),
                        if (label.isNotEmpty)
                          Text(label, style: tokens.smallCaps),
                      ],
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

void openCode(BuildContext context, String code, String language) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CodeScreen(code: code, language: language),
      ),
    );

/// A whole code block: selectable, with line numbers, and a copy action.
class CodeScreen extends StatelessWidget {
  const CodeScreen({
    required this.code,
    required this.language,
    this.title,
    this.actions = const [],
    super.key,
  });

  final String code;
  final String language;

  /// Extra app bar actions, such as a file's menu.
  final List<Widget> actions;

  /// Shown instead of the language, such as a file's name.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final label = languageLabel(language);
    final lines = code.split('\n').length;
    final style = _codeStyle(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? (label.isEmpty ? 'Code' : '$label code')),
        actions: [
          IconButton(
            tooltip: 'Copy code',
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Code copied')));
            },
          ),
          ...actions,
        ],
      ),
      backgroundColor: tokens.codeBackground,
      body: SafeArea(
        top: false,
        // The content is at least as large as the viewport, so a drag
        // anywhere on the screen scrolls, in both directions.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: SelectionArea(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (lines > 1)
                          SelectionContainer.disabled(
                            child: Text(
                              [for (var i = 1; i <= lines; i++) '$i']
                                  .join('\n'),
                              textAlign: TextAlign.end,
                              style: style.copyWith(color: tokens.muted),
                            ),
                          ),
                        if (lines > 1) const SizedBox(width: Spacing.md),
                        Text.rich(
                          _coloured(context, code, language),
                          softWrap: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
