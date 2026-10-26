// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_upsert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DraftUpsertRequest _$DraftUpsertRequestFromJson(Map<String, dynamic> json) =>
    DraftUpsertRequest(
      fileIds: json['file_ids'] == null
          ? const []
          : const LenientStringList().fromJson(json['file_ids']),
      channelId: const LenientString().fromJson(json['channel_id']),
      rootId: const LenientString().fromJson(json['root_id']),
      message: const LenientString().fromJson(json['message']),
      type: const LenientString().fromJson(json['type']),
      props: json['props'],
      priority: const LenientPostPriority().fromJson(json['priority']),
    );

Map<String, dynamic> _$DraftUpsertRequestToJson(DraftUpsertRequest instance) =>
    <String, dynamic>{
      'channel_id': const LenientString().toJson(instance.channelId),
      'root_id': const LenientString().toJson(instance.rootId),
      'message': const LenientString().toJson(instance.message),
      'type': const LenientString().toJson(instance.type),
      'props': instance.props,
      'file_ids': const LenientStringList().toJson(instance.fileIds),
      'priority': const LenientPostPriority().toJson(instance.priority),
    };
