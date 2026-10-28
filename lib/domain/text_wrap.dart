import 'package:flutter/services.dart';

/// Pure: [value] with the selection wrapped in [marker], or unwrapped when
/// it already is, inside or just outside the selection. Without a selection
/// an empty pair is inserted and the cursor put between.
TextEditingValue toggleWrap(TextEditingValue value, String marker) {
  final text = value.text;
  final selection = _selection(value);
  final start = selection.start;
  final end = selection.end;
  final length = marker.length;
  if (selection.isCollapsed) {
    return _with(
      text.replaceRange(start, end, '$marker$marker'),
      start + length,
      start + length,
    );
  }
  final before = text.substring(0, start);
  final inner = text.substring(start, end);
  final after = text.substring(end);
  if (before.endsWith(marker) && after.startsWith(marker)) {
    return _with(
      before.substring(0, before.length - length) +
          inner +
          after.substring(length),
      start - length,
      end - length,
    );
  }
  if (inner.length >= 2 * length &&
      inner.startsWith(marker) &&
      inner.endsWith(marker)) {
    return _with(
      before + inner.substring(length, inner.length - length) + after,
      start,
      end - 2 * length,
    );
  }
  return _with(
    '$before$marker$inner$marker$after',
    start + length,
    end + length,
  );
}

/// Pure: [value] with the selection made the text of a link, `[text](url)`,
/// and "url" selected for typing over; without a selection the cursor sits
/// in the brackets.
TextEditingValue insertLink(TextEditingValue value) {
  final selection = _selection(value);
  final label = selection.textInside(value.text);
  final start = selection.start;
  const url = 'url';
  final text = value.text.replaceRange(start, selection.end, '[$label]($url)');
  if (selection.isCollapsed) return _with(text, start + 1, start + 1);
  final urlStart = start + label.length + 3;
  return _with(text, urlStart, urlStart + url.length);
}

TextSelection _selection(TextEditingValue value) {
  final s = value.selection;
  if (!s.isValid) return TextSelection.collapsed(offset: value.text.length);
  return TextSelection(
    baseOffset: s.start.clamp(0, value.text.length),
    extentOffset: s.end.clamp(0, value.text.length),
  );
}

TextEditingValue _with(String text, int base, int extent) => TextEditingValue(
  text: text,
  selection: TextSelection(baseOffset: base, extentOffset: extent),
);

/// Pure: the place in a history of [count] older messages after one step
/// from [at], older or newer; -1 is the text that was being typed.
int steppedHistory(int count, int at, {required bool older}) {
  if (count == 0) return -1;
  return (older ? at + 1 : at - 1).clamp(-1, count - 1);
}
