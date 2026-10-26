import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/views/search_views.dart';
import 'package:matterleast/domain/message_search.dart';
import 'package:matterleast/domain/server_features.dart';

/// Searches one server's messages and files. Found posts are stored with
/// the channels and people they need, and read back from the database.
class MessageSearch {
  MessageSearch(this.session, this.views, {DateTime Function()? clock})
    : _clock = clock ?? (() => DateTime.now().toUtc());

  final ServerSession session;
  final SearchViews views;
  final DateTime Function() _clock;

  ServerDatabase get _db => session.db;
  api.MattermostClient get _client => session.api.client;

  int get _offsetSeconds => DateTime.now().timeZoneOffset.inSeconds;

  /// Ids of the posts found, newest first. A null [teamId] searches every
  /// team.
  Future<List<String>> posts(String? teamId, String terms) =>
      session.api.coalesced('search:posts:$teamId:$terms', () async {
        final found = await session.api.call(
          () => teamId == null
              ? _client.posts.searchPostsInAllTeams(
                  body: api.ApiV4PostsSearchRequestBody(
                    terms: terms,
                    isOrSearch: false,
                    timeZoneOffset: _offsetSeconds,
                    includeDeletedChannels: true,
                  ),
                )
              : _client.posts.searchPosts(
                  teamId: teamId,
                  body: api.ApiV4TeamsTeamIdPostsSearchRequestBody(
                    terms: terms,
                    isOrSearch: false,
                    timeZoneOffset: _offsetSeconds,
                    includeDeletedChannels: true,
                  ),
                ),
        );
        final posts = (found.posts ?? const <String, api.Post>{}).values;
        await session.store.applySearchResults(
          posts,
          channels: await _missingChannels({
            for (final p in posts) ?p.channelId,
          }),
          users: await _missingUsers({for (final p in posts) ?p.userId}),
        );
        return found.order;
      });

  /// Files found on the server; none when it has no file search.
  Future<List<FileHit>> files(String? teamId, String terms) =>
      session.api.coalesced('search:files:$teamId:$terms', () async {
        if (!(await _db.features()).fileSearch) return const <FileHit>[];
        final api.FileInfoList found;
        try {
          found = await session.api.call(
            () => teamId == null
                ? _client.files.searchFilesAllTeams(
                    body: api.ApiV4FilesSearchRequestBody(
                      terms: terms,
                      isOrSearch: false,
                      timeZoneOffset: _offsetSeconds,
                      includeDeletedChannels: true,
                    ),
                  )
                : _client.teams.searchFiles(
                    teamId: teamId,
                    body: api.ApiV4TeamsTeamIdFilesSearchRequestBody(
                      terms: terms,
                      isOrSearch: false,
                      timeZoneOffset: _offsetSeconds,
                      includeDeletedChannels: true,
                    ),
                  ),
          );
        } on Object catch (e) {
          if (!endpointUnavailable(e)) rethrow;
          await session.store.turnOff(OptionalFeature.fileSearch);
          return const <FileHit>[];
        }
        final infos = [
          for (final id in found.order)
            if (found.fileInfos?[id] case final api.FileInfo f
                when f.id != null && f.deleteAt == null)
              f,
        ];
        final channelIds = {for (final f in infos) ?f.channelId};
        await session.store.applySearchResults(
          const [],
          channels: await _missingChannels(channelIds),
        );
        final places = await views.placesOf(channelIds);
        return [
          for (final f in infos)
            FileHit(
              id: f.id!,
              name: f.name ?? '',
              extension: f.extensionValue ?? '',
              mimeType: f.mimeType ?? '',
              size: f.size ?? 0,
              postId: f.postId ?? '',
              channelId: f.channelId ?? '',
              place: places[f.channelId] ?? '',
              createAt: f.createAt,
            ),
        ];
      });

  /// Remembers [term] among the team's recent searches.
  Future<void> remember(String teamId, String term) =>
      session.store.addRecentSearch(teamId, term.trim(), at: _clock());

  Future<void> forget(String teamId, String term) =>
      session.store.removeRecentSearch(teamId, term);

  Future<List<api.Channel>> _missingChannels(Set<String> ids) async {
    final known = {
      for (final c in await (_db.select(
        _db.channels,
      )..where((c) => c.id.isIn(ids))).get())
        c.id,
    };
    final found = await Future.wait([
      for (final id in ids.difference(known))
        session.api
            .call(() => _client.channels.getChannel(channelId: id))
            .then<api.Channel?>((c) => c)
            // A channel that can't be read leaves its results unnamed.
            .catchError((Object _) => null),
    ]);
    return found.nonNulls.toList();
  }

  Future<List<api.User>> _missingUsers(Set<String> ids) async {
    final known = {
      for (final u in await (_db.select(
        _db.users,
      )..where((u) => u.id.isIn(ids))).get())
        u.id,
    };
    final missing = ids.difference(known).toList();
    if (missing.isEmpty) return const [];
    return session.api.call(() => _client.users.getUsersByIds(body: missing));
  }
}
