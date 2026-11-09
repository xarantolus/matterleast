// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'livekit_wire.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveKitSession _$LiveKitSessionFromJson(Map<String, dynamic> json) =>
    LiveKitSession(
      sessionId: json['session_id'] == null
          ? ''
          : stringOrEmpty(json['session_id']),
      token: json['token'] == null ? '' : stringOrEmpty(json['token']),
      url: json['url'] == null ? '' : stringOrEmpty(json['url']),
      botUserId: json['bot_user_id'] == null
          ? ''
          : stringOrEmpty(json['bot_user_id']),
    );

LiveKitRoomMetadata _$LiveKitRoomMetadataFromJson(Map<String, dynamic> json) =>
    LiveKitRoomMetadata(
      hostId: const LenientString().fromJson(json['host_id']),
    );

LiveKitReaction _$LiveKitReactionFromJson(Map<String, dynamic> json) =>
    LiveKitReaction(emojiData: _emojiIn(json['emojiData']));
