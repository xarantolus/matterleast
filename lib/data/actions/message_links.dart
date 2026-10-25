import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/markdown/post_doc.dart';

/// Looks up what mentions, channel links and permalinks in messages point
/// at: stored data first, the server when a message isn't stored.
class MessageLinks {
  MessageLinks(this.session);

  final ServerSession session;

  ServerDatabase get _db => session.db;

  /// The channel a message is in.
  Future<String?> channelOfPost(String postId) async {
    final row = await (_db.select(
      _db.posts,
    )..where((p) => p.id.equals(postId))).getSingleOrNull();
    if (row != null) return row.channelId;
    final post = await session.api.call(
      () => session.api.client.posts.getPost(postId: postId),
    );
    return post.channelId;
  }

  /// A channel by its URL name, in [teamId] when there is one by that name.
  Future<ChannelRow?> channelNamed(String name, {String? teamId}) async {
    final rows = await (_db.select(
      _db.channels,
    )..where((c) => c.name.equals(name.toLowerCase()))).get();
    return rows.where((c) => c.teamId == teamId).firstOrNull ??
        rows.firstOrNull;
  }

  /// The person a typed `@name` refers to, allowing a trailing `.`, `-` or
  /// `_` that belongs to the sentence.
  Future<UserRow?> userMentioned(String typed) async {
    final candidates = <String>[];
    var name = typed.toLowerCase();
    while (name.isNotEmpty) {
      candidates.add(name);
      final last = name[name.length - 1];
      if (last != '.' && last != '-' && last != '_') break;
      name = name.substring(0, name.length - 1);
    }
    final rows = await (_db.select(
      _db.users,
    )..where((u) => u.username.isIn(candidates))).get();
    for (final candidate in candidates) {
      final match = rows.where((u) => u.username == candidate).firstOrNull;
      if (match != null) return match;
    }
    return null;
  }

  /// Parse options from the stored client config, as it changes.
  Stream<ParseOptions> parseOptions() =>
      (_db.select(_db.config)..where((c) => c.key.equals('client_config')))
          .watchSingleOrNull()
          .asyncMap((_) => _db.configJson('client_config'))
          .map(parseOptionsFrom)
          .distinct();
}

/// Pure: the server settings that change how messages parse.
ParseOptions parseOptionsFrom(Map<String, Object?> config) => ParseOptions(
  latexBlocks: config['EnableLatex'] == 'true',
  latexInline:
      config['EnableLatex'] == 'true' && config['EnableInlineLatex'] == 'true',
  minimumHashtagLength:
      int.tryParse('${config['MinimumHashtagLength'] ?? ''}') ?? 3,
  maxNodes: int.tryParse('${config['MaxMarkdownNodes'] ?? ''}'),
);
