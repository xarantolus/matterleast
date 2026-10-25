// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post.dart';
import 'user.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'user_thread.g.dart';

@JsonSerializable()
class UserThread {
  const UserThread({
    this.participants = const [],
    this.id,
    this.replyCount,
    this.lastReplyAt,
    this.lastViewedAt,
    this.post,
    this.unreadReplies,
    this.unreadMentions,
    this.isUrgent,
    this.deleteAt,
  });

  factory UserThread.fromJson(Map<String, Object?> json) =>
      _$UserThreadFromJson(json);

  @LenientString()
  final String? id;

  @LenientInt()
  @JsonKey(name: 'reply_count')
  final int? replyCount;

  @MillisDateTime()
  @JsonKey(name: 'last_reply_at')
  final DateTime? lastReplyAt;

  @MillisDateTime()
  @JsonKey(name: 'last_viewed_at')
  final DateTime? lastViewedAt;

  @LenientListOfUser()
  final List<User> participants;
  @LenientPost()
  final Post? post;
  @LenientInt()
  @JsonKey(name: 'unread_replies')
  final int? unreadReplies;
  @LenientInt()
  @JsonKey(name: 'unread_mentions')
  final int? unreadMentions;
  @LenientBool()
  @JsonKey(name: 'is_urgent')
  final bool? isUrgent;
  @MillisDateTime()
  @JsonKey(name: 'delete_at')
  final DateTime? deleteAt;

  Map<String, Object?> toJson() => _$UserThreadToJson(this);
}
