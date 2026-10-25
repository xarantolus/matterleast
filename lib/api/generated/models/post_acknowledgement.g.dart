// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_acknowledgement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostAcknowledgement _$PostAcknowledgementFromJson(Map<String, dynamic> json) =>
    PostAcknowledgement(
      userId: const LenientString().fromJson(json['user_id']),
      postId: const LenientString().fromJson(json['post_id']),
      acknowledgedAt: const MillisDateTime().fromJson(json['acknowledged_at']),
    );

Map<String, dynamic> _$PostAcknowledgementToJson(
  PostAcknowledgement instance,
) => <String, dynamic>{
  'user_id': const LenientString().toJson(instance.userId),
  'post_id': const LenientString().toJson(instance.postId),
  'acknowledged_at': const MillisDateTime().toJson(instance.acknowledgedAt),
};
