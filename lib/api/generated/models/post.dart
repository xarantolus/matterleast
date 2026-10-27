// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_metadata.dart';
import 'user.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'post.g.dart';

@JsonSerializable()
class Post {
  const Post({
    this.fileIds = const [],
    this.participants = const [],
    this.id,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.editAt,
    this.userId,
    this.channelId,
    this.rootId,
    this.originalId,
    this.message,
    this.type,
    this.props,
    this.pendingPostId,
    this.metadata,
    this.hashtags,
    this.isPinned,
    this.messageSource,
    this.hasReactions,
    this.remoteId,
    this.replyCount,
    this.lastReplyAt,
    this.isFollowing,
  });

  factory Post.fromJson(Map<String, Object?> json) => _$PostFromJson(json);

  @LenientString()
  final String? id;
  @MillisDateTime()
  @JsonKey(name: 'create_at')
  final DateTime? createAt;
  @MillisDateTime()
  @JsonKey(name: 'update_at')
  final DateTime? updateAt;
  @MillisDateTime()
  @JsonKey(name: 'delete_at')
  final DateTime? deleteAt;
  @MillisDateTime()
  @JsonKey(name: 'edit_at')
  final DateTime? editAt;
  @LenientString()
  @JsonKey(name: 'user_id')
  final String? userId;
  @LenientString()
  @JsonKey(name: 'channel_id')
  final String? channelId;
  @LenientString()
  @JsonKey(name: 'root_id')
  final String? rootId;
  @LenientString()
  @JsonKey(name: 'original_id')
  final String? originalId;
  @LenientString()
  final String? message;
  @LenientString()
  final String? type;
  @JsonMap()
  final Map<String, Object?>? props;
  @LenientStringList()
  @JsonKey(name: 'file_ids')
  final List<String> fileIds;
  @LenientString()
  @JsonKey(name: 'pending_post_id')
  final String? pendingPostId;
  @LenientPostMetadata()
  final PostMetadata? metadata;
  @LenientString()
  final String? hashtags;
  @LenientBool()
  @JsonKey(name: 'is_pinned')
  final bool? isPinned;
  @LenientString()
  @JsonKey(name: 'message_source')
  final String? messageSource;
  @LenientBool()
  @JsonKey(name: 'has_reactions')
  final bool? hasReactions;
  @LenientString()
  @JsonKey(name: 'remote_id')
  final String? remoteId;
  @LenientInt()
  @JsonKey(name: 'reply_count')
  final int? replyCount;
  @MillisDateTime()
  @JsonKey(name: 'last_reply_at')
  final DateTime? lastReplyAt;
  @LenientListOfUser()
  final List<User> participants;
  @LenientBool()
  @JsonKey(name: 'is_following')
  final bool? isFollowing;

  Map<String, Object?> toJson() => _$PostToJson(this);
}
