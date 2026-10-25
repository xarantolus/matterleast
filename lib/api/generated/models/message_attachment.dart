// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'message_attachment_field.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'message_attachment.g.dart';

@JsonSerializable()
class MessageAttachment {
  const MessageAttachment({
    this.fields = const [],
    this.id,
    this.fallback,
    this.color,
    this.pretext,
    this.authorName,
    this.authorLink,
    this.authorIcon,
    this.title,
    this.titleLink,
    this.text,
    this.imageUrl,
    this.thumbUrl,
    this.footer,
    this.footerIcon,
    this.timestamp,
  });

  factory MessageAttachment.fromJson(Map<String, Object?> json) =>
      _$MessageAttachmentFromJson(json);

  @LenientString()
  @JsonKey(name: 'Id')
  final String? id;
  @LenientString()
  @JsonKey(name: 'Fallback')
  final String? fallback;
  @LenientString()
  @JsonKey(name: 'Color')
  final String? color;
  @LenientString()
  @JsonKey(name: 'Pretext')
  final String? pretext;
  @LenientString()
  @JsonKey(name: 'AuthorName')
  final String? authorName;
  @LenientString()
  @JsonKey(name: 'AuthorLink')
  final String? authorLink;
  @LenientString()
  @JsonKey(name: 'AuthorIcon')
  final String? authorIcon;
  @LenientString()
  @JsonKey(name: 'Title')
  final String? title;
  @LenientString()
  @JsonKey(name: 'TitleLink')
  final String? titleLink;
  @LenientString()
  @JsonKey(name: 'Text')
  final String? text;
  @LenientListOfMessageAttachmentField()
  @JsonKey(name: 'Fields')
  final List<MessageAttachmentField> fields;
  @LenientString()
  @JsonKey(name: 'ImageURL')
  final String? imageUrl;
  @LenientString()
  @JsonKey(name: 'ThumbURL')
  final String? thumbUrl;
  @LenientString()
  @JsonKey(name: 'Footer')
  final String? footer;
  @LenientString()
  @JsonKey(name: 'FooterIcon')
  final String? footerIcon;

  @LenientString()
  @JsonKey(name: 'Timestamp')
  final String? timestamp;

  Map<String, Object?> toJson() => _$MessageAttachmentToJson(this);
}
