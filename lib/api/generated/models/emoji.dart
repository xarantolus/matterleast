// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'emoji.g.dart';

@JsonSerializable()
class Emoji {
  const Emoji({
    this.id,
    this.creatorId,
    this.name,
    this.createAt,
    this.updateAt,
    this.deleteAt,
  });

  factory Emoji.fromJson(Map<String, Object?> json) => _$EmojiFromJson(json);

  @LenientString()
  final String? id;

  @LenientString()
  @JsonKey(name: 'creator_id')
  final String? creatorId;

  @LenientString()
  final String? name;

  @MillisDateTime()
  @JsonKey(name: 'create_at')
  final DateTime? createAt;

  @MillisDateTime()
  @JsonKey(name: 'update_at')
  final DateTime? updateAt;

  @MillisDateTime()
  @JsonKey(name: 'delete_at')
  final DateTime? deleteAt;

  Map<String, Object?> toJson() => _$EmojiToJson(this);
}
