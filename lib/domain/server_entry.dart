import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_entry.freezed.dart';

/// An added server as the screens see it.
@freezed
abstract class ServerEntry with _$ServerEntry {
  const factory ServerEntry({
    required String url,
    required String displayName,
    required String? siteName,
    required String? serverVersion,
    required String? diagnosticId,
    required DateTime? lastActiveAt,
    required String? ssoScheme,
  }) = _ServerEntry;

  const ServerEntry._();

  bool get signedIn => lastActiveAt != null;

  /// The address without the scheme, as people write it.
  String get address => url.replaceFirst(RegExp('^https?://'), '');
}

/// The signed-in user of a server, as far as the screens need it.
@freezed
abstract class Me with _$Me {
  const factory Me({
    required String id,
    required String username,
    required String firstName,
    required String lastName,
    required String nickname,

    /// `online`, `away`, `dnd` or `offline`.
    required String status,
    int? lastPictureUpdate,
  }) = _Me;

  const Me._();

  String get fullName => '$firstName $lastName'.trim();

  String get displayName => fullName.isNotEmpty ? fullName : username;
}

/// Up to two letters for an avatar or rail icon: the first letters of the
/// first two words, else the first two characters.
String initialsOf(String name) {
  final words = name
      .split(RegExp(r'[\s._-]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return '?';
  String first(String word, int count) =>
      String.fromCharCodes(word.runes.take(count));
  final letters = words.length == 1
      ? first(words.single, 2)
      : first(words[0], 1) + first(words[1], 1);
  return letters.toUpperCase();
}

/// Why [name] can't be the new name of the server at [url], or null when it
/// can: names tell signed-in servers apart in the rail and on Home.
String? renameProblem(
  String name, {
  required String url,
  required Iterable<ServerEntry> servers,
}) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'Enter a name.';
  final taken = servers.any(
    (s) => s.url != url && s.signedIn && s.displayName == trimmed,
  );
  return taken ? 'Another server already has this name.' : null;
}
