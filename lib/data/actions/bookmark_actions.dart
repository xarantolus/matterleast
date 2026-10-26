import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/file_upload.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/extras_store.dart';
import 'package:matterleast/domain/server_features.dart';

/// A channel's bookmarks: fetched behind the cached bar, and the user's
/// changes, stored from the server's answer.
class BookmarkActions {
  BookmarkActions(this.session);

  final ServerSession session;

  api.BookmarksClient get _client => session.api.client.bookmarks;

  /// Changes since the last fetch; nothing when the server has no
  /// bookmarks. An answer that the endpoint isn't there turns them off.
  Future<void> refresh(String channelId) async {
    if (!(await session.db.features()).bookmarks) return;
    final since = await session.db.syncInt(SyncKeys.bookmarksSince(channelId));
    try {
      final bookmarks = await session.api.coalesced(
        'bookmarks:$channelId',
        () => _client.listChannelBookmarksForChannel(
          channelId: channelId,
          bookmarksSince: since == null || since == 0 ? null : since,
        ),
      );
      await session.store.applyBookmarks(channelId, bookmarks);
    } on Object catch (e) {
      // A server from before bookmarks has no such route. A 403 only says
      // the user can't see this channel's, so it doesn't count.
      await _turnOffIfAbsent(e, missingRoute: true);
      rethrow;
    }
  }

  Future<void> addLink(
    String channelId, {
    required String name,
    required Uri link,
    String? emoji,
  }) => _write(channelId, () async {
    final created = await session.api.call(
      () => _client.createChannelBookmark(
        channelId: channelId,
        body: api.ApiV4ChannelsChannelIdBookmarksRequestBody(
          displayName: name,
          type: api.Type.link,
          linkUrl: link.toString(),
          emoji: _orNull(emoji),
        ),
      ),
    );
    return [created];
  });

  /// Uploads a file to the channel and bookmarks it.
  Future<void> addFile(
    String channelId, {
    required String name,
    required Stream<List<int>> Function() open,
    required int length,
  }) => _write(channelId, () async {
    final upload = FileUpload.start(
      session.api,
      channelId: channelId,
      open: open,
      length: length,
      name: name,
      clientId: 'bookmark-${DateTime.now().microsecondsSinceEpoch}',
    );
    final file = await upload.done;
    final created = await session.api.call(
      () => _client.createChannelBookmark(
        channelId: channelId,
        body: api.ApiV4ChannelsChannelIdBookmarksRequestBody(
          displayName: name,
          type: api.Type.file,
          fileId: file.id,
        ),
      ),
    );
    return [created];
  });

  /// Renames a bookmark, or points a link elsewhere. The server may answer
  /// with a copy that replaces it (when someone else owned it).
  Future<void> edit(
    String channelId,
    String bookmarkId, {
    required String name,
    Uri? link,
    String? emoji,
  }) => _write(channelId, () async {
    final result = await session.api.call(
      () => _client.updateChannelBookmark(
        channelId: channelId,
        bookmarkId: bookmarkId,
        body: api.ApiV4ChannelsChannelIdBookmarksBookmarkIdRequestBody(
          displayName: name,
          linkUrl: link?.toString(),
          emoji: emoji ?? '',
        ),
      ),
    );
    return [?result.deleted, ?result.updated];
  });

  Future<void> delete(String channelId, String bookmarkId) =>
      _write(channelId, () async {
        await session.api.call(
          () => _client.deleteChannelBookmark(
            channelId: channelId,
            bookmarkId: bookmarkId,
          ),
        );
        await session.store.removeBookmark(bookmarkId);
        return const [];
      });

  /// Moves a bookmark to [index] in the bar; the server renumbers the rest.
  Future<void> move(String channelId, String bookmarkId, int index) => _write(
    channelId,
    () => session.api.call(
      () => _client.updateChannelBookmarkSortOrder(
        channelId: channelId,
        bookmarkId: bookmarkId,
        body: index,
      ),
    ),
  );

  Future<void> _write(
    String channelId,
    Future<List<api.ChannelBookmarkWithFileInfo>> Function() request,
  ) async {
    try {
      await session.store.applyBookmarks(channelId, await request());
    } on Object catch (e) {
      await _turnOffIfAbsent(e);
      rethrow;
    }
  }

  Future<void> _turnOffIfAbsent(Object e, {bool missingRoute = false}) async {
    if (endpointUnavailable(e) ||
        missingRoute && e is ServerError && e.statusCode == 404) {
      await session.store.turnOff(OptionalFeature.bookmarks);
    }
  }

  static String? _orNull(String? s) => s == null || s.isEmpty ? null : s;
}
