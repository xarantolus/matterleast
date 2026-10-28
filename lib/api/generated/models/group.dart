// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'group.g.dart';

@JsonSerializable()
class Group {
  const Group({
    this.id,
    this.name,
    this.displayName,
    this.description,
    this.source,
    this.remoteId,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.hasSyncables,
    this.memberCount,
    this.allowReference,
  });

  factory Group.fromJson(Map<String, Object?> json) => _$GroupFromJson(json);

  @LenientString()
  final String? id;
  @LenientString()
  final String? name;
  @LenientString()
  @JsonKey(name: 'display_name')
  final String? displayName;
  @LenientString()
  final String? description;
  @LenientString()
  final String? source;
  @LenientString()
  @JsonKey(name: 'remote_id')
  final String? remoteId;
  @MillisDateTime()
  @JsonKey(name: 'create_at')
  final DateTime? createAt;
  @MillisDateTime()
  @JsonKey(name: 'update_at')
  final DateTime? updateAt;
  @MillisDateTime()
  @JsonKey(name: 'delete_at')
  final DateTime? deleteAt;
  @LenientBool()
  @JsonKey(name: 'has_syncables')
  final bool? hasSyncables;
  @LenientInt()
  @JsonKey(name: 'member_count')
  final int? memberCount;
  @LenientBool()
  @JsonKey(name: 'allow_reference')
  final bool? allowReference;

  Map<String, Object?> toJson() => _$GroupToJson(this);
}
