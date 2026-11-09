import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matterleast/api/json/calls.dart';
import 'package:matterleast/app/live_providers.dart';
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/calls/call_peer.dart';
import 'package:matterleast/data/calls/call_platform.dart';
import 'package:matterleast/data/calls/rtc_call_controller.dart';
import 'package:matterleast/domain/call_controller.dart';
import 'package:matterleast/domain/call_ui_rules.dart';
import 'package:matterleast/domain/calls.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'call_providers.g.dart';

/// Whether the server runs the Calls plugin. False while unknown, so
/// nothing shows that might vanish.
@riverpod
bool callsAvailable(Ref ref, String url) =>
    ref.watch(featuresProvider(url)).value?.calls ?? false;

/// The server's Calls settings; null until they arrived.
@riverpod
CallsConfig? callsConfig(Ref ref, String url) {
  final session = ref.watch(serverSessionProvider(url)).value;
  return session == null
      ? null
      : followValue(ref, session.connection.calls.config);
}

@riverpod
CallsState callsState(Ref ref, String url) {
  final session = ref.watch(serverSessionProvider(url)).value;
  return session == null
      ? const CallsState()
      : followValue(ref, session.connection.calls.state);
}

/// The call running in [channelId], if any.
@riverpod
ActiveCall? callInChannel(Ref ref, String url, String channelId) => ref.watch(
  callsStateProvider(url).select((state) => state.calls[channelId]),
);

/// The running call whose post is [postId], with its channel.
@riverpod
({String channelId, ActiveCall call})? callOfPost(
  Ref ref,
  String url,
  String postId,
) => ref.watch(
  callsStateProvider(url).select((state) {
    for (final e in state.calls.entries) {
      if (e.value.postId == postId) return (channelId: e.key, call: e.value);
    }
    return null;
  }),
);

/// Whether a call runs in [channelId] on a server with the plugin.
@riverpod
bool channelHasCall(Ref ref, String url, String channelId) =>
    ref.watch(callsAvailableProvider(url)) &&
    ref.watch(callInChannelProvider(url, channelId)) != null;

/// What [channelId] offers the user: starting a call, joining the one
/// that runs, or nothing.
@riverpod
CallAction callActionIn(
  Ref ref,
  String url,
  String channelId,
  String channelType,
) {
  if (!ref.watch(callsAvailableProvider(url))) return CallAction.none;
  return callAction(
    config: ref.watch(callsConfigProvider(url)),
    channelType: channelType,
    explicit: ref.watch(
      callsStateProvider(url).select((state) => state.enabled[channelId]),
    ),
    live: ref.watch(callInChannelProvider(url, channelId)) != null,
    admin: ref.watch(systemAdminProvider(url)).value ?? false,
  );
}

/// Who is in the call of [channelId], in the order they joined.
@riverpod
SessionIds callSessionIds(Ref ref, String url, String channelId) => ref.watch(
  callsStateProvider(
    url,
  ).select((state) => SessionIds([...?state.calls[channelId]?.sessions.keys])),
);

/// One person's connection to the call of [channelId].
@riverpod
CallSession? callSessionOf(
  Ref ref,
  String url,
  String channelId,
  String sessionId,
) => ref.watch(
  callsStateProvider(url)
      .select((state) => state.calls[channelId]?.sessions[sessionId]),
);

/// The host of the call of [channelId].
@riverpod
String? callHost(Ref ref, String url, String channelId) => ref.watch(
  callsStateProvider(url).select((state) => state.calls[channelId]?.hostId),
);

/// How many hands are up in the call of [channelId].
@riverpod
int callHandsUp(Ref ref, String url, String channelId) => ref.watch(
  callsStateProvider(url).select(
    (state) =>
        [...?state.calls[channelId]?.sessions.values]
            .where((s) => s.raisedHand > 0)
            .length,
  ),
);

/// The session that shares its screen in the call of [channelId], if any.
@riverpod
String callScreenSharer(Ref ref, String url, String channelId) => ref.watch(
  callsStateProvider(url)
      .select((state) => state.calls[channelId]?.screenSharingSessionId ?? ''),
);

/// The emoji [sessionId] shows right now.
@riverpod
String? callReaction(Ref ref, String url, String sessionId) {
  final session = ref.watch(serverSessionProvider(url)).value;
  if (session == null) return null;
  return ref.watch(
    _reactionsProvider(url).select((reactions) => reactions[sessionId]),
  );
}

@riverpod
Map<String, String> _reactions(Ref ref, String url) {
  final session = ref.watch(serverSessionProvider(url)).value;
  return session == null
      ? const {}
      : followValue(ref, session.connection.calls.reactions);
}

/// The calls that ring the user on [url]'s server, by channel.
@riverpod
Map<String, ActiveCall> incomingCalls(Ref ref, String url) {
  final session = ref.watch(serverSessionProvider(url)).value;
  return session == null
      ? const {}
      : followValue(ref, session.connection.calls.incoming);
}

/// Whether the call screen is the page the user looks at; the bar hides
/// then.
@Riverpod(keepAlive: true)
class CallScreenOpen extends _$CallScreenOpen {
  @override
  int build() => 0;

  void opened() => state++;
  void closed() {
    if (ref.mounted) state--;
  }
}

/// Starts and joins calls; null where the app can't.
@Riverpod(keepAlive: true)
CallController? callController(Ref ref) {
  final controller = RtcCallController(
    sessionOf: (url) => ref.read(serverSessionProvider(url).future),
    platform: PhoneCallPlatform(),
    createPeer: WebRtcPeer.new,
    network: ref.watch(networkStateProvider),
  );
  ref.onDispose(() => unawaited(controller.dispose()));
  return controller;
}
