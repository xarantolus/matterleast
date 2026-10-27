import 'package:matterleast/data/emoji/emoji.dart';

final _image = RegExp(r'!\[([^\]]*)\]\([^)]*\)');
final _link = RegExp(r'\[([^\]]*)\]\([^)]*\)');
final _lineMarker = RegExp(r'^\s*(#{1,6}\s+|>\s?|[-*+]\s+(\[[ xX]\]\s+)?)');
final _emphasis = RegExp(r'(?<![\w@~])[*_]+|[*_]+(?![\w])|~~|`+');
final _space = RegExp(r'\s+');
final _shortcode = RegExp(r':([a-zA-Z0-9_+-]+):');

/// One line of plain text from a message's markdown, for previews: heading,
/// quote and list markers, emphasis and code ticks go, links and images
/// leave their text, known `:emoji:` become the emoji, and `@user`,
/// `~channel` and words with underscores stay as written.
String previewText(String markdown) {
  final lines = markdown
      .split('\n')
      .where((line) => !line.trimLeft().startsWith('```'))
      .map((line) => line.replaceFirst(_lineMarker, ''));
  return lines
      .join(' ')
      .replaceAllMapped(_image, (m) => m[1]!)
      .replaceAllMapped(_link, (m) => m[1]!)
      .replaceAllMapped(_shortcode, (m) => unicodeForName(m[1]!) ?? m[0]!)
      .replaceAll(_emphasis, '')
      .replaceAll(_space, ' ')
      .trim();
}
