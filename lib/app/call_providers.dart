import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matterleast/api/json/calls.dart';
import 'package:matterleast/app/live_providers.dart';
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/call_controller.dart';
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

/// Starts and joins calls; null while no part of the app registers one.
@Riverpod(keepAlive: true)
CallController? callController(Ref ref) => null;
