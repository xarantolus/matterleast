import 'dart:async';

import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/paged_search.dart';
import 'package:matterleast/domain/quick_switch.dart';

/// Pages of people and channels from one server, for member lists, pickers
/// and browsing. People are stored, so names and presence come from the
/// database; channels the user can join are only shown.
class Directory {
  Directory(this.session, {required this.serverUrl});

  final ServerSession session;
  final String serverUrl;

  static const pageSize = 60;

  ServerDatabase get _db => session.db;
  api.MattermostClient get _client => session.api.client;

  /// Searches are POSTs, which [ServerApi] doesn't join by itself.
  Future<T> _search<T>(String key, Future<T> Function() request) =>
      session.api.coalesced(key, request);

  /// One page of people, stored; deactivated people and bots are left out,
  /// so a short page doesn't mean the last one.
  Future<ServerPage<String>> _page(List<api.User> users) async =>
      (items: await _stored(users), more: users.length >= pageSize);

  Future<List<String>> _stored(List<api.User> users) async {
    await session.store.applyUsers(users);
    return [
      for (final u in users)
        if (u.id != null && u.deleteAt == null && u.isBot != true) u.id!,
    ];
  }

  /// Members of a channel, admins first.
  Future<ServerPage<String>> members(String channelId, {int page = 0}) async =>
      _page(
        await session.api.call(
          () => _client.users.getUsers(
            inChannel: channelId,
            active: true,
            sort: 'admin',
            page: page,
            perPage: pageSize,
          ),
        ),
      );

  /// People in [teamId] who are not in [channelId], to add.
  Future<ServerPage<String>> nonMembers(
    String teamId,
    String channelId, {
    int page = 0,
  }) async => _page(
    await session.api.call(
      () => _client.users.getUsers(
        inTeam: teamId,
        notInChannel: channelId,
        active: true,
        page: page,
        perPage: pageSize,
      ),
    ),
  );

  /// Everyone the user may message: the team's people when the server
  /// restricts direct messages to teams, else everyone.
  Future<ServerPage<String>> people({String? teamId, int page = 0}) async {
    final restricted = await _restricted();
    return _page(
      await session.api.call(
        () => _client.users.getUsers(
          inTeam: restricted ? teamId : null,
          active: true,
          page: page,
          perPage: pageSize,
        ),
      ),
    );
  }

  /// People matching [term], narrowed like the lists above.
  Future<List<String>> searchPeople(
    String term, {
    String? teamId,
    String? inChannel,
    String? notInChannel,
  }) =>
      _search('people-search:$term:$teamId:$inChannel:$notInChannel', () async {
        final restricted = inChannel == null && notInChannel == null
            ? await _restricted()
            : true;
        return _stored(
          await session.api.call(
            () => _client.users.searchUsers(
              body: api.ApiV4UsersSearchRequestBody(
                term: term,
                teamId: restricted ? teamId : null,
                inChannelId: inChannel,
                notInChannelId: notInChannel,
                allowInactive: false,
                limit: 50,
              ),
            ),
          ),
        );
      });

  Future<bool> _restricted() async =>
      (await _db.features()).directMessagesRestricted;

  /// Public channels of [teamId] the user is not in, or archived ones with
  /// [archived]; [more] says whether another page may follow.
  Future<ServerPage<SwitchItem>> channels(
    String teamId, {
    bool archived = false,
    int page = 0,
  }) async {
    final found = await session.api.call(
      () => archived
          ? _client.channels.getDeletedChannelsForTeam(
              teamId: teamId,
              page: page,
              perPage: pageSize,
            )
          : _client.channels.getPublicChannelsForTeam(
              teamId: teamId,
              page: page,
              perPage: pageSize,
            ),
    );
    return (
      items: await _channelItems(found, archived: archived),
      more: found.length >= pageSize,
    );
  }

  /// Channels of [teamId] matching [term].
  Future<List<SwitchItem>> searchChannels(
    String teamId,
    String term, {
    bool archived = false,
  }) => _search('channel-search:$teamId:$term:$archived', () async {
    final found = await session.api.call(
      () => _client.channels.searchChannels(
        teamId: teamId,
        body: api.ApiV4TeamsTeamIdChannelsSearchRequestBody(term: term),
      ),
    );
    return _channelItems([
      for (final c in found)
        if ((c.deleteAt != null) == archived) c,
    ], archived: archived);
  });

  Future<List<SwitchItem>> _channelItems(
    List<api.Channel> found, {
    required bool archived,
  }) async {
    final joined = {
      for (final m in await _db.select(_db.myChannels).get()) m.channelId,
    };
    return [
      for (final c in found)
        if (c.id != null &&
            (archived || (c.type == 'O' && !joined.contains(c.id))))
          SwitchItem(
            serverUrl: serverUrl,
            kind: archived ? SwitchKind.archived : SwitchKind.joinable,
            id: c.id!,
            title: c.displayName ?? c.name ?? '',
            subtitle: c.purpose,
            handle: c.name,
            teamId: c.teamId,
          ),
    ];
  }
}
