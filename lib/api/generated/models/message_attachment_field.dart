// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'message_attachment_field.g.dart';

@JsonSerializable()
class MessageAttachmentField {
  const MessageAttachmentField({this.title, this.value, this.short});

  factory MessageAttachmentField.fromJson(Map<String, Object?> json) =>
      _$MessageAttachmentFieldFromJson(json);

  @LenientString()
  @JsonKey(name: 'Title')
  final String? title;
  @LenientString()
  @JsonKey(name: 'Value')
  final String? value;
  @LenientBool()
  @JsonKey(name: 'Short')
  final bool? short;

  Map<String, Object?> toJson() => _$MessageAttachmentFieldToJson(this);
}
