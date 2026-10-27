import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/markdown/post_doc.dart';

/// Looks up what mentions, channel links and permalinks in messages point
/// at: stored data first, the server when a message isn't stored.
class MessageLinks {
  MessageLinks(this.session);

  final ServerSession session;

  ServerDatabase get _db => session.db;

  /// Where a linked message is: stored, on the server in a channel the
  /// user is in, behind a team or channel to join first, or gone. Throws
  /// [ApiError] when the server can't be asked.
  Future<LinkedPost> locatePost(String postId) async {
    final row = await (_db.select(
      _db.posts,
    )..where((p) => p.id.equals(postId))).getSingleOrNull();
    if (row != null && row.deleteAt == null) {
      final channel = await (_db.select(
        _db.channels,
      )..where((c) => c.id.equals(row.channelId))).getSingleOrNull();
      if (channel != null) {
        return LinkedPostFound(
          channelId: row.channelId,
          teamId: channel.teamId,
          rootId: row.rootId,
          channelName: channel.displayName,
        );
      }
    }
    final api = session.api;
    try {
      final info = await api.call(
        () => api.client.posts.getPostInfo(postId: postId),
      );
      final channelId = info.channelId;
      if (channelId == null) return const LinkedPostMissing();
      // Direct and group messages have no team to be in.
      final teamless = info.teamId?.isEmpty ?? true;
      if (!(teamless || (info.hasJoinedTeam ?? false)) ||
          !(info.hasJoinedChannel ?? false)) {
        return LinkedPostNeedsJoin(
          teamId: info.teamId ?? '',
          teamName: info.teamDisplayName ?? '',
          inTeam: info.hasJoinedTeam ?? false,
          channelId: channelId,
          channelName: info.channelDisplayName ?? '',
          privateChannel: info.channelType == 'P',
        );
      }
      final post = await api.call(
        () => api.client.posts.getPost(postId: postId),
      );
      if (post.deleteAt != null) return const LinkedPostMissing();
      return LinkedPostFound(
        channelId: channelId,
        teamId: info.teamId ?? '',
        rootId: post.rootId ?? '',
        channelName: info.channelDisplayName ?? '',
      );
    } on ServerError catch (e) {
      if (e.isNotFound || e.isForbidden) return const LinkedPostMissing();
      rethrow;
    }
  }

  /// A channel by the names in its link, from the server when it isn't
  /// stored; null when there is no such channel the user may see.
  Future<({ChannelRow? stored, String? id, String displayName, bool open})?>
  channelLinked(String teamName, String name) async {
    final team = await (_db.select(
      _db.teams,
    )..where((t) => t.name.equals(teamName.toLowerCase()))).getSingleOrNull();
    final stored = await channelNamed(name, teamId: team?.id);
    if (stored != null && (team == null || stored.teamId == team.id)) {
      return (
        stored: stored,
        id: stored.id,
        displayName: stored.displayName,
        open: stored.type == 'O',
      );
    }
    final api = session.api;
    try {
      final channel = await api.call(
        () => api.client.channels.getChannelByNameForTeamName(
          teamName: teamName,
          channelName: name,
        ),
      );
      return (
        stored: null,
        id: channel.id,
        displayName: channel.displayName ?? name,
        open: channel.type == 'O',
      );
    } on ServerError catch (e) {
      if (e.isNotFound || e.isForbidden) return null;
      rethrow;
    }
  }

  /// A channel by its URL name, in [teamId] when there is one by that name.
  /// The URL name of the team with [teamId], when stored.
  Future<String?> teamName(String teamId) async => (await (_db.select(
    _db.teams,
  )..where((t) => t.id.equals(teamId))).getSingleOrNull())?.name;

  Future<ChannelRow?> channelNamed(String name, {String? teamId}) async {
    final rows = await (_db.select(
      _db.channels,
    )..where((c) => c.name.equals(name.toLowerCase()))).get();
    return rows.where((c) => c.teamId == teamId).firstOrNull ??
        rows.firstOrNull;
  }

  /// The id of the person a typed `@name` refers to, stored or fetched;
  /// null when there is none. A trailing `.`, `-` or `_` may belong to the
  /// sentence instead of the name.
  Future<String?> userIdMentioned(String typed) async {
    final candidates = mentionCandidates(typed);
    final stored = await _userNamed(candidates);
    if (stored != null) return stored;
    await session.users.ensureUsernames(candidates);
    return _userNamed(candidates);
  }

  Future<String?> _userNamed(List<String> candidates) async {
    final rows = await (_db.select(
      _db.users,
    )..where((u) => u.username.isIn(candidates))).get();
    for (final candidate in candidates) {
      final match = rows.where((u) => u.username == candidate).firstOrNull;
      if (match != null) return match.id;
    }
    return null;
  }

  /// Parse options from what the server offers, as it changes.
  Stream<ParseOptions> parseOptions() =>
      _db.watchFeatures().map(parseOptionsFrom).distinct();
}

/// Pure: the usernames a typed `@name` may mean, longest first: the name
/// itself, then without each trailing `.`, `-` or `_`.
List<String> mentionCandidates(String typed) {
  final candidates = <String>[];
  var name = typed.toLowerCase();
  while (name.isNotEmpty) {
    candidates.add(name);
    final last = name[name.length - 1];
    if (last != '.' && last != '-' && last != '_') break;
    name = name.substring(0, name.length - 1);
  }
  return candidates;
}

/// Pure: the server settings that change how messages parse.
ParseOptions parseOptionsFrom(ServerFeatures features) => ParseOptions(
  latexBlocks: features.latex,
  latexInline: features.inlineLatex,
  minimumHashtagLength: features.minimumHashtagLength,
  maxNodes: features.maxMarkdownNodes,
);

/// Where a message from a link is.
sealed class LinkedPost {
  const LinkedPost();
}

/// In a channel the user is in; [rootId] is empty for a thread's first
/// message.
final class LinkedPostFound extends LinkedPost {
  const LinkedPostFound({
    required this.channelId,
    required this.teamId,
    required this.rootId,
    required this.channelName,
  });

  final String channelId;
  final String teamId;
  final String rootId;
  final String channelName;
}

/// In a team or channel the user would have to join first.
final class LinkedPostNeedsJoin extends LinkedPost {
  const LinkedPostNeedsJoin({
    required this.teamId,
    required this.teamName,
    required this.inTeam,
    required this.channelId,
    required this.channelName,
    required this.privateChannel,
  });

  final String teamId;
  final String teamName;
  final bool inTeam;
  final String channelId;
  final String channelName;
  final bool privateChannel;
}

/// Deleted, or somewhere the user can't see.
final class LinkedPostMissing extends LinkedPost {
  const LinkedPostMissing();
}

/// Pure: the thread to open for a linked reply, which under collapsed
/// threads only shows there; null to open the channel.
String? threadToOpen({
  required String rootId,
  required bool collapsedThreads,
}) => collapsedThreads && rootId.isNotEmpty ? rootId : null;
