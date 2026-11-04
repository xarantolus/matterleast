/// Pure: Slack's `mrkdwn` as Mattermost markdown. Code keeps its markup;
/// elsewhere `*bold*`, `~strike~`, `<url|label>`, `<url>`, `<@id|name>`,
/// `<#id|name>`, `<!here>` and the `&amp; &lt; &gt;` escapes are converted
/// (`_italic_` reads the same in both).
String slackMrkdwnToMarkdown(String text) {
  final out = StringBuffer();
  var last = 0;
  for (final m in _code.allMatches(text)) {
    out
      ..write(_prose(text.substring(last, m.start)))
      ..write(_unescape(m[0]!));
    last = m.end;
  }
  out.write(_prose(text.substring(last)));
  return out.toString();
}

final _code = RegExp(r'```[\s\S]*?```|`[^`\n]+`');
final _angle = RegExp(r'<([^<>\s|][^<>|]*)(?:\|([^<>]*))?>');
final _bold = RegExp(r'(?<![*\w])\*(?![*\s])([^*\n]+?)(?<![*\s])\*(?![*\w])');
final _strike = RegExp(r'(?<![~\w])~(?![~\s])([^~\n]+?)(?<![~\s])~(?![~\w])');

String _prose(String text) => _unescape(
  text
      .replaceAllMapped(_angle, _angleLink)
      .replaceAllMapped(_bold, (m) => '**${m[1]}**')
      .replaceAllMapped(_strike, (m) => '~~${m[1]}~~'),
);

String _angleLink(Match m) {
  final target = m[1]!;
  final label = m[2];
  final named = label == null || label.isEmpty ? null : label;
  if (target.startsWith('@')) return '@${named ?? target.substring(1)}';
  if (target.startsWith('#')) return '~${named ?? target.substring(1)}';
  if (target.startsWith('!')) {
    return switch (target.substring(1)) {
      'here' => '@here',
      'channel' => '@channel',
      'everyone' => '@all',
      final other => named ?? other,
    };
  }
  if (!target.contains(':') && !target.contains('/')) return m[0]!;
  return named == null ? target : '[$named]($target)';
}

String _unescape(String text) => text
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&amp;', '&');
