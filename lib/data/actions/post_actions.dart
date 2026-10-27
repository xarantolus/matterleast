import 'package:drift/drift.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/domain/preference_keys.dart';
import 'package:matterleast/domain/server_features.dart';

/// What the user does to an existing post from its menu. Changes show at
/// once and are put back when the server refuses, rethrowing its error for
/// the screen to tell. The server's own events for the same change apply
/// on top without harm, since every apply is idempotent.
class PostActions {
  PostActions(this.session, {DateTime Function()? clock})
    : _clock = clock ?? (() => DateTime.now().toUtc());

  final ServerSession session;
  final DateTime Function() _clock;

  ServerDatabase get _db => session.db;
  ServerStore get _store => session.store;
  api.MattermostClient get _client => session.api.client;

  Future<T> _call<T>(Future<T> Function() request) => session.api.call(request);

  Future<String> _me() async {
    final me = await _db.syncText(SyncKeys.currentUserId);
    if (me == null) throw StateError('Not signed in');
    return me;
  }

  Future<void> _optimistic(
    Future<void> Function() apply,
    Future<void> Function() request,
    Future<void> Function() revert,
  ) async {
    await apply();
    try {
      await request();
    } on Object {
      await revert();
      rethrow;
    }
  }

  Future<void> addReaction(String postId, String emojiName) async {
    final reaction = api.Reaction(
      userId: await _me(),
      postId: postId,
      emojiName: emojiName,
      createAt: _clock(),
    );
    await _optimistic(
      () => _store.applyReaction(reaction, added: true),
      () => _call(() => _client.reactions.saveReaction(body: reaction)),
      () => _store.applyReaction(reaction, added: false),
    );
    await _store.addRecentEmoji([emojiName]);
  }

  Future<void> removeReaction(String postId, String emojiName) async {
    final me = await _me();
    final existing =
        await (_db.select(_db.reactions)..where(
              (r) =>
                  r.postId.equals(postId) &
                  r.userId.equals(me) &
                  r.emojiName.equals(emojiName),
            ))
            .getSingleOrNull();
    final reaction = api.Reaction(
      userId: me,
      postId: postId,
      emojiName: emojiName,
      createAt: existing?.createAt,
    );
    await _optimistic(
      () => _store.applyReaction(reaction, added: false),
      () => _call(
        () => _client.reactions.deleteReaction(
          userId: me,
          postId: postId,
          emojiName: emojiName,
        ),
      ),
      () async {
        if (existing != null) await _store.applyReaction(reaction, added: true);
      },
    );
  }

  /// Adds or takes back a reaction on the newest message in the channel
  /// (its root messages under collapsed threads) or in the thread of
  /// [rootId]. False when [emojiName] is no emoji the server knows or
  /// there is no message, so the text is sent as it is.
  Future<bool> reactToNewest(
    String channelId, {
    required String rootId,
    required String emojiName,
    required bool add,
  }) async {
    final name = canonicalName(emojiName);
    if (!isKnownEmoji(name) && !await _isCustomEmoji(name)) return false;
    final crt = await _db.collapsedThreads();
    final newest =
        await (_db.select(_db.posts)
              ..where(
                (p) =>
                    p.channelId.equals(channelId) &
                    p.deleteAt.isNull() &
                    p.sendState.isNull() &
                    p.type.equals(ephemeralType).not() &
                    (rootId.isNotEmpty
                        ? p.rootId.equals(rootId) | p.id.equals(rootId)
                        : crt
                        ? p.rootId.equals('')
                        : const Constant(true)),
              )
              ..orderBy([(p) => OrderingTerm.desc(p.createAt)])
              ..limit(1))
            .getSingleOrNull();
    if (newest == null) return false;
    final me = await _me();
    final mine =
        await (_db.select(_db.reactions)..where(
              (r) =>
                  r.postId.equals(newest.id) &
                  r.userId.equals(me) &
                  r.emojiName.equals(name),
            ))
            .getSingleOrNull();
    if (add && mine == null) await addReaction(newest.id, name);
    if (!add && mine != null) await removeReaction(newest.id, name);
    return true;
  }

  Future<bool> _isCustomEmoji(String name) async =>
      await (_db.select(_db.customEmoji)
            ..where((e) => e.name.equals(name) & e.deleteAt.isNull())
            ..limit(1))
          .getSingleOrNull() !=
      null;

  /// Changes the text of a post; it shows edited at once.
  Future<void> editPost(String postId, String message) async {
    final before = await _store.post(postId);
    if (before == null) return;
    await _optimistic(
      () => _store.setPostMessage(postId, message, editAt: _clock()),
      () async {
        // The generated patch body always sends `file_ids`, and an empty
        // list would remove the post's files; only the text goes here.
        final response = await _call(
          () => session.api.dio.put<Map<String, Object?>>(
            '/api/v4/posts/$postId/patch',
            data: {'message': message},
          ),
        );
        if (response.data case final json?) {
          await _store.applyEdit(api.Post.fromJson(json));
        }
      },
      () =>
          _store.setPostMessage(postId, before.message, editAt: before.editAt),
    );
  }

  /// Deletes a post after the server agreed, so a refusal leaves it as it
  /// was; it then goes without a placeholder.
  Future<void> deletePost(String postId) async {
    await _call(() => _client.posts.deletePost(postId: postId));
    await _store.removePost(postId);
  }

  /// Opens a burn-on-read message; its countdown starts. When the server
  /// says it is gone (expired or burned), it goes here too.
  Future<void> reveal(String postId) async {
    try {
      await _store.applyEdit(
        await _call(() => _client.posts.revealPost(postId: postId)),
      );
    } on ServerError catch (e) {
      if (e.isNotFound || (e.id?.contains('burn_on_read') ?? false)) {
        await _store.removePost(postId);
      }
      rethrow;
    }
  }

  /// Burns a burn-on-read message at once: for everyone when it is the
  /// user's own, else for the user.
  Future<void> burnNow(String postId) async {
    await _call(() => _client.posts.burnPost(postId: postId));
    await _store.removePost(postId);
  }

  /// A burn-on-read message's time ran out while it was on screen.
  Future<void> burned() => _store.removeBurnedPosts(_clock());

  Future<void> savePost(String postId) => _setSaved(postId, saved: true);

  Future<void> unsavePost(String postId) => _setSaved(postId, saved: false);

  Future<void> _setSaved(String postId, {required bool saved}) async {
    final me = await _me();
    final preference = api.Preference(
      userId: me,
      category: Prefs.flaggedPost,
      name: postId,
      value: 'true',
    );
    Future<void> show({required bool saved}) async {
      if (saved) {
        await _store.applyPreferences([preference]);
      } else {
        await _store.deletePreferences([preference]);
      }
      await _store.applySavedChanges([preference], deleted: !saved);
    }

    await _optimistic(
      () => show(saved: saved),
      () => _call(
        () => saved
            ? _client.preferences.updatePreferences(
                userId: me,
                body: [preference],
              )
            : _client.preferences.deletePreferences(
                userId: me,
                body: [preference],
              ),
      ),
      () => show(saved: !saved),
    );
  }

  Future<void> pinPost(String postId) => _setPinned(postId, pinned: true);

  Future<void> unpinPost(String postId) => _setPinned(postId, pinned: false);

  Future<void> _setPinned(String postId, {required bool pinned}) => _optimistic(
    () => _store.setPinned(postId, pinned: pinned),
    () => _call(
      () => pinned
          ? _client.posts.pinPost(postId: postId)
          : _client.posts.unpinPost(postId: postId),
    ),
    () => _store.setPinned(postId, pinned: !pinned),
  );

  /// Acknowledges a message that asks for it, or takes the acknowledgement
  /// back. A server without acknowledgements turns them off.
  Future<void> acknowledge(String postId) => _setAcknowledged(postId, true);

  Future<void> unacknowledge(String postId) => _setAcknowledged(postId, false);

  Future<void> _setAcknowledged(String postId, bool acknowledged) async {
    final me = await _me();
    final ack = api.PostAcknowledgement(
      userId: me,
      postId: postId,
      acknowledgedAt: _clock(),
    );
    try {
      await _optimistic(
        () => _store.applyAcknowledgement(ack, added: acknowledged),
        () async {
          if (!acknowledged) {
            await _call(
              () => _client.posts.deleteAcknowledgementForPost(
                userId: me,
                postId: postId,
              ),
            );
            return;
          }
          final saved = await _call(
            () => _client.posts.saveAcknowledgementForPost(
              userId: me,
              postId: postId,
            ),
          );
          await _store.applyAcknowledgement(saved, added: true);
        },
        () => _store.applyAcknowledgement(ack, added: !acknowledged),
      );
    } on ApiError catch (e) {
      if (endpointUnavailable(e)) {
        await _store.turnOff(OptionalFeature.acknowledgements);
      }
      rethrow;
    }
  }

  /// Marks the channel unread from this post on; it stays unread until the
  /// user opens it again. The counts come from the server.
  Future<void> markUnread(String postId) async {
    final me = await _me();
    final post = await _store.post(postId);
    final crt = await _db.collapsedThreads();
    final unread = await _call(
      () => _client.posts.setPostUnread(
        userId: me,
        postId: postId,
        body: api.ApiV4UsersUserIdPostsPostIdSetUnreadRequestBody(
          collapsedThreadsSupported: crt,
        ),
      ),
    );
    final channelId = unread.channelId ?? post?.channelId;
    if (channelId == null) return;
    final channel = _call(
      () => _client.channels.getChannel(channelId: channelId),
    );
    final member = _call(
      () =>
          _client.channels.getChannelMember(channelId: channelId, userId: 'me'),
    );
    await _store.applyChannel(await channel);
    await _store.applyMarkedUnread(await member);
  }

  /// With [channelId], a thread not stored yet is stored as followed.
  Future<void> followThread(
    String teamId,
    String rootId, {
    String? channelId,
  }) => _setFollowing(teamId, rootId, following: true, channelId: channelId);

  Future<void> unfollowThread(String teamId, String rootId) =>
      _setFollowing(teamId, rootId, following: false);

  Future<void> _setFollowing(
    String teamId,
    String rootId, {
    required bool following,
    String? channelId,
  }) => _optimistic(
    () => _store.applyThreadFollow(
      rootId,
      following: following,
      channelId: channelId,
    ),
    () => _call(
      () => following
          ? _client.threads.startFollowingThread(
              userId: 'me',
              teamId: teamId,
              threadId: rootId,
            )
          : _client.threads.stopFollowingThread(
              userId: 'me',
              teamId: teamId,
              threadId: rootId,
            ),
    ),
    () => _store.applyThreadFollow(rootId, following: !following),
  );

  /// Asks the server to have its system bot remind the user of the post
  /// at [at]. A server without reminders turns them off.
  Future<void> remind(String postId, DateTime at) async {
    final me = await _me();
    try {
      // Not in the generated client: one tiny body and an OK answer.
      await _call(
        () => session.api.dio.post<Object?>(
          '/api/v4/users/$me/posts/$postId/reminder',
          data: {'target_time': at.toUtc().millisecondsSinceEpoch ~/ 1000},
        ),
      );
    } on Object catch (e) {
      if (remindersUnavailable(e)) {
        await _store.turnOff(OptionalFeature.postReminders);
      }
      rethrow;
    }
  }
}

/// Pure: whether a failed reminder says the server has none: not built
/// in, or no such route (a 404 for the post itself means only that post).
bool remindersUnavailable(Object error) =>
    endpointUnavailable(error) ||
    (error is ServerError &&
        error.statusCode == 404 &&
        error.id == 'api.context.404.app_error');
