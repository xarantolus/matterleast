import 'dart:async';

import 'package:dio/dio.dart';
import 'package:matterleast/api/json/github_release.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/app_update.dart';
import 'package:matterleast/log.dart';

/// Asks GitHub for the newest release at most once a day and keeps the
/// answer in the settings. A failed check stays silent until the next day.
class UpdateCheck {
  UpdateCheck({
    required this._http,
    required this._settings,
    required String repo,
    this._now = DateTime.now,
  }) : _latest = Uri.https('api.github.com', '/repos/$repo/releases/latest');

  final Dio _http;
  final SettingsStore _settings;
  final DateTime Function() _now;
  final Uri _latest;
  Future<void>? _running;
  Timer? _timer;

  /// Checks now if due, then looks again every hour while the app runs,
  /// so a computer that stays on still checks daily.
  void start() {
    unawaited(runIfDue());
    _timer ??= Timer.periodic(const Duration(hours: 1), (_) => runIfDue());
  }

  void dispose() => _timer?.cancel();

  Future<void> runIfDue() => _running ??= _run().whenComplete(() {
    _running = null;
  });

  Future<void> _run() async {
    final now = _now();
    if (!updateCheckDue(await _settings.read(Settings.lastUpdateCheck), now)) {
      return;
    }
    await _settings.write(Settings.lastUpdateCheck, now);
    try {
      final response = await _http.getUri<Object?>(
        _latest,
        options: Options(
          headers: {'Accept': 'application/vnd.github+json'},
          responseType: ResponseType.json,
        ),
      );
      final release = switch (response.data) {
        final Map<String, Object?> json => GitHubRelease.fromJson(json),
        _ => null,
      };
      final tag = release?.tagName;
      final page = Uri.tryParse(release?.htmlUrl ?? '');
      if (tag == null ||
          parseVersion(tag) == null ||
          page == null ||
          page.scheme != 'https' ||
          page.host != 'github.com') {
        Log.info('updates', 'The latest release has no usable tag or page');
        return;
      }
      await _settings.write(
        Settings.latestRelease,
        KnownRelease(tag: tag, url: page.toString()),
      );
    } on Object catch (e) {
      Log.info('updates', 'The update check failed: ${e.runtimeType}');
    }
  }
}
