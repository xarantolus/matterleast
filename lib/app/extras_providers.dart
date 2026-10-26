import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/attribute_actions.dart';
import 'package:matterleast/data/actions/bookmark_actions.dart';
import 'package:matterleast/data/views/extras_views.dart';
import 'package:matterleast/domain/bookmarks.dart';
import 'package:matterleast/domain/profile_attributes.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'extras_providers.g.dart';

@Riverpod(keepAlive: true)
Future<BookmarkActions> bookmarkActions(Ref ref, String url) async =>
    (await ref.watch(serverSessionProvider(url).future)).bookmarks;

@Riverpod(keepAlive: true)
Future<AttributeActions> attributeActions(Ref ref, String url) async =>
    (await ref.watch(serverSessionProvider(url).future)).attributes;

@riverpod
Stream<List<Bookmark>> channelBookmarks(
  Ref ref,
  String url,
  String channelId,
) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* BookmarkViews(session.db).bookmarks(channelId);
}

@riverpod
Stream<BookmarkRights> bookmarkRightsIn(
  Ref ref,
  String url,
  String channelId,
) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* BookmarkViews(session.db).rights(channelId);
}

/// Fetched once while a channel's bar is shown, so it catches up with
/// changes made while the app wasn't listening.
@Riverpod(retry: noRetry)
Future<void> bookmarksRefresh(Ref ref, String url, String channelId) async {
  final actions = await ref.watch(bookmarkActionsProvider(url).future);
  await actions.refresh(channelId);
}

@riverpod
Stream<List<ShownAttribute>> profileAttributes(
  Ref ref,
  String url,
  String userId,
) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* AttributeViews(session.db).shown(userId);
}

@riverpod
Stream<(List<AttributeField>, Map<String, List<String>>)> editableAttributes(
  Ref ref,
  String url,
  String userId,
) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* AttributeViews(session.db).editable(userId);
}

/// Fetched when a profile opens.
@Riverpod(retry: noRetry)
Future<void> attributesRefresh(Ref ref, String url, String userId) async {
  final actions = await ref.watch(attributeActionsProvider(url).future);
  await actions.refresh(userId);
}
