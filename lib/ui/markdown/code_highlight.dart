import 'package:material_ui/material_ui.dart';
import 'package:re_highlight/languages/all.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/styles/github-dark.dart';
import 'package:re_highlight/styles/github.dart';

/// Syntax colouring for code blocks, one language registered at a time as
/// messages ask for it. Results are kept per (code, language, brightness).
class CodeHighlighter {
  CodeHighlighter._();

  static final instance = CodeHighlighter._();

  final _highlight = Highlight();
  final _registered = <String>{};
  Map<String, String>? _aliases;
  final _cache = <(String, String, Brightness), TextSpan>{};

  static const _cacheSize = 200;
  static const _longestLine = 300;

  /// The highlight.js name for [language] (a name or alias), or null.
  String? languageFor(String language) {
    final lower = language.toLowerCase();
    if (lower.isEmpty) return null;
    if (builtinAllLanguages.containsKey(lower)) return lower;
    _aliases ??= {
      for (final MapEntry(:key, :value) in builtinAllLanguages.entries)
        for (final alias in value.aliases ?? const <String>[]) alias: key,
    };
    return _aliases![lower];
  }

  /// [code] as coloured spans on top of [base], or null when the language is
  /// unknown or a line is too long to be worth colouring.
  TextSpan? spans(
    String code,
    String language,
    TextStyle base,
    Brightness brightness,
  ) {
    final name = languageFor(language);
    if (name == null) return null;
    if (code.split('\n').any((l) => l.length > _longestLine)) return null;
    final key = (code, name, brightness);
    final hit = _cache.remove(key);
    if (hit != null) return _cache[key] = hit;
    if (_registered.add(name)) {
      _highlight.registerLanguage(name, builtinAllLanguages[name]!);
    }
    final renderer = TextSpanRenderer(
      base,
      brightness == Brightness.dark ? githubDarkTheme : githubTheme,
    );
    _highlight.highlight(code: code, language: name).render(renderer);
    final span = renderer.span;
    if (span == null) return null;
    _cache[key] = span;
    if (_cache.length > _cacheSize) _cache.remove(_cache.keys.first);
    return span;
  }
}

const _languageNames = {
  'bash': 'Bash',
  'c': 'C',
  'cpp': 'C++',
  'csharp': 'C#',
  'css': 'CSS',
  'dart': 'Dart',
  'diff': 'Diff',
  'go': 'Go',
  'java': 'Java',
  'javascript': 'JavaScript',
  'json': 'JSON',
  'kotlin': 'Kotlin',
  'latex': 'LaTeX',
  'markdown': 'Markdown',
  'objectivec': 'Objective-C',
  'php': 'PHP',
  'python': 'Python',
  'ruby': 'Ruby',
  'rust': 'Rust',
  'scss': 'SCSS',
  'shell': 'Shell',
  'sql': 'SQL',
  'swift': 'Swift',
  'typescript': 'TypeScript',
  'xml': 'XML',
  'yaml': 'YAML',
};

/// The name shown on a code block's badge.
String languageLabel(String language) {
  final name = CodeHighlighter.instance.languageFor(language) ?? language;
  return _languageNames[name] ??
      (name.isEmpty ? '' : name[0].toUpperCase() + name.substring(1));
}
