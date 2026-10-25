// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'embeds.dart';
import 'emoji.dart';
import 'file_info.dart';
import 'post_acknowledgement.dart';
import 'post_priority.dart';
import 'reaction.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'post_metadata.g.dart';

@JsonSerializable()
class PostMetadata {
  const PostMetadata({
    this.images,
    this.priority,
    this.expireAt,
    this.redactedFileCount,
    this.embeds = const [],
    this.emojis = const [],
    this.files = const [],
    this.reactions = const [],
    this.acknowledgements = const [],
    this.recipients = const [],
  });

  factory PostMetadata.fromJson(Map<String, Object?> json) =>
      _$PostMetadataFromJson(json);

  @LenientListOfEmbeds()
  final List<Embeds> embeds;

  @LenientListOfEmoji()
  final List<Emoji> emojis;

  @LenientListOfFileInfo()
  final List<FileInfo> files;

  @JsonMap()
  final Map<String, Object?>? images;

  @LenientListOfReaction()
  final List<Reaction> reactions;
  @LenientPostPriority()
  final PostPriority? priority;

  @LenientListOfPostAcknowledgement()
  final List<PostAcknowledgement> acknowledgements;
  @MillisDateTime()
  @JsonKey(name: 'expire_at')
  final DateTime? expireAt;
  @LenientStringList()
  final List<String> recipients;
  @LenientInt()
  @JsonKey(name: 'redacted_file_count')
  final int? redactedFileCount;

  Map<String, Object?> toJson() => _$PostMetadataToJson(this);
}
