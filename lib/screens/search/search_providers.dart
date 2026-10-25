import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/message_search.dart';
import 'package:matterleast/data/actions/switch_search.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/views/search_views.dart';
import 'package:matterleast/data/views/switch_views.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/message_search.dart';
import 'package:matterleast/domain/quick_switch.dart';
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
