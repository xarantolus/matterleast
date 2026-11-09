import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/api/json/calls.dart';
import 'package:matterleast/api/websocket/server_events.dart';

part 'calls.freezed.dart';

const callsPluginId = 'com.mattermost.calls';

/// The type of the post a call starts.
const callPostType = 'custom_calls';

/// One connection of a person to a call; a person can be in a call from
/// more than one device.
@freezed
abstract class CallSession with _$CallSession {
  const factory CallSession({
    required String userId,
    @Default(true) bool muted,
    @Default(false) bool speaking,

    /// When the hand went up; 0 while it is down.
    @Default(0) int raisedHand,
  }) = _CallSession;
}

/// A call running in a channel, by the plugin's account of it.
@freezed
abstract class ActiveCall with _$ActiveCall {
  const factory ActiveCall({
    required String id,
    DateTime? startAt,
    String? threadId,
    String? postId,
    String? ownerId,
    String? hostId,
    String? screenSharingSessionId,
    @Default(<String, CallSession>{}) Map<String, CallSession> sessions,
  }) = _ActiveCall;

  const ActiveCall._();

  /// Each person once, in the order they joined, however many devices.
  List<String> get participantUserIds =>
      {for (final s in sessions.values) s.userId}.toList();
}

/// The calls of one server and where calls were switched on or off
/// explicitly; a channel not listed there follows the server's default.
@freezed
abstract class CallsState with _$CallsState {
  const factory CallsState({
    @Default(<String, ActiveCall>{}) Map<String, ActiveCall> calls,
    @Default(<String, bool>{}) Map<String, bool> enabled,
  }) = _CallsState;
}

ActiveCall callOf(CallSnapshot snapshot) => ActiveCall(
  id: snapshot.id,
  startAt: snapshot.startAt,
  threadId: snapshot.threadId,
  postId: snapshot.postId,
  ownerId: snapshot.ownerId,
  hostId: snapshot.hostId,
  screenSharingSessionId: snapshot.screenSharingSessionId,
  sessions: {
    for (final s in snapshot.sessions)
      if (s.sessionId.isNotEmpty)
        s.sessionId: CallSession(
          userId: s.userId,
          muted: s.unmuted != true,
          raisedHand: s.raisedHand ?? 0,
        ),
  },
);

/// Pure: every snapshot of a channel list, as the state they describe.
CallsState callsStateOf(List<CallsChannelState> channels) => CallsState(
  calls: {
    for (final c in channels)
      if (c.channelId.isNotEmpty && c.call != null)
        c.channelId: callOf(c.call!),
  },
  enabled: {
    for (final c in channels)
      if (c.channelId.isNotEmpty && c.enabled != null) c.channelId: c.enabled!,
  },
);

/// Pure: [state] after [event]. An event about a call we don't know leaves
/// the state as it was; the caller fetches that call.
CallsState applyCallEvent(CallsState state, CallsEvent event) {
  final channel = event.channelId;
  final call = state.calls[channel];
  CallsState withCall(ActiveCall? next) {
    if (next == call) return state;
    final calls = {...state.calls};
    if (next == null) {
      calls.remove(channel);
    } else {
      calls[channel] = next;
    }
    return state.copyWith(calls: calls);
  }

  CallsState editSession(
    String sessionId,
    CallSession Function(CallSession) edit,
  ) {
    final session = call?.sessions[sessionId];
    if (call == null || session == null) return state;
    return withCall(
      call.copyWith(sessions: {...call.sessions, sessionId: edit(session)}),
    );
  }

  switch (event) {
    case CallStartedEvent():
      return withCall(
        ActiveCall(
          id: event.id,
          startAt: event.startAt,
          threadId: event.threadId,
          postId: event.postId,
          ownerId: event.ownerId,
          hostId: event.hostId,
          // The event says nothing about who is in the call.
          sessions: call != null && call.id == event.id
              ? call.sessions
              : const {},
        ),
      );
    case CallEndedEvent():
      return withCall(null);
    case CallStateEvent():
      return withCall(callOf(event.call));
    case CallJoinedEvent():
      if (call == null) return state;
      final known = call.sessions[event.sessionId];
      if (known?.userId == event.userId) return state;
      return withCall(
        call.copyWith(
          sessions: {
            ...call.sessions,
            event.sessionId: CallSession(userId: event.userId),
          },
        ),
      );
    case CallLeftEvent():
      if (call == null || !call.sessions.containsKey(event.sessionId)) {
        return state;
      }
      final rest = {
        for (final e in call.sessions.entries)
          if (e.key != event.sessionId) e.key: e.value,
      };
      // The plugin sends no call_end when the last person leaves.
      if (rest.isEmpty) return withCall(null);
      return withCall(
        call.copyWith(
          sessions: rest,
          screenSharingSessionId: call.screenSharingSessionId == event.sessionId
              ? ''
              : call.screenSharingSessionId,
        ),
      );
    case CallMutedEvent():
      return editSession(
        event.sessionId,
        (s) => s.copyWith(muted: event.muted),
      );
    case CallVoiceEvent():
      return editSession(
        event.sessionId,
        (s) => s.copyWith(speaking: event.speaking),
      );
    case CallHandEvent():
      return editSession(
        event.sessionId,
        (s) => s.copyWith(raisedHand: event.raisedAt),
      );
    case CallHostEvent():
      return call == null
          ? state
          : withCall(call.copyWith(hostId: event.hostId));
    case CallScreenEvent():
      if (call == null) return state;
      if (event.sharing) {
        return withCall(call.copyWith(screenSharingSessionId: event.sessionId));
      }
      return call.screenSharingSessionId == event.sessionId
          ? withCall(call.copyWith(screenSharingSessionId: ''))
          : state;
    case CallHostMuteEvent() ||
        CallHostLowerHandEvent() ||
        CallHostRemovedEvent() ||
        CallReactionEvent() ||
        CallNoticeDismissedEvent():
      return state;
    case CallsEnabledEvent():
      return state.enabled[channel] == event.enabled
          ? state
          : state.copyWith(enabled: {...state.enabled, channel: event.enabled});
  }
}

/// Pure: whether calls can be had in a channel. Without a setting of its
/// own a channel follows the server, which allows them.
bool callsEnabledIn({required bool? explicit}) => explicit != false;

/// Pure: whether this user may start a call in a channel with calls
/// enabled: anyone where calls were switched on explicitly or by default,
/// otherwise only system admins.
bool canStartCall({
  required bool? explicit,
  required bool defaultEnabled,
  required bool admin,
}) => explicit == true || defaultEnabled || admin;

enum CallAction { none, start, join }

/// Pure: what the channel offers the user: nothing, starting a call or
/// joining the one that runs. [config] is null until the server's answer.
CallAction callAction({
  required CallsConfig? config,
  required String channelType,
  required bool? explicit,
  required bool live,
  required bool admin,
}) {
  if (config == null || !callsEnabledIn(explicit: explicit)) {
    return CallAction.none;
  }
  if (channelType != 'D' && config.groupCallsAllowed == false) {
    return CallAction.none;
  }
  if (live) return CallAction.join;
  return canStartCall(
        explicit: explicit,
        defaultEnabled: config.defaultEnabled == true,
        admin: admin,
      )
      ? CallAction.start
      : CallAction.none;
}

/// How a call post's card reads.
enum CallCardState { calling, active, noAnswer, canceled, declined, ended }

/// Pure: the card of a call post, from its props, the people in the call
/// and whether the call still runs. A direct message call stays `calling`
/// until a second person is in it.
CallCardState callCardState({
  required DateTime? endAt,
  required String status,
  required int people,
  required bool callExists,
}) {
  final over = endAt != null || !callExists;
  if (over) {
    const byStatus = {
      'no_answer': CallCardState.noAnswer,
      'canceled_by_caller': CallCardState.canceled,
      'declined': CallCardState.declined,
    };
    // Only a post that says it ended carries why; a call that vanished
    // before its post was updated just ended.
    return endAt == null
        ? CallCardState.ended
        : byStatus[status] ?? CallCardState.ended;
  }
  final ringing = status == 'calling' && people < 2;
  return ringing ? CallCardState.calling : CallCardState.active;
}

/// Pure: how long a call lasted in words: "a few seconds", "a minute",
/// "5 minutes", "an hour", "3 hours", "a day", "2 days".
String callDurationLabel(Duration length) {
  final seconds = length.inSeconds;
  final minutes = (seconds / 60).round();
  final hours = (minutes / 60).round();
  String count(int n, String unit) => '$n $unit${n == 1 ? '' : 's'}';
  if (seconds < 45) return 'a few seconds';
  if (seconds < 90) return 'a minute';
  if (minutes < 45) return count(minutes, 'minute');
  if (minutes < 90) return 'an hour';
  if (hours < 22) return count(hours, 'hour');
  if (hours < 36) return 'a day';
  return count((hours / 24).round(), 'day');
}
