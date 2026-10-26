import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/views/draft_views.dart';
import 'package:matterleast/domain/drafts.dart';
import 'package:matterleast/domain/scheduled_posts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'drafts_providers.g.dart';

/// One team's drafts, newest first.
@riverpod
Stream<List<DraftItem>> teamDrafts(Ref ref, String url, String teamId) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* DraftViews(session.db).drafts(teamId);
}

/// One team's scheduled messages, failed first, then the soonest.
@riverpod
Stream<List<ScheduledItem>> teamScheduled(
  Ref ref,
  String url,
  String teamId,
) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* DraftViews(session.db).scheduled(teamId);
}

/// How many messages wait to be sent in a channel or thread.
@riverpod
Stream<int> scheduledCount(
  Ref ref,
  String url,
  String channelId,
  String rootId,
) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* DraftViews(session.db).scheduledCount(channelId, rootId);
}

/// The IANA zone the user set by hand in their profile; null when the
/// phone's zone applies.
@riverpod
Stream<String?> manualTimeZone(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* session.db.watchMe().map((me) {
    final zone = me?.timezone;
    if (zone == null || zone.useAutomaticTimezone != 'false') return null;
    final manual = zone.manualTimezone;
    return manual == null || manual.isEmpty ? null : manual;
  }).distinct();
}

/// Fetches the team's synced drafts and scheduled messages while the drafts
/// screen is open; what is stored shows meanwhile, and a failure keeps it.
@riverpod
Future<void> refreshDrafts(Ref ref, String url, String teamId) async {
  final connection = (await ref.watch(serverSessionProvider(url).future))
      .connection;
  await Future.wait([
    connection.drafts.pull(teamId).catchError((Object _) {}),
    connection.scheduled.fetch(teamId).catchError((Object _) {}),
  ]);
}
