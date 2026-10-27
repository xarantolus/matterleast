import 'package:dio/dio.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/data/updates/update_check.dart';
import 'package:matterleast/domain/app_update.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_providers.g.dart';

@Riverpod(keepAlive: true)
Dio updateHttp(Ref ref) {
  const timeout = Duration(seconds: 10);
  final dio = Dio(
    BaseOptions(
      connectTimeout: timeout,
      sendTimeout: timeout,
      receiveTimeout: timeout,
    ),
  );
  ref.onDispose(dio.close);
  return dio;
}

@Riverpod(keepAlive: true)
UpdateCheck updateCheck(Ref ref) {
  final check = UpdateCheck(
    http: ref.watch(updateHttpProvider),
    settings: ref.watch(settingsStoreProvider),
    repo: releaseRepo,
  )..start();
  ref.onDispose(check.dispose);
  return check;
}

@riverpod
Stream<KnownRelease?> latestRelease(Ref ref) =>
    ref.watch(settingsStoreProvider).watch(Settings.latestRelease);

@riverpod
Stream<String?> dismissedRelease(Ref ref) =>
    ref.watch(settingsStoreProvider).watch(Settings.dismissedRelease);

/// The release the desktop update indicator points out, or null. Watching
/// it on desktop starts the daily check; phones update through their store
/// and never ask.
@riverpod
KnownRelease? availableUpdate(Ref ref) {
  if (!isDesktop) return null;
  ref.watch(updateCheckProvider);
  final running = ref.watch(runningVersionProvider).value;
  if (running == null) return null;
  return updateToShow(
    running: running,
    latest: ref.watch(latestReleaseProvider).value,
    dismissed: ref.watch(dismissedReleaseProvider).value,
  );
}
