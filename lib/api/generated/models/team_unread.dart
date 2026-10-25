// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'team_unread.g.dart';

@JsonSerializable()
class TeamUnread {
  const TeamUnread({
    this.teamId,
    this.msgCount,
    this.mentionCount,
    this.msgCountRoot,
    this.mentionCountRoot,
    this.threadCount,
    this.threadMentionCount,
    this.threadUrgentMentionCount,
  });

  factory TeamUnread.fromJson(Map<String, Object?> json) =>
      _$TeamUnreadFromJson(json);

  @LenientString()
  @JsonKey(name: 'team_id')
  final String? teamId;
  @LenientInt()
  @JsonKey(name: 'msg_count')
  final int? msgCount;
  @LenientInt()
  @JsonKey(name: 'mention_count')
  final int? mentionCount;
  @LenientInt()
  @JsonKey(name: 'msg_count_root')
  final int? msgCountRoot;
  @LenientInt()
  @JsonKey(name: 'mention_count_root')
  final int? mentionCountRoot;
  @LenientInt()
  @JsonKey(name: 'thread_count')
  final int? threadCount;
  @LenientInt()
  @JsonKey(name: 'thread_mention_count')
  final int? threadMentionCount;
  @LenientInt()
  @JsonKey(name: 'thread_urgent_mention_count')
  final int? threadUrgentMentionCount;

  Map<String, Object?> toJson() => _$TeamUnreadToJson(this);
}
