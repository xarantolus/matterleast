import 'package:json_annotation/json_annotation.dart';
import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/websocket/encoded.dart';

part 'calls.g.dart';

/// The Calls plugin (`com.mattermost.calls`): its routes and WebSocket
/// payloads. All of it is another party's JSON, read leniently.

/// What `GET /plugins/com.mattermost.calls/config` says to every user.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.pascal)
class CallsConfig {
  const CallsConfig({
    this.defaultEnabled,
    this.groupCallsAllowed,
    this.hostControlsAllowed,
    this.allowScreenSharing,
    this.enableRinging,
    this.maxCallParticipants,
    this.allowEnableCalls,
    this.iceServers = const [],
    this.needsTurnCredentials,
    this.enableDcSignaling,
  });

  factory CallsConfig.fromJson(Map<String, Object?> json) =>
      _$CallsConfigFromJson(json);

  /// Every channel allows calls unless an admin turned them off there.
  @LenientBool()
  final bool? defaultEnabled;

  /// Older plugins don't say; they allow calls in group messages.
  @LenientBool()
  final bool? groupCallsAllowed;
  @LenientBool()
  final bool? hostControlsAllowed;
  @LenientBool()
  final bool? allowScreenSharing;
  @LenientBool()
  final bool? enableRinging;

  /// Zero means no limit.
  @LenientInt()
  final int? maxCallParticipants;
  @LenientBool()
  final bool? allowEnableCalls;

  /// The STUN and TURN servers to connect through.
  @JsonKey(name: 'ICEServersConfigs', fromJson: decodeCallsIceServers)
  final List<CallsIceServer> iceServers;

  /// The server hands out short-lived TURN credentials on request.
  @LenientBool()
  @JsonKey(name: 'NeedsTURNCredentials')
  final bool? needsTurnCredentials;

  /// Offers and answers travel over the data channel once it is open.
  @LenientBool()
  @JsonKey(name: 'EnableDCSignaling')
  final bool? enableDcSignaling;
}

/// A STUN or TURN server for the media connection.
@JsonSerializable(createToJson: false)
class CallsIceServer {
  const CallsIceServer({this.urls = const [], this.username, this.credential});

  factory CallsIceServer.fromJson(Map<String, Object?> json) =>
      _$CallsIceServerFromJson(json);

  @LenientStringList()
  final List<String> urls;
  @LenientString()
  final String? username;
  @LenientString()
  final String? credential;
}

/// The servers of `GET turn-credentials`; one that doesn't read is skipped.
List<CallsIceServer> decodeCallsIceServers(Object? json) =>
    decodeList(json, CallsIceServer.fromJson);

/// One person's connection to a call. A user can be in a call from more
/// than one device, each with its own session.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class SessionSnapshot {
  const SessionSnapshot({
    this.sessionId = '',
    this.userId = '',
    this.unmuted,
    this.raisedHand,
  });

  factory SessionSnapshot.fromJson(Map<String, Object?> json) =>
      _$SessionSnapshotFromJson(json);

  @JsonKey(fromJson: stringOrEmpty)
  final String sessionId;
  @JsonKey(fromJson: stringOrEmpty)
  final String userId;
  @LenientBool()
  final bool? unmuted;

  /// When the hand went up; 0 while it is down.
  @LenientInt()
  final int? raisedHand;
}

/// A running call as the plugin's routes and `call_state` events send it.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class CallSnapshot {
  const CallSnapshot({
    this.id = '',
    this.startAt,
    this.threadId,
    this.postId,
    this.ownerId,
    this.hostId,
    this.screenSharingSessionId,
    this.sessions = const [],
  });

  factory CallSnapshot.fromJson(Map<String, Object?> json) =>
      _$CallSnapshotFromJson(json);

  @JsonKey(fromJson: stringOrEmpty)
  final String id;
  @MillisDateTime()
  final DateTime? startAt;

  /// The call post, which the call's chat replies attach to.
  @LenientString()
  final String? threadId;
  @LenientString()
  final String? postId;
  @LenientString()
  final String? ownerId;
  @LenientString()
  final String? hostId;
  @LenientString()
  final String? screenSharingSessionId;
  @JsonKey(fromJson: _sessions)
  final List<SessionSnapshot> sessions;
}

/// A channel's state from `GET /channels` or `GET /{channel id}`: whether
/// calls were switched on or off there explicitly, and the call running.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class CallsChannelState {
  const CallsChannelState({this.channelId = '', this.enabled, this.call});

  factory CallsChannelState.fromJson(Map<String, Object?> json) =>
      _$CallsChannelStateFromJson(json);

  @JsonKey(fromJson: stringOrEmpty)
  final String channelId;
  @LenientBool()
  final bool? enabled;
  @JsonKey(fromJson: _call)
  final CallSnapshot? call;
}

/// Decodes the channels of `GET /channels`; one that doesn't read is
/// skipped.
List<CallsChannelState> decodeCallsChannels(Object? json) =>
    decodeList(json, CallsChannelState.fromJson);

/// The data of any `custom_com.mattermost.calls_*` event; which fields
/// are there depends on the event.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class CallEventData {
  const CallEventData({
    this.id,
    this.channelIdStart,
    this.channelId,
    this.startAt,
    this.threadId,
    this.postId,
    this.ownerId,
    this.hostId,
    this.hostIdChanged,
    this.userId,
    this.sessionId,
    this.raisedHand,
    this.emoji,
    this.call,
  });

  factory CallEventData.fromJson(Map<String, Object?> json) =>
      _$CallEventDataFromJson(json);

  @LenientString()
  final String? id;

  /// `call_start` names its channel as `channelID`.
  @LenientString()
  @JsonKey(name: 'channelID')
  final String? channelIdStart;

  /// `call_state` names its channel in the data; the others in the
  /// broadcast.
  @LenientString()
  final String? channelId;
  @MillisDateTime()
  final DateTime? startAt;
  @LenientString()
  final String? threadId;
  @LenientString()
  final String? postId;
  @LenientString()
  final String? ownerId;
  @LenientString()
  final String? hostId;

  /// `call_host_changed` says `hostID`.
  @LenientString()
  @JsonKey(name: 'hostID')
  final String? hostIdChanged;
  @LenientString()
  final String? userId;
  @LenientString()
  final String? sessionId;
  @LenientInt()
  final int? raisedHand;

  /// `user_reacted` carries the emoji.
  @_EmojiIn()
  final CallEmojiData? emoji;

  /// `call_state` sends the call as JSON in a string.
  @_CallInString()
  final CallSnapshot? call;
}

/// The emoji of a reaction in a call.
@JsonSerializable(createToJson: false)
class CallEmojiData {
  const CallEmojiData({this.name, this.literal});

  factory CallEmojiData.fromJson(Map<String, Object?> json) =>
      _$CallEmojiDataFromJson(json);

  @LenientString()
  final String? name;

  /// The character itself when the emoji has no short name.
  @LenientString()
  final String? literal;
}

class _EmojiIn implements JsonConverter<CallEmojiData?, Object?> {
  const _EmojiIn();
  @override
  CallEmojiData? fromJson(Object? json) => json is Map<String, Object?>
      ? decodeOrSkip(json, CallEmojiData.fromJson)
      : null;
  @override
  Object? toJson(CallEmojiData? object) => throw UnsupportedError('decode');
}

class _CallInString implements JsonConverter<CallSnapshot?, Object?> {
  const _CallInString();
  @override
  CallSnapshot? fromJson(Object? json) => switch (decodeJsonString(json)) {
    final Map<String, Object?> m => decodeOrSkip(m, CallSnapshot.fromJson),
    _ => null,
  };
  @override
  Object? toJson(CallSnapshot? object) => throw UnsupportedError('decode');
}

/// The props of a call post (`custom_calls`).
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class CallPostProps {
  const CallPostProps({
    this.title,
    this.startAt,
    this.endAt,
    this.callStatus,
    this.participants = const [],
  });

  factory CallPostProps.fromJson(Map<String, Object?> json) =>
      _$CallPostPropsFromJson(json);

  @LenientString()
  final String? title;
  @MillisDateTime()
  final DateTime? startAt;

  /// Set once the call ended.
  @MillisDateTime()
  final DateTime? endAt;

  /// `calling`, `ended`, `no_answer`, `canceled_by_caller` or `declined`;
  /// only direct message calls start as `calling`.
  @LenientString()
  final String? callStatus;
  @LenientStringList()
  final List<String> participants;
}

/// The props of a call post from the post's stored props JSON.
CallPostProps decodeCallPostProps(String? json) =>
    switch (decodeJsonString(json)) {
      final Map<String, Object?> m => decodeOrSkip(m, CallPostProps.fromJson),
      _ => null,
    } ??
    const CallPostProps();

List<SessionSnapshot> _sessions(Object? json) =>
    decodeList(json, SessionSnapshot.fromJson);

CallSnapshot? _call(Object? json) => json is Map<String, Object?>
    ? decodeOrSkip(json, CallSnapshot.fromJson)
    : null;
