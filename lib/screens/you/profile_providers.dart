import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/profile_actions.dart';
import 'package:matterleast/data/views/profile_views.dart';
import 'package:matterleast/domain/profile_locks.dart';
import 'package:matterleast/domain/user_profile.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

@Riverpod(keepAlive: true)
Future<ProfileActions> profileActions(Ref ref, String url) async =>
    (await ref.watch(serverSessionProvider(url).future)).profiles;

@riverpod
Stream<UserProfile?> userProfile(Ref ref, String url, String userId) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* ProfileViews(session.db).profile(userId);
}

/// The profile fields the signed-in user can't change on [url].
@riverpod
Stream<ProfileLocks> myProfileLocks(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* ProfileViews(session.db).locks();
}

/// The custom statuses the user set lately on [url], newest first.
@riverpod
Stream<List<CustomStatus>> recentCustomStatuses(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* ProfileViews(session.db).recentStatuses();
}

/// Fetched when a profile opens, so it shows fresh details.
@Riverpod(retry: noRetry)
Future<void> profileRefresh(Ref ref, String url, String userId) async {
  final actions = await ref.watch(profileActionsProvider(url).future);
  await actions.refresh(userId);
}
