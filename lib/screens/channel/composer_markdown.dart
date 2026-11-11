import 'package:flutter/services.dart';

/// Markdown help while typing in the composer: continued lists, wrapped
/// selections and pasted spreadsheet tables.
class ComposerMarkdown extends TextInputFormatter {
  const ComposerMarkdown();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.composing.isValid) return newValue;
    return wrapSelection(oldValue, newValue) ??
        continueList(oldValue, newValue) ??
        pasteTable(oldValue, newValue) ??
        newValue;
  }
}

final _item = RegExp(r'^(\s*)([-*+] \[[ xX]\] |[-*+] |\d+[.)] |> )(.*)$');
const _wrappers = {
  '*': '*',
  '_': '_',
  '`': '`',
  '~': '~',
  '(': ')',
  '[': ']',
  '"': '"',
};

/// Whether [offset] is inside an open ``` block.
bool insideFence(String text, int offset) => RegExp(
  r'^\s*```',
  multiLine: true,
).allMatches(text.substring(0, offset)).length.isOdd;

/// The text typed or pasted at the old selection: [next] minus what stayed
/// around it, or null when something else changed.
String? _inserted(TextEditingValue old, TextEditingValue next) {
  final selection = old.selection;
  if (!selection.isValid) return null;
  final before = selection.textBefore(old.text);
  final after = selection.textAfter(old.text);
  final text = next.text;
  if (text.length < before.length + after.length ||
      !text.startsWith(before) ||
      !text.endsWith(after)) {
    return null;
  }
  return text.substring(before.length, text.length - after.length);
}

/// Typing a marker or an opening bracket over a selection wraps it and keeps
/// the inner text selected.
TextEditingValue? wrapSelection(TextEditingValue old, TextEditingValue next) {
  final selection = old.selection;
  if (!selection.isValid ||
      selection.isCollapsed ||
      insideFence(old.text, selection.start)) {
    return null;
  }
  final typed = _inserted(old, next);
  final close = typed == null ? null : _wrappers[typed];
  if (close == null) return null;
  final inner = selection.textInside(old.text);
  final start = selection.start + 1;
  return TextEditingValue(
    text:
        '${selection.textBefore(old.text)}$typed$inner$close'
        '${selection.textAfter(old.text)}',
    selection: TextSelection(
      baseOffset: start,
      extentOffset: start + inner.length,
    ),
  );
}

/// A new line after a list item starts the next item; on an empty item it
/// ends the list.
TextEditingValue? continueList(TextEditingValue old, TextEditingValue next) {
  final selection = old.selection;
  if (!selection.isValid ||
      !selection.isCollapsed ||
      _inserted(old, next) != '\n' ||
      insideFence(old.text, selection.start)) {
    return null;
  }
  final at = selection.start;
  final lineStart = _lineStart(old.text, at);
  final match = _item.firstMatch(old.text.substring(lineStart, at));
  if (match == null) return null;
  final prefix = match[2]!;
  if (match[3]!.isEmpty) {
    return TextEditingValue(
      text: old.text.replaceRange(lineStart, at, ''),
      selection: TextSelection.collapsed(offset: lineStart),
    );
  }
  final number = RegExp(r'^(\d+)([.)] )$').firstMatch(prefix);
  final following = number != null
      ? '${int.parse(number[1]!) + 1}${number[2]}'
      : prefix.contains('[')
      ? '${prefix.substring(0, prefix.indexOf('['))}[ ] '
      : prefix;
  final insert = '\n${match[1]}$following';
  return TextEditingValue(
    text: old.text.replaceRange(at, at, insert),
    selection: TextSelection.collapsed(offset: at + insert.length),
  );
}

/// Tab-separated rows pasted from a spreadsheet become a markdown table with
/// the first row as header.
TextEditingValue? pasteTable(TextEditingValue old, TextEditingValue next) {
  final selection = old.selection;
  final pasted = _inserted(old, next);
  if (!selection.isValid ||
      pasted == null ||
      !pasted.contains('\t') ||
      insideFence(old.text, selection.start)) {
    return null;
  }
  final rows = pasted
      .split(RegExp(r'\r?\n'))
      .map((row) => row.split('\t'))
      .toList();
  if (rows.length > 1 && rows.last.length == 1 && rows.last.first.isEmpty) {
    rows.removeLast();
  }
  final width = rows.first.length;
  if (rows.length < 2 || rows.any((row) => row.length != width)) return null;
  String line(List<String> cells) =>
      '| ${cells.map((c) => c.trim().replaceAll('|', r'\|')).join(' | ')} |';
  final table = [
    line(rows.first),
    line(List.filled(width, '---')),
    for (final row in rows.skip(1)) line(row),
  ].join('\n');
  final before = selection.textBefore(old.text);
  final lead = before.isEmpty || before.endsWith('\n') ? '' : '\n';
  return TextEditingValue(
    text: '$before$lead$table${selection.textAfter(old.text)}',
    selection: TextSelection.collapsed(
      offset: before.length + lead.length + table.length,
    ),
  );
}

/// The lines the selection touches when each is a list item, else null.
({int start, int end, List<String> lines})? _listLines(TextEditingValue value) {
  final selection = value.selection;
  if (!selection.isValid) return null;
  final text = value.text;
  final start = _lineStart(text, selection.start);
  var end = text.indexOf('\n', selection.end);
  if (end < 0) end = text.length;
  final lines = text.substring(start, end).split('\n');
  if (lines.any((line) => !_item.hasMatch(line))) return null;
  return (start: start, end: end, lines: lines);
}

/// Whether the caret line, or every selected line, is a list item.
bool onListItems(TextEditingValue value) => _listLines(value) != null;

/// Indents the list items under the selection by their marker's width, or
/// takes that much leading space off; null when they are not all list items.
TextEditingValue? indentListItems(
  TextEditingValue value, {
  bool outdent = false,
}) {
  final found = _listLines(value);
  if (found == null) return null;
  final shifts = <int>[];
  final out = <String>[];
  for (final line in found.lines) {
    final unit = _item.firstMatch(line)![2]!.length;
    final spaces = line.length - line.trimLeft().length;
    final shift = outdent ? -spaces.clamp(0, unit) : unit;
    shifts.add(shift);
    out.add(shift < 0 ? line.substring(-shift) : '${' ' * shift}$line');
  }
  // An offset moves by the shifts of the lines before it and its own line's;
  // one inside removed space lands at the line's start.
  int moved(int offset) {
    var at = found.start;
    var before = 0;
    var result = offset;
    for (var i = 0; i < out.length; i++) {
      if (offset >= at) {
        result = shifts[i] < 0 && offset < at - shifts[i]
            ? at + before
            : offset + before + shifts[i];
      }
      before += shifts[i];
      at += found.lines[i].length + 1;
    }
    return result;
  }

  final selection = value.selection;
  return TextEditingValue(
    text: value.text.replaceRange(found.start, found.end, out.join('\n')),
    selection: TextSelection(
      baseOffset: moved(selection.baseOffset),
      extentOffset: moved(selection.extentOffset),
    ),
  );
}

int _lineStart(String text, int offset) =>
    offset == 0 ? 0 : text.lastIndexOf('\n', offset - 1) + 1;
