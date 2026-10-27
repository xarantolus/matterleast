// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'command.g.dart';

@JsonSerializable()
class Command {
  const Command({
    this.id,
    this.token,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.creatorId,
    this.teamId,
    this.trigger,
    this.method,
    this.username,
    this.iconUrl,
    this.autoComplete,
    this.autoCompleteDesc,
    this.autoCompleteHint,
    this.displayName,
    this.description,
    this.url,
  });

  factory Command.fromJson(Map<String, Object?> json) =>
      _$CommandFromJson(json);

  @LenientString()
  final String? id;
  @LenientString()
  final String? token;
  @MillisDateTime()
  @JsonKey(name: 'create_at')
  final DateTime? createAt;
  @MillisDateTime()
  @JsonKey(name: 'update_at')
  final DateTime? updateAt;
  @MillisDateTime()
  @JsonKey(name: 'delete_at')
  final DateTime? deleteAt;
  @LenientString()
  @JsonKey(name: 'creator_id')
  final String? creatorId;
  @LenientString()
  @JsonKey(name: 'team_id')
  final String? teamId;
  @LenientString()
  final String? trigger;
  @LenientString()
  final String? method;
  @LenientString()
  final String? username;
  @LenientString()
  @JsonKey(name: 'icon_url')
  final String? iconUrl;
  @LenientBool()
  @JsonKey(name: 'auto_complete')
  final bool? autoComplete;
  @LenientString()
  @JsonKey(name: 'auto_complete_desc')
  final String? autoCompleteDesc;
  @LenientString()
  @JsonKey(name: 'auto_complete_hint')
  final String? autoCompleteHint;
  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;
  @LenientString()
  final String? description;
  @LenientString()
  final String? url;

  Map<String, Object?> toJson() => _$CommandToJson(this);
}
