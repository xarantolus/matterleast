/// What the user typed, made into the server's base URL. Without a scheme we
/// assume https; http is kept only when typed explicitly, and the caller
/// decides whether to allow it. A pasted channel or post link is cut back to
/// the server root.
Uri? normalizeServerUrl(String input) {
  var text = input.trim();
  if (text.isEmpty) return null;
  if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(text)) {
    text = 'https://$text';
  }
  final uri = Uri.tryParse(text);
  if (uri == null || uri.host.isEmpty) return null;
  if (uri.scheme != 'https' && uri.scheme != 'http') return null;

  var segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  final cut = segments.indexWhere(_looksLikeAppPath);
  if (cut >= 0) segments = segments.sublist(0, cut);
  // "/team/channels/x" is one segment past the root; "/pl/..." is deeper.
  if (segments.isNotEmpty && _isTeamPath(uri.pathSegments)) {
    segments = segments.sublist(0, segments.length - 1);
  }

  return Uri(
    scheme: uri.scheme.toLowerCase(),
    host: uri.host.toLowerCase(),
    port: uri.hasPort ? uri.port : null,
    path: segments.isEmpty ? '' : '/${segments.join('/')}',
  );
}

const _appPaths = {
  'channels',
  'messages',
  'pl',
  'threads',
  'login',
  'signup_user_complete',
  'api',
  'plugins',
  'boards',
  'playbooks',
  'admin_console',
};

bool _looksLikeAppPath(String segment) => _appPaths.contains(segment);

/// `/<team>/channels/...`: the team name sits before an app path.
bool _isTeamPath(List<String> segments) {
  final clean = segments.where((s) => s.isNotEmpty).toList();
  final cut = clean.indexWhere(_looksLikeAppPath);
  return cut >= 1 &&
      {'channels', 'messages', 'pl', 'threads'}.contains(clean[cut]);
}

/// Stable file name for a server's own database.
String serverDbFileName(Uri serverUrl) {
  final key = serverUrl.toString();
  var hash = 0x811c9dc5;
  for (final unit in key.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
  }
  final hex = hash.toRadixString(16).padLeft(8, '0');
  return 'server-$hex-${serverUrl.host.replaceAll(RegExp(r'[^a-z0-9]'), '_')}.sqlite';
}
