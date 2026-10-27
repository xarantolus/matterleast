// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_channels_channel_id_request_body.g.dart';

@JsonSerializable()
class ApiV4ChannelsChannelIdRequestBody {
  const ApiV4ChannelsChannelIdRequestBody({
    required this.id,
    this.name,
    this.displayName,
    this.purpose,
    this.header,
  });

  factory ApiV4ChannelsChannelIdRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4ChannelsChannelIdRequestBodyFromJson(json);

  final String id;
  @LenientString()
  final String? name;
  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;
  @LenientString()
  final String? purpose;
  @LenientString()
  final String? header;

  Map<String, Object?> toJson() =>
      _$ApiV4ChannelsChannelIdRequestBodyToJson(this);
}
