import 'dart:async';

import 'package:drift/drift.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/views/permission_views.dart';
import 'package:matterleast/domain/autocomplete.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/log.dart';

/// Suggestions for the word at the cursor: what the database knows first,
/// then merged with the server's autocomplete when it answers. A server
/// that fails or is slow leaves the local suggestions.
class SuggestionSource {
  SuggestionSource({
    required this.server,
    required this.store,
    DateTime Function()? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  final ServerApi server;
  final ServerStore store;
  final DateTime Function() _clock;

  static const _commandsFor = Duration(seconds: 60);
  final _commands = <String, ({DateTime at, List<api.Command> list})>{};

  ServerDatabase get _db => store.db;

  /// Emits the local suggestions, then (when the server is asked) the
  /// merged ones.
  Stream<List<Suggestion>> suggest({
    required String text,
    required int cursor,
    required String channelId,
    required String teamId,
    String rootId = '',
  }) async* {
    switch (triggerAt(text, cursor)) {
      case null:
        yield const [];
      case UserTrigger(:final prefix):
        final local = await _localUsers(prefix);
        final rights = await PermissionViews(_db).channel(channelId);
        final special = rights.channelMentions;
        yield rankUsers(prefix, local, specialMentions: special);
        final groupsAsked =
            prefix.isNotEmpty &&
                rights.groupMentions &&
                (await _db.features()).groupMentions
            ? _ask(
                () => server.client.groups.getGroups(
                  q: prefix,
                  filterAllowReference: true,
                  includeMemberCount: true,
                  perPage: 25,
                ),
                feature: OptionalFeature.groupMentions,
              )
            : Future<List<api.Group>?>.value();
        final remote = await _ask(
          () => server.client.users.autocompleteUsers(
            name: prefix,
            limit: 25,
            inTeam: teamId.isEmpty ? null : teamId,
            inChannel: channelId,
          ),
        );
        final groups = [
          for (final g in await groupsAsked ?? const <api.Group>[])
            if (g.id != null && g.name != null && g.deleteAt == null)
              (
                id: g.id!,
                name: g.name!,
                displayName: g.displayName ?? g.name!,
                memberCount: g.memberCount,
              ),
        ];
        if (remote == null && groups.isEmpty) return;
        final found = remote == null
            ? const <api.User>[]
            : [...remote.users, ...remote.outOfChannel];
        await store.applyUsers(found);
        final outside = {
          for (final u in remote?.outOfChannel ?? const <api.User>[]) ?u.id,
        };
        yield rankUsers(
          prefix,
          [
            for (final u in found)
              if (u.id != null && u.username != null && u.deleteAt == null)
                _candidate(u, inChannel: !outside.contains(u.id)),
            for (final u in local)
              if (!outside.contains(u.id)) u,
          ],
          specialMentions: special,
          groups: groups,
        );
      case ChannelTrigger(:final prefix):
        final local = await _localChannels(teamId, prefix);
        yield rankChannels(prefix, local);
        if (teamId.isEmpty) return;
        final remote = await _ask(
          () => server.client.channels.autocompleteChannelsForTeam(
            teamId: teamId,
            name: prefix,
          ),
        );
        if (remote == null) return;
        final mine = await _memberOf([for (final c in remote) ?c.id]);
        yield rankChannels(prefix, [
          ...local,
          for (final c in remote)
            if (c.id != null && c.name != null && c.deleteAt == null)
              (
                id: c.id!,
                name: c.name!,
                displayName: c.displayName ?? c.name!,
                type: c.type ?? '',
                member: mine.contains(c.id),
              ),
        ]);
      case EmojiTrigger(:final prefix):
        final custom = await _customEmoji();
        final recent = await store.recentEmoji();
        List<Suggestion> ranked(Iterable<String> customNames) => rankEmoji(
          prefix,
          systemNames: systemEmojiNames(),
          customNames: customNames,
          recent: recent,
          unicodeOf: unicodeForName,
        );
        yield ranked(custom);
        if (!await _customEmojiOn()) return;
        final remote = await _ask(
          () => server.client.emoji.autocompleteEmoji(name: prefix),
          feature: OptionalFeature.customEmoji,
        );
        if (remote == null) return;
        await store.applyCustomEmoji(remote);
        yield ranked({...custom, for (final e in remote) ?e.name});
      case final CommandTrigger trigger when !trigger.hasArguments:
        yield const [];
        if (teamId.isEmpty || !await _commandsOn()) return;
        final commands = await _teamCommands(teamId);
        if (commands == null) return;
        yield rankCommands(trigger.prefix, [
          for (final c in commands)
            if (c.trigger != null && c.deleteAt == null)
              (
                trigger: c.trigger!,
                hint: c.autoCompleteHint ?? '',
                description: c.autoCompleteDesc ?? c.description ?? '',
                iconUrl: c.iconUrl ?? '',
              ),
        ]);
      case CommandTrigger(:final prefix):
        yield const [];
        if (teamId.isEmpty || !await _commandsOn()) return;
        final remote = await _ask(
          () => server.client.commands.listCommandAutocompleteSuggestions(
            teamId: teamId,
            userInput: '/$prefix',
            channelId: channelId,
            rootId: rootId.isEmpty ? null : rootId,
          ),
          feature: OptionalFeature.commandSuggestions,
        );
        if (remote == null) return;
        yield [
          for (final s in remote)
            if (s.complete case final complete? when complete.isNotEmpty)
              CommandSuggestion(
                complete: complete,
                hint: s.hint ?? '',
                description: s.description ?? '',
                iconUrl: s.iconData ?? '',
              ),
        ];
    }
  }

  /// The team's commands, asked for at most once a minute.
  Future<List<api.Command>?> _teamCommands(String teamId) async {
    final cached = _commands[teamId];
    if (cached != null && _clock().difference(cached.at) < _commandsFor) {
      return cached.list;
    }
    final list = await _ask(
      () => server.client.commands.listAutocompleteCommands(teamId: teamId),
      feature: OptionalFeature.commandSuggestions,
    );
    if (list != null) _commands[teamId] = (at: _clock(), list: list);
    return list;
  }

  /// The server's suggestions, or null when it has none to give; an
  /// answer that the optional [feature] is unavailable turns it off.
  Future<T?> _ask<T>(
    Future<T> Function() request, {
    OptionalFeature? feature,
  }) async {
    try {
      return await server.call(request);
    } on Object catch (e) {
      Log.info('autocomplete', 'Server suggestions failed: ${e.runtimeType}');
      if (feature != null &&
          endpointUnavailable(
            e,
            refusalMeansAbsent:
                feature == OptionalFeature.commandSuggestions ||
                feature == OptionalFeature.groupMentions,
          )) {
        await store.turnOff(feature);
      }
      return null;
    }
  }

  static String _escape(String prefix) =>
      prefix.replaceAllMapped(RegExp(r'[\\%_]'), (m) => '\\${m[0]}');

  Future<List<UserCandidate>> _localUsers(String prefix) async {
    final like = '${_escape(prefix)}%';
    final word = '% ${_escape(prefix)}%';
    final me = await _db.syncText(SyncKeys.currentUserId);
    final rows =
        await (_db.select(_db.users)
              ..where(
                (u) =>
                    u.deleteAt.isNull() &
                    u.id.equals(me ?? '').not() &
                    (u.username.like(like, escapeChar: r'\') |
                        u.firstName.like(like, escapeChar: r'\') |
                        u.lastName.like(like, escapeChar: r'\') |
                        u.nickname.like(like, escapeChar: r'\') |
                        u.nickname.like(word, escapeChar: r'\')),
              )
              ..limit(100))
            .get();
    return [
      for (final u in rows)
        (
          id: u.id,
          username: u.username,
          firstName: u.firstName,
          lastName: u.lastName,
          nickname: u.nickname,
          inChannel: null,
        ),
    ];
  }

  UserCandidate _candidate(api.User u, {required bool inChannel}) => (
    id: u.id!,
    username: u.username!,
    firstName: u.firstName ?? '',
    lastName: u.lastName ?? '',
    nickname: u.nickname ?? '',
    inChannel: inChannel,
  );

  Future<List<ChannelCandidate>> _localChannels(
    String teamId,
    String prefix,
  ) async {
    final query =
        _db.select(_db.channels).join([
          leftOuterJoin(
            _db.myChannels,
            _db.myChannels.channelId.equalsExp(_db.channels.id),
          ),
        ])..where(
          _db.channels.teamId.equals(teamId) &
              _db.channels.deleteAt.isNull() &
              _db.channels.type.isIn(['O', 'P']),
        );
    return [
      for (final row in await query.get())
        (
          id: row.readTable(_db.channels).id,
          name: row.readTable(_db.channels).name,
          displayName: row.readTable(_db.channels).displayName,
          type: row.readTable(_db.channels).type,
          member: row.readTableOrNull(_db.myChannels) != null,
        ),
    ];
  }

  Future<Set<String>> _memberOf(List<String> channelIds) async => {
    for (final m in await (_db.select(
      _db.myChannels,
    )..where((m) => m.channelId.isIn(channelIds))).get())
      m.channelId,
  };

  Future<Set<String>> _customEmoji() async => {
    for (final e in await _db.select(_db.customEmoji).get()) e.name,
  };

  Future<bool> _customEmojiOn() async => (await _db.features()).customEmoji;

  Future<bool> _commandsOn() async => (await _db.features()).commandSuggestions;
}
