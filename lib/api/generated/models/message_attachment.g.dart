// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageAttachment _$MessageAttachmentFromJson(Map<String, dynamic> json) =>
    MessageAttachment(
      fields: json['Fields'] == null
          ? const []
          : const LenientListOfMessageAttachmentField().fromJson(
              json['Fields'],
            ),
      id: const LenientString().fromJson(json['Id']),
      fallback: const LenientString().fromJson(json['Fallback']),
      color: const LenientString().fromJson(json['Color']),
      pretext: const LenientString().fromJson(json['Pretext']),
      authorName: const LenientString().fromJson(json['AuthorName']),
      authorLink: const LenientString().fromJson(json['AuthorLink']),
      authorIcon: const LenientString().fromJson(json['AuthorIcon']),
      title: const LenientString().fromJson(json['Title']),
      titleLink: const LenientString().fromJson(json['TitleLink']),
      text: const LenientString().fromJson(json['Text']),
      imageUrl: const LenientString().fromJson(json['ImageURL']),
      thumbUrl: const LenientString().fromJson(json['ThumbURL']),
      footer: const LenientString().fromJson(json['Footer']),
      footerIcon: const LenientString().fromJson(json['FooterIcon']),
      timestamp: const LenientString().fromJson(json['Timestamp']),
    );

Map<String, dynamic> _$MessageAttachmentToJson(
  MessageAttachment instance,
) => <String, dynamic>{
  'Id': const LenientString().toJson(instance.id),
  'Fallback': const LenientString().toJson(instance.fallback),
  'Color': const LenientString().toJson(instance.color),
  'Pretext': const LenientString().toJson(instance.pretext),
  'AuthorName': const LenientString().toJson(instance.authorName),
  'AuthorLink': const LenientString().toJson(instance.authorLink),
  'AuthorIcon': const LenientString().toJson(instance.authorIcon),
  'Title': const LenientString().toJson(instance.title),
  'TitleLink': const LenientString().toJson(instance.titleLink),
  'Text': const LenientString().toJson(instance.text),
  'Fields': const LenientListOfMessageAttachmentField().toJson(instance.fields),
  'ImageURL': const LenientString().toJson(instance.imageUrl),
  'ThumbURL': const LenientString().toJson(instance.thumbUrl),
  'Footer': const LenientString().toJson(instance.footer),
  'FooterIcon': const LenientString().toJson(instance.footerIcon),
  'Timestamp': const LenientString().toJson(instance.timestamp),
};
