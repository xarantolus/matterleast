// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'reaction.g.dart';

@JsonSerializable()
class Reaction {
  const Reaction({
    this.userId,
    this.postId,
    this.emojiName,
    this.createAt,
    this.channelId,
    this.updateAt,
    this.deleteAt,
    this.remoteId,
  });

  factory Reaction.fromJson(Map<String, Object?> json) =>
      _$ReactionFromJson(json);

  @LenientString()
  @JsonKey(name: 'user_id')
  final String? userId;

  @LenientString()
  @JsonKey(name: 'post_id')
  final String? postId;

  @LenientString()
  @JsonKey(name: 'emoji_name')
  final String? emojiName;

  @MillisDateTime()
  @JsonKey(name: 'create_at')
  final DateTime? createAt;
  @LenientString()
  @JsonKey(name: 'channel_id')
  final String? channelId;
  @MillisDateTime()
  @JsonKey(name: 'update_at')
  final DateTime? updateAt;
  @MillisDateTime()
  @JsonKey(name: 'delete_at')
  final DateTime? deleteAt;
  @LenientString()
  @JsonKey(name: 'remote_id')
  final String? remoteId;

  Map<String, Object?> toJson() => _$ReactionToJson(this);
}
