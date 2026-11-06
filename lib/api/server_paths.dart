/// [segments] with `.` and `..` (also when they were percent-encoded)
/// applied, as the server and any proxy in front of it will.
List<String> _resolveDots(List<String> segments) {
  final result = <String>[];
  for (final s in segments) {
    if (s == '..') {
      if (result.isNotEmpty) result.removeLast();
    } else if (s != '.') {
      result.add(s);
    }
  }
  return result;
}

/// The segments of [url] below [server]'s own path, which may be a
/// sub-path; null when [url] is elsewhere.
List<String>? _below(Uri url, Uri server) {
  if (!url.isScheme('https') && !url.isScheme('http')) return null;
  if (url.origin != server.origin) return null;
  final base = server.pathSegments.where((s) => s.isNotEmpty).toList();
  final path = _resolveDots(url.pathSegments);
  if (path.length < base.length) return null;
  for (final (i, segment) in base.indexed) {
    if (path[i] != segment) return null;
  }
  return path.sublist(base.length);
}

/// The segments after `api/v4/` when [url] points at [server]'s API.
List<String>? apiSegments(Uri url, Uri server) {
  final rest = _below(url, server);
  if (rest == null || rest.length < 2) return null;
  return rest[0] == 'api' && rest[1] == 'v4' ? rest.sublist(2) : null;
}

/// Pure: whether a request to [url] may carry [server]'s session token:
/// only its REST API and its plugins' routes, never another app that
/// shares the host.
bool carriesToken(Uri url, Uri server) {
  if (apiSegments(url, server) != null) return true;
  final rest = _below(url, server);
  return rest != null && rest.length >= 2 && rest[0] == 'plugins';
}
