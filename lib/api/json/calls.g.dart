// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calls.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallsConfig _$CallsConfigFromJson(Map<String, dynamic> json) => CallsConfig(
  defaultEnabled: const LenientBool().fromJson(json['DefaultEnabled']),
  groupCallsAllowed: const LenientBool().fromJson(json['GroupCallsAllowed']),
  hostControlsAllowed: const LenientBool().fromJson(
    json['HostControlsAllowed'],
  ),
  allowScreenSharing: const LenientBool().fromJson(json['AllowScreenSharing']),
  enableRinging: const LenientBool().fromJson(json['EnableRinging']),
  maxCallParticipants: const LenientInt().fromJson(json['MaxCallParticipants']),
  allowEnableCalls: const LenientBool().fromJson(json['AllowEnableCalls']),
);

SessionSnapshot _$SessionSnapshotFromJson(Map<String, dynamic> json) =>
    SessionSnapshot(
      sessionId: json['session_id'] == null
          ? ''
          : stringOrEmpty(json['session_id']),
      userId: json['user_id'] == null ? '' : stringOrEmpty(json['user_id']),
      unmuted: const LenientBool().fromJson(json['unmuted']),
      raisedHand: const LenientInt().fromJson(json['raised_hand']),
    );

CallSnapshot _$CallSnapshotFromJson(Map<String, dynamic> json) => CallSnapshot(
  id: json['id'] == null ? '' : stringOrEmpty(json['id']),
  startAt: const MillisDateTime().fromJson(json['start_at']),
  threadId: const LenientString().fromJson(json['thread_id']),
  postId: const LenientString().fromJson(json['post_id']),
  ownerId: const LenientString().fromJson(json['owner_id']),
  hostId: const LenientString().fromJson(json['host_id']),
  screenSharingSessionId: const LenientString().fromJson(
    json['screen_sharing_session_id'],
  ),
  sessions: json['sessions'] == null ? const [] : _sessions(json['sessions']),
);

CallsChannelState _$CallsChannelStateFromJson(Map<String, dynamic> json) =>
    CallsChannelState(
      channelId: json['channel_id'] == null
          ? ''
          : stringOrEmpty(json['channel_id']),
      enabled: const LenientBool().fromJson(json['enabled']),
      call: _call(json['call']),
    );

CallEventData _$CallEventDataFromJson(Map<String, dynamic> json) =>
    CallEventData(
      id: const LenientString().fromJson(json['id']),
      channelIdStart: const LenientString().fromJson(json['channelID']),
      channelId: const LenientString().fromJson(json['channel_id']),
      startAt: const MillisDateTime().fromJson(json['start_at']),
      threadId: const LenientString().fromJson(json['thread_id']),
      postId: const LenientString().fromJson(json['post_id']),
      ownerId: const LenientString().fromJson(json['owner_id']),
      hostId: const LenientString().fromJson(json['host_id']),
      hostIdChanged: const LenientString().fromJson(json['hostID']),
      userId: const LenientString().fromJson(json['user_id']),
      sessionId: const LenientString().fromJson(json['session_id']),
      raisedHand: const LenientInt().fromJson(json['raised_hand']),
      call: const _CallInString().fromJson(json['call']),
    );

CallPostProps _$CallPostPropsFromJson(Map<String, dynamic> json) =>
    CallPostProps(
      title: const LenientString().fromJson(json['title']),
      startAt: const MillisDateTime().fromJson(json['start_at']),
      endAt: const MillisDateTime().fromJson(json['end_at']),
      callStatus: const LenientString().fromJson(json['call_status']),
      participants: json['participants'] == null
          ? const []
          : const LenientStringList().fromJson(json['participants']),
    );
