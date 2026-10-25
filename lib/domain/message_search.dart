import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_search.freezed.dart';

/// What a search is narrowed to, besides its words. Each part becomes one
/// of the server's search modifiers.
@freezed
abstract class SearchScope with _$SearchScope {
  const factory SearchScope({
    required String teamId,

    /// Searches every team the user is in; [teamId] stays the home of the
    /// recent searches.
    @Default(false) bool allTeams,

    /// `in:` takes the channel's name (or `@username` for a direct
    /// message); [channelLabel] is what the chip says.
    String? channelId,
    String? channelName,
    String? channelLabel,

    /// `from:` takes the username.
    String? userId,
    String? username,
    String? userLabel,
    DateTime? on,
    DateTime? before,
    DateTime? after,

    /// Files only: `ext:` for each of its extensions.
    FileKind? fileKind,
  }) = _SearchScope;
}

/// The file types the Files results can be narrowed to, with the
/// extensions the official app searches for each.
enum FileKind {
  documents('Documents', ['doc', 'docx', 'odt', 'pdf', 'txt', 'rtf']),
  spreadsheets('Spreadsheets', ['xls', 'xlsx', 'csv', 'ods']),
  presentations('Presentations', ['ppt', 'pptx', 'odp']),
  code('Code', [
    'c',
    'cc',
    'cpp',
    'cs',
    'css',
    'dart',
    'diff',
    'go',
    'h',
    'hpp',
    'html',
    'java',
    'js',
    'json',
    'jsx',
    'kt',
    'kts',
    'lua',
    'md',
    'php',
    'pl',
    'py',
    'rb',
    'rs',
    'scala',
    'scss',
    'sh',
    'sql',
    'swift',
    'ts',
    'xml',
    'yaml',
  ]),
  images('Images', [
    'jpg',
    'jpeg',
    'gif',
    'bmp',
    'png',
    'tiff',
    'tif',
    'svg',
    'psd',
    'xcf',
  ]),
  audio('Audio', ['mp3', 'wav', 'wma', 'm4a', 'flac', 'aac', 'ogg']),
  videos('Videos', [
    'mp4',
    'avi',
    'webm',
    'mkv',
    'wmv',
    'mpg',
    'mov',
    'flv',
    'ogm',
    'mpeg',
  ]);

  const FileKind(this.label, this.extensions);

  final String label;
  final List<String> extensions;
}

/// One file found by a search.
@freezed
abstract class FileHit with _$FileHit {
  const factory FileHit({
    required String id,
    required String name,
    required String extension,
    required String mimeType,
    required int size,
    required String postId,
    required String channelId,

    /// Where it was posted, such as `#town-square` or a person's name.
    required String place,
    DateTime? createAt,
  }) = _FileHit;
}

/// Pure: the terms sent to the server for [query] within [scope].
String searchTerms(String query, SearchScope scope) => [
  normalizeQuotes(query).trim(),
  if (scope.channelName case final name?) 'in:$name',
  if (scope.username case final name?) 'from:$name',
  if (scope.on case final day?) 'on:${dayTerm(day)}',
  if (scope.before case final day?) 'before:${dayTerm(day)}',
  if (scope.after case final day?) 'after:${dayTerm(day)}',
].where((part) => part.isNotEmpty).join(' ');

/// Pure: the terms sent to the server's file search, which also narrow by
/// [SearchScope.fileKind].
String fileSearchTerms(String query, SearchScope scope) => [
  searchTerms(query, scope),
  for (final ext in scope.fileKind?.extensions ?? const <String>[]) 'ext:$ext',
].where((part) => part.isNotEmpty).join(' ');

/// A calendar day as the server's date modifiers write it.
String dayTerm(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

/// Keyboards type curly quotes; the server only knows straight ones.
String normalizeQuotes(String text) =>
    text.replaceAll(RegExp('[“”„]'), '"').replaceAll(RegExp('[‘’]'), "'");

/// Pure: the plain words of [query] for searching what is stored: quoted
/// phrases stay whole, excluded words (`-word`) and modifiers are left out,
/// and a trailing `*` is dropped since every stored match is a prefix match.
List<String> localWords(String query) {
  final words = <String>[];
  final pattern = RegExp(r'"([^"]*)"|(\S+)');
  for (final match in pattern.allMatches(normalizeQuotes(query))) {
    final phrase = match[1];
    if (phrase != null) {
      if (phrase.trim().isNotEmpty) words.add(phrase.trim().toLowerCase());
      continue;
    }
    final word = match[2]!;
    if (word.startsWith('-') || RegExp(r'^[a-z]+:').hasMatch(word)) continue;
    final bare = word.replaceAll(RegExp(r'\*+$'), '').toLowerCase();
    if (bare.isNotEmpty) words.add(bare);
  }
  return words;
}

/// What the results show, from what was found locally and what the server
/// answered.
sealed class SearchView<T> {
  const SearchView();
}

/// Nothing to show yet; a spinner, never "no results".
class SearchLoading<T> extends SearchView<T> {
  const SearchLoading();
}

class SearchShown<T> extends SearchView<T> {
  const SearchShown(this.results, {required this.refreshing, this.notice});

  final List<T> results;

  /// The server's answer is still coming.
  final bool refreshing;

  /// Why only stored results show, when the server could not be asked.
  final String? notice;
}

/// Both looked and found nothing.
class SearchEmpty<T> extends SearchView<T> {
  const SearchEmpty();
}

/// The server failed and nothing stored matches.
class SearchFailed<T> extends SearchView<T> {
  const SearchFailed(this.cause);

  final String cause;
}

/// Pure: stored matches show at once; the server's answer replaces them
/// when it arrives; a failed server keeps the stored ones.
SearchView<T> searchView<T>({
  required List<T>? local,
  required List<T>? server,
  required bool serverLoading,
  String? serverError,
}) {
  if (server != null && !serverLoading) {
    return server.isEmpty
        ? (local?.isNotEmpty ?? false)
              ? SearchShown(local!, refreshing: false)
              : const SearchEmpty()
        : SearchShown(server, refreshing: false);
  }
  if (serverError != null && !serverLoading) {
    return (local?.isNotEmpty ?? false)
        ? SearchShown(
            local!,
            refreshing: false,
            notice: '$serverError Showing saved messages.',
          )
        : (local == null ? const SearchLoading() : SearchFailed(serverError));
  }
  final shown = server ?? local;
  if (shown == null || shown.isEmpty) return const SearchLoading();
  return SearchShown(shown, refreshing: true);
}

/// Pure: [items] with the day before each run of items from one local day,
/// as a [DateTime] at midnight; items without a time share the last day.
List<Object> withDays<T extends Object>(
  List<T> items,
  DateTime? Function(T) timeOf,
) {
  final rows = <Object>[];
  DateTime? current;
  for (final item in items) {
    final time = timeOf(item)?.toLocal();
    if (time != null) {
      final day = DateTime(time.year, time.month, time.day);
      if (day != current) {
        rows.add(day);
        current = day;
      }
    }
    rows.add(item);
  }
  return rows;
}
