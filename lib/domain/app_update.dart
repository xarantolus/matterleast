import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_update.freezed.dart';
part 'app_update.g.dart';

/// The newest release the update check found: its tag, such as `v0.12.0`,
/// and its page on GitHub.
@freezed
abstract class KnownRelease with _$KnownRelease {
  const factory KnownRelease({required String tag, required String url}) =
      _KnownRelease;

  factory KnownRelease.fromJson(Map<String, Object?> json) =>
      _$KnownReleaseFromJson(json);
}

typedef AppVersion = (int major, int minor, int patch);

final _version = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)(?:\+[0-9A-Za-z.-]*)?$');

/// `0.11.1`, `v0.12.0` or `0.11.1+18` as numbers; null for anything else,
/// such as a pre-release tag.
AppVersion? parseVersion(String text) {
  final m = _version.firstMatch(text.trim());
  if (m == null) return null;
  return (int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
}

int compareVersions(AppVersion a, AppVersion b) {
  if (a.$1 != b.$1) return a.$1.compareTo(b.$1);
  if (a.$2 != b.$2) return a.$2.compareTo(b.$2);
  return a.$3.compareTo(b.$3);
}

const updateCheckInterval = Duration(days: 1);

/// Whether a check is due: never checked, a day passed since, or the clock
/// went back.
bool updateCheckDue(DateTime? lastCheck, DateTime now) =>
    lastCheck == null ||
    now.isBefore(lastCheck) ||
    now.difference(lastCheck) >= updateCheckInterval;

/// The release to point out, or null: none known, not newer than the
/// running version, or not newer than the one the user hid.
KnownRelease? updateToShow({
  required String running,
  required KnownRelease? latest,
  required String? dismissed,
}) {
  if (latest == null) return null;
  final newest = parseVersion(latest.tag);
  final current = parseVersion(running);
  if (newest == null || current == null) return null;
  if (compareVersions(newest, current) <= 0) return null;
  final hidden = dismissed == null ? null : parseVersion(dismissed);
  if (hidden != null && compareVersions(newest, hidden) <= 0) return null;
  return latest;
}

/// The version as people read it: `v0.12.0` → `0.12.0`.
String versionLabel(String tag) => tag.startsWith('v') ? tag.substring(1) : tag;
