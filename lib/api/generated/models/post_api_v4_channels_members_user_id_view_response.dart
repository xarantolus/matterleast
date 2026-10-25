// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'post_api_v4_channels_members_user_id_view_response.g.dart';

@JsonSerializable()
class PostApiV4ChannelsMembersUserIdViewResponse {
  const PostApiV4ChannelsMembersUserIdViewResponse({
    this.status,
    this.lastViewedAtTimes,
  });

  factory PostApiV4ChannelsMembersUserIdViewResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV4ChannelsMembersUserIdViewResponseFromJson(json);

  @LenientString()
  final String? status;

  @JsonMap()
  @JsonKey(name: 'last_viewed_at_times')
  final Map<String, Object?>? lastViewedAtTimes;

  Map<String, Object?> toJson() =>
      _$PostApiV4ChannelsMembersUserIdViewResponseToJson(this);
}
