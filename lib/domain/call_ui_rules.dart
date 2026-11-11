import 'package:flutter/foundation.dart';
import 'package:matterleast/api/json/calls.dart';

/// Where a call the user is in shows while they look elsewhere.
enum CallSurface {
  /// A bar above the whole app.
  bar,

  /// A small panel at the foot of the channel list's pane.
  dock,
}

/// Pure: a desktop window wide enough for panes docks the call in the
/// channel list, which then stays in view; anything else shows the bar.
CallSurface callSurface({required bool desktop, required bool panes}) =>
    desktop && panes ? CallSurface.dock : CallSurface.bar;

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
