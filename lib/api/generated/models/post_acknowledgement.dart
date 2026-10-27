// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'post_acknowledgement.g.dart';

@JsonSerializable()
class PostAcknowledgement {
  const PostAcknowledgement({this.userId, this.postId, this.acknowledgedAt});

  factory PostAcknowledgement.fromJson(Map<String, Object?> json) =>
      _$PostAcknowledgementFromJson(json);

  @LenientString()
  @JsonKey(name: 'user_id')
  final String? userId;
  @LenientString()
  @JsonKey(name: 'post_id')
  final String? postId;
  @MillisDateTime()
  @JsonKey(name: 'acknowledged_at')
  final DateTime? acknowledgedAt;

  Map<String, Object?> toJson() => _$PostAcknowledgementToJson(this);
}
