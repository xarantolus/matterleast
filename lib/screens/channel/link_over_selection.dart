import 'package:flutter/services.dart';

/// Turns a URL pasted over selected text into a markdown link.
class LinkOverSelection extends TextInputFormatter {
  const LinkOverSelection();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => linkOverSelection(oldValue, newValue) ?? newValue;
}

TextEditingValue? linkOverSelection(
  TextEditingValue old,
  TextEditingValue next,
) {
  final selection = old.selection;
  if (!selection.isValid || selection.isCollapsed || next.composing.isValid) {
    return null;
  }
  final before = selection.textBefore(old.text);
  final after = selection.textAfter(old.text);
  final text = next.text;
  if (text.length <= before.length + after.length ||
      !text.startsWith(before) ||
      !text.endsWith(after)) {
    return null;
  }
  final selected = selection.textInside(old.text);
  if (selected.contains('\n')) return null;
  final url = text.substring(before.length, text.length - after.length).trim();
  final uri = Uri.tryParse(url);
  if (uri == null ||
      url.contains(RegExp(r'\s')) ||
      !(uri.scheme == 'http' || uri.scheme == 'https') ||
      uri.host.isEmpty) {
    return null;
  }
  final link = '[$selected]($url)';
  return TextEditingValue(
    text: '$before$link$after',
    selection: TextSelection.collapsed(offset: before.length + link.length),
  );
}
