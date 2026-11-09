import 'package:flutter/foundation.dart';
import 'package:matterleast/domain/call_connection.dart';

/// The call the user is in: which channel on which server.
typedef CallRef = ({String url, String channelId});

/// Starts and joins calls and says which one the user is in. The call
/// itself (media and screen) lives behind it; where none is registered,
/// calls are shown but can't be joined.
abstract interface class CallController {
  /// The call the user is in or joining; null when none.
  ValueListenable<CallRef?> get current;

  /// The state of the user's own connection to that call, and how the
  /// last one ended.
  ValueListenable<CallConnection> get connection;

  /// Joins the call in [channelId]; does nothing while in another call.
  Future<void> join(String url, String channelId);

  /// Starts a call in [channelId], under the post [rootId] if given.
  Future<void> start(
    String url,
    String channelId, {
    String? title,
    String? rootId,
  });

  /// Leaves the call, or clears how the last one ended.
  Future<void> leave();

  /// Mutes or unmutes the microphone; ignored when listening only.
  Future<void> setMuted({required bool muted});
  Future<void> setRoute(AudioRoute route);
}
