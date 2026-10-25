// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostMetadata _$PostMetadataFromJson(Map<String, dynamic> json) => PostMetadata(
  images: const JsonMap().fromJson(json['images']),
  priority: const LenientPostPriority().fromJson(json['priority']),
  expireAt: const MillisDateTime().fromJson(json['expire_at']),
  redactedFileCount: const LenientInt().fromJson(json['redacted_file_count']),
  embeds: json['embeds'] == null
      ? const []
      : const LenientListOfEmbeds().fromJson(json['embeds']),
  emojis: json['emojis'] == null
      ? const []
      : const LenientListOfEmoji().fromJson(json['emojis']),
  files: json['files'] == null
      ? const []
      : const LenientListOfFileInfo().fromJson(json['files']),
  reactions: json['reactions'] == null
      ? const []
      : const LenientListOfReaction().fromJson(json['reactions']),
  acknowledgements: json['acknowledgements'] == null
      ? const []
      : const LenientListOfPostAcknowledgement().fromJson(
          json['acknowledgements'],
        ),
  recipients: json['recipients'] == null
      ? const []
      : const LenientStringList().fromJson(json['recipients']),
);

Map<String, dynamic> _$PostMetadataToJson(
  PostMetadata instance,
) => <String, dynamic>{
  'embeds': const LenientListOfEmbeds().toJson(instance.embeds),
  'emojis': const LenientListOfEmoji().toJson(instance.emojis),
  'files': const LenientListOfFileInfo().toJson(instance.files),
  'images': const JsonMap().toJson(instance.images),
  'reactions': const LenientListOfReaction().toJson(instance.reactions),
  'priority': const LenientPostPriority().toJson(instance.priority),
  'acknowledgements': const LenientListOfPostAcknowledgement().toJson(
    instance.acknowledgements,
  ),
  'expire_at': const MillisDateTime().toJson(instance.expireAt),
  'recipients': const LenientStringList().toJson(instance.recipients),
  'redacted_file_count': const LenientInt().toJson(instance.redactedFileCount),
};
