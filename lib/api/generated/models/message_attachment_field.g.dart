// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_attachment_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageAttachmentField _$MessageAttachmentFieldFromJson(
  Map<String, dynamic> json,
) => MessageAttachmentField(
  title: const LenientString().fromJson(json['Title']),
  value: const LenientString().fromJson(json['Value']),
  short: const LenientBool().fromJson(json['Short']),
);

Map<String, dynamic> _$MessageAttachmentFieldToJson(
  MessageAttachmentField instance,
) => <String, dynamic>{
  'Title': const LenientString().toJson(instance.title),
  'Value': const LenientString().toJson(instance.value),
  'Short': const LenientBool().toJson(instance.short),
};
