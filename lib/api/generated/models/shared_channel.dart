// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'shared_channel.g.dart';

@JsonSerializable()
class SharedChannel {
  const SharedChannel({
    this.id,
    this.teamId,
    this.home,
    this.readonly,
    this.name,
    this.displayName,
    this.purpose,
    this.header,
    this.creatorId,
    this.createAt,
    this.updateAt,
    this.remoteId,
  });

  factory SharedChannel.fromJson(Map<String, Object?> json) =>
      _$SharedChannelFromJson(json);

  @LenientString()
  final String? id;
  @LenientString()
  @JsonKey(name: 'team_id')
  final String? teamId;

  @LenientBool()
  final bool? home;

  @LenientBool()
  final bool? readonly;

  @LenientString()
  final String? name;

  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;
  @LenientString()
  final String? purpose;
  @LenientString()
  final String? header;

  @LenientString()
  @JsonKey(name: 'creator_id')
  final String? creatorId;

  @MillisDateTime()
  @JsonKey(name: 'create_at')
  final DateTime? createAt;

  @MillisDateTime()
  @JsonKey(name: 'update_at')
  final DateTime? updateAt;

  @LenientString()
  @JsonKey(name: 'remote_id')
  final String? remoteId;

  Map<String, Object?> toJson() => _$SharedChannelToJson(this);
}
