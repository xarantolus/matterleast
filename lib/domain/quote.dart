/// Pure: [message] as a markdown quote, then [permalink] on its own line
/// when there is one, ready for the reply to follow.
String quoteOf(String message, {String? permalink}) {
  final quoted = [
    for (final line in message.trimRight().split('\n'))
      line.isEmpty ? '>' : '> $line',
  ].join('\n');
  return permalink == null || permalink.isEmpty
      ? '$quoted\n\n'
      : '$quoted\n\n$permalink\n\n';
}

/// Pure: [draft] with [quote] added after it, a blank line apart.
String withQuote(String draft, String quote) {
  if (draft.trim().isEmpty) return quote;
  final gap = draft.endsWith('\n\n')
      ? ''
      : draft.endsWith('\n')
      ? '\n'
      : '\n\n';
  return '$draft$gap$quote';
}
