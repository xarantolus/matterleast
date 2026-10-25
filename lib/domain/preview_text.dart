final _image = RegExp(r'!\[([^\]]*)\]\([^)]*\)');
final _link = RegExp(r'\[([^\]]*)\]\([^)]*\)');
final _lineMarker = RegExp(r'^\s*(#{1,6}\s+|>\s?|[-*+]\s+(\[[ xX]\]\s+)?)');
final _emphasis = RegExp(r'(?<![\w@~])[*_]+|[*_]+(?![\w])|~~|`+');
final _space = RegExp(r'\s+');

/// One line of plain text from a message's markdown, for previews: heading,
/// quote and list markers, emphasis and code ticks go, links and images
/// leave their text, and `@user`, `~channel` and words with underscores
/// stay as written.
String previewText(String markdown) {
  final lines = markdown
      .split('\n')
      .where((line) => !line.trimLeft().startsWith('```'))
      .map((line) => line.replaceFirst(_lineMarker, ''));
  return lines
      .join(' ')
      .replaceAllMapped(_image, (m) => m[1]!)
      .replaceAllMapped(_link, (m) => m[1]!)
      .replaceAll(_emphasis, '')
      .replaceAll(_space, ' ')
      .trim();
}
