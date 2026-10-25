// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_posts_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4PostsRequestBody _$ApiV4PostsRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4PostsRequestBody(
  channelId: json['channel_id'] as String,
  message: json['message'] as String,
  fileIds: json['file_ids'] == null
      ? const []
      : const LenientStringList().fromJson(json['file_ids']),
  rootId: const LenientString().fromJson(json['root_id']),
  props: const JsonMap().fromJson(json['props']),
  metadata: const LenientMetadata().fromJson(json['metadata']),
);

Map<String, dynamic> _$ApiV4PostsRequestBodyToJson(
  ApiV4PostsRequestBody instance,
) => <String, dynamic>{
  'channel_id': instance.channelId,
  'message': instance.message,
  'root_id': const LenientString().toJson(instance.rootId),
  'file_ids': const LenientStringList().toJson(instance.fileIds),
  'props': const JsonMap().toJson(instance.props),
  'metadata': const LenientMetadata().toJson(instance.metadata),
};
