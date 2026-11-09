import 'package:flutter/foundation.dart';

/// The call the user is in: which channel on which server.
typedef CallRef = ({String url, String channelId});

/// Starts and joins calls and says which one the user is in. The call
/// itself (media and screen) lives behind it; where none is registered,
/// calls are shown but can't be joined.
abstract interface class CallController {
  /// The call the user is in or joining; null when none.
  ValueListenable<CallRef?> get current;

  Future<void> join(String url, String channelId);

  /// Starts a call in [channelId], under the post [rootId] if given.
  Future<void> start(
    String url,
    String channelId, {
    String? title,
    String? rootId,
  });
}
