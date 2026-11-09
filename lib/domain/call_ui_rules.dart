import 'package:flutter/foundation.dart';
import 'package:matterleast/api/json/calls.dart';

/// Pure: whether the user may use host controls: the server allows them
/// and the user is the call's host or a system admin.
bool hostControlsOpen({
  required CallsConfig? config,
  required String? hostId,
  required String? selfId,
  required bool admin,
}) =>
    config?.hostControlsAllowed == true &&
    (admin || (selfId != null && hostId == selfId));

/// Pure: whether a call that just started rings the user: ringing is on,
/// the channel is a direct or group message and someone else started it.
bool callRings({
  required CallsConfig? config,
  required String? channelType,
  required String? ownerId,
  required String? selfId,
}) =>
    config?.enableRinging == true &&
    (channelType == 'D' || channelType == 'G') &&
    selfId != null &&
    ownerId != selfId;

/// The sessions of a call in the order they joined; equal when the same
/// sessions are in the same order, so a list watching it ignores changes
/// to what one of them does.
class SessionIds {
  const SessionIds(this.ids);
  final List<String> ids;

  @override
  bool operator ==(Object other) =>
      other is SessionIds && listEquals(other.ids, ids);

  @override
  int get hashCode => Object.hashAll(ids);
}
