import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/domain/time_labels.dart';

part 'message_search.freezed.dart';

/// The tabs of the search results.
enum SearchTab { messages, files }

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
    FileFilter? fileFilter,
  }) = _SearchScope;
}

/// The file types the Files results can be narrowed to, with the
/// extensions the official app searches for each.
enum FileFilter {
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

  const FileFilter(this.label, this.extensions);

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
    int? width,
    int? height,
    @Default(false) bool hasPreview,

    /// Who posted it.
    @Default('') String userId,

    /// A tiny JPEG to blur while the picture loads.
    Uint8List? miniPreview,
  }) = _FileHit;

  const FileHit._();

  PostFile get postFile => PostFile(
    id: id,
    name: name,
    extension: extension,
    mimeType: mimeType,
    size: size,
    width: width,
    height: height,
    hasPreview: hasPreview,
    miniPreview: miniPreview,
  );
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
/// [SearchScope.fileFilter].
String fileSearchTerms(String query, SearchScope scope) => [
  searchTerms(query, scope),
  for (final ext in scope.fileFilter?.extensions ?? const <String>[])
    'ext:$ext',
].where((part) => part.isNotEmpty).join(' ');

final _dayModifier = RegExp(r'\b(?:on|before|after):(\d{4})-(\d{2})-(\d{2})\b');

/// Pure: the UTC offset the server should read the date modifiers in
/// [terms] with, which is that of the first named day in local time (a day
/// across a clock change from [now] has another offset); [now]'s offset
/// when no day is named.
Duration searchTimeZoneOffset(String terms, {required DateTime now}) {
  final m = _dayModifier.firstMatch(terms);
  if (m == null) return now.timeZoneOffset;
  return DateTime(
    int.parse(m[1]!),
    int.parse(m[2]!),
    int.parse(m[3]!),
  ).timeZoneOffset;
}

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
  const SearchShown(
    this.results, {
    required this.refreshing,
    this.notice,
    this.more = const [],
    this.failures = const [],
  });

  final List<T> results;

  /// What the server found beyond the stored [results], shown below them
  /// so the rows already on screen stay where they are.
  final List<T> more;

  /// The server's answer is still coming.
  final bool refreshing;

  /// Why only stored results show, when the server could not be asked.
  final String? notice;

  /// Servers that could not be searched, when several are.
  final List<({String name, String cause})> failures;
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

/// Pure: stored matches show at once; the server's answer adds what they
/// lack below them, so nothing the reader sees moves; a failed server
/// keeps the stored ones. [keyOf] tells which results are the same.
SearchView<T> searchView<T>({
  required List<T>? local,
  required List<T>? server,
  required bool serverLoading,
  String? serverError,
  Object? Function(T)? keyOf,
}) {
  SearchShown<T> merged(List<T> server, {required bool refreshing}) {
    if (local == null || local.isEmpty) {
      return SearchShown(server, refreshing: refreshing);
    }
    final key = keyOf ?? (T item) => item;
    final stored = {for (final item in local) key(item)};
    return SearchShown(
      local,
      refreshing: refreshing,
      more: [
        for (final item in server)
          if (!stored.contains(key(item))) item,
      ],
    );
  }

  if (server != null && !serverLoading) {
    return server.isEmpty && !(local?.isNotEmpty ?? false)
        ? const SearchEmpty()
        : merged(server, refreshing: false);
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
  if (server != null && server.isNotEmpty) {
    return merged(server, refreshing: true);
  }
  if (local == null || local.isEmpty) return const SearchLoading();
  return SearchShown(local, refreshing: true);
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

/// One search request: a server and the scope resolved for it, whose team
/// is the one searched unless [SearchScope.allTeams].
typedef SearchRequest = ({String url, SearchScope scope});

/// What a server offers a search.
typedef SearchServer = ({String url, bool crossTeam, String? homeTeam});

/// Pure: the requests for [scope]. [server] narrows to one server (null
/// searches all); a server that can't search every team falls back to the
/// scope's team on the server it was named for, else to its [homeTeam],
/// and is left out when it has neither.
List<SearchRequest> searchRequests(
  List<SearchServer> servers,
  SearchScope scope, {
  String? server,
}) => [
  for (final s in servers)
    if (server == null || s.url == server)
      if (_resolved(s, scope, named: server != null) case final resolved?)
        (url: s.url, scope: resolved),
];

SearchScope? _resolved(
  SearchServer s,
  SearchScope scope, {
  required bool named,
}) {
  if (scope.allTeams && s.crossTeam) {
    return scope.copyWith(teamId: s.homeTeam ?? scope.teamId);
  }
  final team = named && scope.teamId.isNotEmpty ? scope.teamId : s.homeTeam;
  return team == null ? null : scope.copyWith(teamId: team, allTeams: false);
}

/// Pure: [lists] as one, newest first; equal times keep the earlier list
/// first, then each list's own order.
List<T> mergeNewestFirst<T>(List<List<T>> lists, DateTime? Function(T) timeOf) {
  final all = [
    for (final (l, list) in lists.indexed)
      for (final (i, item) in list.indexed) (item, l, i),
  ];
  final epoch = DateTime.fromMillisecondsSinceEpoch(0);
  all.sort((a, b) {
    final byTime = (timeOf(b.$1) ?? epoch).compareTo(timeOf(a.$1) ?? epoch);
    if (byTime != 0) return byTime;
    final byList = a.$2.compareTo(b.$2);
    return byList != 0 ? byList : a.$3.compareTo(b.$3);
  });
  return [for (final e in all) e.$1];
}

/// Pure: the servers in the order their results first showed, in groups
/// that appeared together. [ready] are the servers with results now; the
/// ones not seen before join as a new last group, so rows already on screen
/// keep their place.
List<List<String>> arrivalGroups(
  List<List<String>> shown,
  Iterable<String> ready,
) {
  final seen = {for (final group in shown) ...group};
  final fresh = [
    for (final url in ready)
      if (!seen.contains(url)) url,
  ];
  return fresh.isEmpty ? shown : [...shown, fresh];
}

/// Pure: the views of several servers as one. Loading shows until some
/// result exists or every server has answered; a failed server is listed
/// in [SearchShown.failures] while the others' results show.
SearchView<T> mergeSearch<T>(
  List<({String name, SearchView<T> view})> sources,
) {
  final results = <T>[];
  final more = <T>[];
  final failures = <({String name, String cause})>[];
  var loading = false;
  for (final (:name, :view) in sources) {
    switch (view) {
      case SearchLoading():
        loading = true;
      case SearchEmpty():
        break;
      case SearchFailed(:final cause):
        failures.add((name: name, cause: cause));
      case SearchShown(
        results: final r,
        more: final m,
        :final refreshing,
        :final notice,
      ):
        results.addAll(r);
        more.addAll(m);
        loading |= refreshing;
        if (notice != null) failures.add((name: name, cause: notice));
    }
  }
  if (results.isEmpty && more.isEmpty) {
    if (loading) return const SearchLoading();
    return failures.isEmpty
        ? const SearchEmpty()
        : SearchFailed(failures.first.cause);
  }
  return SearchShown(
    results,
    more: more,
    refreshing: loading,
    failures: failures,
  );
}

/// The files of one date group: a day within the past week, else a month.
class FileGroup<T> {
  FileGroup(this.start, {required this.month});

  /// Local midnight of the day, or of the month's first day.
  final DateTime start;
  final bool month;

  /// Pictures and videos, for the grid.
  final media = <T>[];

  /// Everything else, listed after the grid.
  final others = <T>[];

  String label(DateTime now) =>
      month ? monthLabel(start, now) : dayLabel(start, now);
}

/// Pure: [items], newest first, in groups: a day each within the past
/// week of [now], a month each before it. An item without a time joins the
/// last group. Each group keeps the order of its items.
List<FileGroup<T>> groupFiles<T>(
  List<T> items, {
  required DateTime? Function(T) timeOf,
  required bool Function(T) isMedia,
  required DateTime now,
}) {
  final groups = <FileGroup<T>>[];
  for (final item in items) {
    final time = timeOf(item)?.toLocal();
    if (time != null) {
      final month = calendarDaysBetween(time, now) >= 7;
      final start = month
          ? DateTime(time.year, time.month)
          : DateTime(time.year, time.month, time.day);
      if (groups.isEmpty ||
          groups.last.start != start ||
          groups.last.month != month) {
        groups.add(FileGroup<T>(start, month: month));
      }
    } else if (groups.isEmpty) {
      groups.add(
        FileGroup<T>(DateTime.fromMillisecondsSinceEpoch(0), month: true),
      );
    }
    (isMedia(item) ? groups.last.media : groups.last.others).add(item);
  }
  return groups;
}

/// Pure: how many tiles of a media grid fit across [width], never fewer
/// than 3 (the smallest phone) and growing with the window.
int mediaColumns(double width) => (width / 130).floor().clamp(3, 12);

/// Pure: the type shown on a file's tile, such as `PDF`.
String fileTypeLabel(String extension) {
  final ext = extension.toUpperCase();
  if (ext.isEmpty) return 'FILE';
  return ext.length > 4 ? ext.substring(0, 4) : ext;
}

/// How many files one page of the server's file search holds.
const filePageSize = 60;

/// Pure: the hits of the next [page] that aren't [known] yet, and whether
/// another page may follow: only after a full page that brought something
/// new, since a server without paging answers the first page again.
({List<FileHit> fresh, bool more}) filePageAfter(
  Set<String> known,
  List<FileHit> page, {
  int size = filePageSize,
}) {
  final fresh = [
    for (final f in page)
      if (!known.contains(f.id)) f,
  ];
  return (fresh: fresh, more: page.length >= size && fresh.isNotEmpty);
}
