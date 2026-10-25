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
    this.iconUrl,
    this.gotoLocation,
  });

  factory CommandResponse.fromJson(Map<String, Object?> json) =>
      _$CommandResponseFromJson(json);

  @LenientString()
  @JsonKey(name: 'ResponseType')
  final String? responseType;
  @LenientString()
  @JsonKey(name: 'Text')
  final String? text;
  @LenientString()
  @JsonKey(name: 'Username')
  final String? username;
  @LenientString()
  @JsonKey(name: 'IconURL')
  final String? iconUrl;
  @LenientString()
  @JsonKey(name: 'GotoLocation')
  final String? gotoLocation;
  @LenientListOfMessageAttachment()
  @JsonKey(name: 'Attachments')
  final List<MessageAttachment> attachments;

  Map<String, Object?> toJson() => _$CommandResponseToJson(this);
}
