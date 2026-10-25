// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_v4_channels_channel_id_members_user_id_autotranslation_request_body.g.dart';

@JsonSerializable()
class ApiV4ChannelsChannelIdMembersUserIdAutotranslationRequestBody {
  const ApiV4ChannelsChannelIdMembersUserIdAutotranslationRequestBody({
    required this.autotranslationDisabled,
  });

  factory ApiV4ChannelsChannelIdMembersUserIdAutotranslationRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4ChannelsChannelIdMembersUserIdAutotranslationRequestBodyFromJson(
    json,
  );

  @JsonKey(name: 'autotranslation_disabled')
  final bool autotranslationDisabled;

  Map<String, Object?> toJson() =>
      _$ApiV4ChannelsChannelIdMembersUserIdAutotranslationRequestBodyToJson(
        this,
      );
}
