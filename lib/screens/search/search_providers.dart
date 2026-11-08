import 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/message_search.dart';
import 'package:matterleast/data/actions/switch_search.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/views/search_views.dart';
import 'package:matterleast/data/views/switch_views.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/message_search.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_providers.g.dart';

/// A failed search is retried by the user (pull or Retry), not on its own.
Duration? noRetry(int retryCount, Object error) => null;

/// One server's channels, conversations and people for the quick switcher.
@riverpod
Stream<List<SwitchItem>> switchItems(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* SwitchViews(session.db, serverUrl: url).items();
}

/// What one server knows about [term] beyond what is stored.
@Riverpod(retry: noRetry)
Future<List<SwitchItem>> switchRemote(Ref ref, String url, String term) async {
  final session = await ref.watch(serverSessionProvider(url).future);
  return SwitchSearch(session, serverUrl: url).search(term);
}

/// The team the user is in on [url], as the server's sync last stored it.
@riverpod
Future<String?> currentTeam(Ref ref, String url) async {
  final session = await ref.watch(serverSessionProvider(url).future);
  return session.db.syncText(SyncKeys.currentTeamId);
}

/// The servers and teams a search in [scope] asks, narrowed to [server]
/// when given.
@riverpod
Future<List<SearchRequest>> searchPlan(
  Ref ref,
  String? server,
  SearchScope scope,
) async {
  final servers = await ref.watch(serversProvider.future);
  return searchRequests(
    [
      for (final s in servers)
        if (s.signedIn)
          (
            url: s.url,
            crossTeam: (await ref.watch(featuresProvider(s.url).future))
                .crossTeamSearch,
            homeTeam: await ref.watch(currentTeamProvider(s.url).future),
          ),
    ],
    scope,
    server: server,
  );
}

@riverpod
Future<MessageSearch> messageSearch(Ref ref, String url) async {
  final session = await ref.watch(serverSessionProvider(url).future);
  return MessageSearch(session, SearchViews(session.db, serverUrl: url));
}

@riverpod
Stream<List<String>> recentSearches(Ref ref, String url, String teamId) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* SearchViews(session.db, serverUrl: url).recentSearches(teamId);
}

/// Stored posts matching [query] in [scope], at once and without a server.
@riverpod
Future<List<String>> localPostResults(
  Ref ref,
  String url,
  SearchScope scope,
  String query,
) async {
  final session = await ref.watch(serverSessionProvider(url).future);
  return SearchViews(
    session.db,
    serverUrl: url,
  ).localPostIds(scope, localWords(query));
}

@Riverpod(retry: noRetry)
Future<List<String>> serverPostResults(
  Ref ref,
  String url,
  SearchScope scope,
  String query,
) async {
  final search = await ref.watch(messageSearchProvider(url).future);
  return search.posts(
    scope.allTeams ? null : scope.teamId,
    searchTerms(query, scope),
  );
}

@riverpod
Future<List<FileHit>> localFileResults(
  Ref ref,
  String url,
  SearchScope scope,
  String query,
) async {
  final session = await ref.watch(serverSessionProvider(url).future);
  return SearchViews(
    session.db,
    serverUrl: url,
  ).localFiles(scope, localWords(query));
}

@Riverpod(retry: noRetry)
Future<List<FileHit>> serverFileResults(
  Ref ref,
  String url,
  SearchScope scope,
  String query,
) async {
  final search = await ref.watch(messageSearchProvider(url).future);
  return search.files(
    scope.allTeams ? null : scope.teamId,
    fileSearchTerms(query, scope),
  );
}

/// The pages after the first of one server's file search.
class MoreFilesState {
  const MoreFilesState({
    this.hits = const [],
    this.page = 0,
    this.done = true,
    this.loading = false,
    this.failure,
  });

  final List<FileHit> hits;

  /// The last page loaded; the first is 0.
  final int page;
  final bool done;
  final bool loading;

  /// What the server said when the last page failed.
  final String? failure;

  MoreFilesState copyWith({
    List<FileHit>? hits,
    int? page,
    bool? done,
    bool? loading,
    String? failure,
  }) => MoreFilesState(
    hits: hits ?? this.hits,
    page: page ?? this.page,
    done: done ?? this.done,
    loading: loading ?? this.loading,
    failure: failure,
  );
}

/// Loads the file search's later pages one at a time, as the reader gets to
/// the end of what is shown. Starts over when the first page is fetched
/// again.
@riverpod
class MoreFiles extends _$MoreFiles {
  @override
  MoreFilesState build(String url, SearchScope scope, String query) {
    final first = ref.watch(serverFileResultsProvider(url, scope, query)).value;
    return MoreFilesState(done: first == null || first.length < filePageSize);
  }

  Future<void> loadNext() async {
    if (state.done || state.loading) return;
    final shown = state;
    state = shown.copyWith(loading: true);
    try {
      final first =
          ref.read(serverFileResultsProvider(url, scope, query)).value ??
          const <FileHit>[];
      final search = await ref.read(messageSearchProvider(url).future);
      final page = await search.files(
        scope.allTeams ? null : scope.teamId,
        fileSearchTerms(query, scope),
        page: shown.page + 1,
      );
      if (!ref.mounted) return;
      final next = filePageAfter({
        for (final f in [...first, ...shown.hits]) f.id,
      }, page);
      state = MoreFilesState(
        hits: [...shown.hits, ...next.fresh],
        page: shown.page + 1,
        done: !next.more,
      );
    } on Object catch (e) {
      if (!ref.mounted) return;
      state = shown.copyWith(failure: requestProblemText(e, hostOf(url)));
    }
  }
}

/// Message previews of the posts [ids] (comma-separated), in that order.
@riverpod
Stream<List<InboxItem>> searchPostItems(
  Ref ref,
  String url,
  String ids,
) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* SearchViews(
    session.db,
    serverUrl: url,
  ).postItems(ids.isEmpty ? const [] : ids.split(','));
}

/// Who sent a file, for its row.
@riverpod
Stream<({String name, int? picture})?> fileSender(
  Ref ref,
  String url,
  String userId,
) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* SearchViews(session.db, serverUrl: url).sender(userId);
}

/// The web link of a message, null while its team isn't known.
@riverpod
Future<String?> postLink(
  Ref ref,
  String url,
  String channelId,
  String postId,
) async {
  final session = await ref.watch(serverSessionProvider(url).future);
  return SearchViews(session.db, serverUrl: url).postLink(channelId, postId);
}

/// The name of [userId] as the stored users give it, once; empty when
/// unknown.
Future<String> senderName(WidgetRef ref, String url, String userId) async {
  final session = await ref.read(serverSessionProvider(url).future);
  final sender = await SearchViews(
    session.db,
    serverUrl: url,
  ).sender(userId).first;
  return sender?.name ?? '';
}
