// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_v4_channels_group_search_request_body.g.dart';

@JsonSerializable()
class ApiV4ChannelsGroupSearchRequestBody {
  const ApiV4ChannelsGroupSearchRequestBody({required this.term});

  factory ApiV4ChannelsGroupSearchRequestBody.fromJson(
    Map<String, Object?> json,
  ) => _$ApiV4ChannelsGroupSearchRequestBodyFromJson(json);

  final String term;

  Map<String, Object?> toJson() =>
      _$ApiV4ChannelsGroupSearchRequestBodyToJson(this);
}
