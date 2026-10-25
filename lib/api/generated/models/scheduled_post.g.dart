// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduledPost _$ScheduledPostFromJson(Map<String, dynamic> json) =>
    ScheduledPost(
      fileIds: json['file_ids'] == null
          ? const []
          : const LenientStringList().fromJson(json['file_ids']),
      id: const LenientString().fromJson(json['id']),
      createAt: const MillisDateTime().fromJson(json['create_at']),
      updateAt: const MillisDateTime().fromJson(json['update_at']),
      userId: const LenientString().fromJson(json['user_id']),
      channelId: const LenientString().fromJson(json['channel_id']),
      rootId: const LenientString().fromJson(json['root_id']),
      message: const LenientString().fromJson(json['message']),
      props: const JsonMap().fromJson(json['props']),
      scheduledAt: const MillisDateTime().fromJson(json['scheduled_at']),
      processedAt: const MillisDateTime().fromJson(json['processed_at']),
      errorCode: const LenientString().fromJson(json['error_code']),
      repeatType: const LenientString().fromJson(json['repeat_type']),
      repeatTimezone: const LenientString().fromJson(json['repeat_timezone']),
      metadata: const LenientPostMetadata().fromJson(json['metadata']),
    );

Map<String, dynamic> _$ScheduledPostToJson(ScheduledPost instance) =>
    <String, dynamic>{
      'id': const LenientString().toJson(instance.id),
      'create_at': const MillisDateTime().toJson(instance.createAt),
      'update_at': const MillisDateTime().toJson(instance.updateAt),
      'user_id': const LenientString().toJson(instance.userId),
      'channel_id': const LenientString().toJson(instance.channelId),
      'root_id': const LenientString().toJson(instance.rootId),
      'message': const LenientString().toJson(instance.message),
      'props': const JsonMap().toJson(instance.props),
      'file_ids': const LenientStringList().toJson(instance.fileIds),
      'scheduled_at': const MillisDateTime().toJson(instance.scheduledAt),
      'processed_at': const MillisDateTime().toJson(instance.processedAt),
      'error_code': const LenientString().toJson(instance.errorCode),
      'repeat_type': const LenientString().toJson(instance.repeatType),
      'repeat_timezone': const LenientString().toJson(instance.repeatTimezone),
      'metadata': const LenientPostMetadata().toJson(instance.metadata),
    };
