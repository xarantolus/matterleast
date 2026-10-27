import 'package:json_annotation/json_annotation.dart';
import 'package:matterleast/api/json/lenient.dart';

part 'github_release.g.dart';

/// The parts of GitHub's `GET /repos/{owner}/{repo}/releases/latest` the
/// update check reads.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class GitHubRelease {
  const GitHubRelease({this.tagName, this.htmlUrl});

  factory GitHubRelease.fromJson(Map<String, Object?> json) =>
      _$GitHubReleaseFromJson(json);

  @LenientString()
  final String? tagName;
  @LenientString()
  final String? htmlUrl;
}
