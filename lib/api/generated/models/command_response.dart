// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'message_attachment.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'command_response.g.dart';

@JsonSerializable()
class CommandResponse {
  const CommandResponse({
    this.attachments = const [],
    this.responseType,
    this.text,
    this.username,
    this.channelId,
    this.iconUrl,
    this.type,
    this.props,
    this.gotoLocation,
    this.triggerId,
    this.skipSlackParsing,
  });

  factory CommandResponse.fromJson(Map<String, Object?> json) =>
      _$CommandResponseFromJson(json);

  @LenientString()
  @JsonKey(name: 'response_type')
  final String? responseType;
  @LenientString()
  final String? text;
  @LenientString()
  final String? username;
  @LenientString()
  @JsonKey(name: 'channel_id')
  final String? channelId;
  @LenientString()
  @JsonKey(name: 'icon_url')
  final String? iconUrl;
  @LenientString()
  final String? type;
  @JsonMap()
  final Map<String, Object?>? props;
  @LenientString()
  @JsonKey(name: 'goto_location')
  final String? gotoLocation;
  @LenientString()
  @JsonKey(name: 'trigger_id')
  final String? triggerId;
  @LenientBool()
  @JsonKey(name: 'skip_slack_parsing')
  final bool? skipSlackParsing;
  @LenientListOfMessageAttachment()
  final List<MessageAttachment> attachments;

  Map<String, Object?> toJson() => _$CommandResponseToJson(this);
}
