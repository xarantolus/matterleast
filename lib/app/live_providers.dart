import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/views/profile_views.dart';
import 'package:matterleast/domain/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'live_providers.g.dart';

/// The time now; tests set their own.
@Riverpod(keepAlive: true)
DateTime Function() wallClock(Ref ref) => DateTime.now;

T _follow<T>(Ref ref, ValueListenable<T> value) {
  value.addListener(ref.invalidateSelf);
  ref.onDispose(() => value.removeListener(ref.invalidateSelf));
  return value.value;
}

/// Whether [url]'s server is live: its socket is connected and it answers.
/// Each server decides for itself.
@riverpod
bool serverLive(Ref ref, String url) {
  final session = ref.watch(serverSessionProvider(url)).value;
  return session != null && _follow(ref, session.connection.live);
}

/// The people on [url]'s server whose presence came fresh from it since it
/// last became live; empty while it isn't.
@riverpod
Set<String> knownPresence(Ref ref, String url) {
  final session = ref.watch(serverSessionProvider(url)).value;
  return session == null
      ? const {}
      : _follow(ref, session.connection.presence.known);
}

/// Whether [userId]'s presence on [url]'s server is current: it shows
/// only while the server is live, from what it told since.
@riverpod
bool presenceKnown(Ref ref, String url, String userId) =>
    ref.watch(knownPresenceProvider(url)).contains(userId);

/// Whether the app came back and [url]'s server is catching up on what
/// it may have missed.
@riverpod
bool serverCatchingUp(Ref ref, String url) {
  final session = ref.watch(serverSessionProvider(url)).value;
  return session != null && _follow(ref, session.connection.catchingUp);
}

/// Everyone's custom status on [url]'s server as stored, expired or not.
@Riverpod(keepAlive: true)
Stream<Map<String, CustomStatus>> customStatuses(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* ProfileViews(session.db).customStatuses();
}

/// [userId]'s custom status while it is set and not expired by the clock;
/// it goes at its expiry without a refetch. Nothing where the server has
/// custom statuses turned off.
@riverpod
CustomStatus? activeCustomStatus(Ref ref, String url, String userId) {
  final on = ref.watch(
    featuresProvider(url).select((f) => f.value?.customStatus ?? false),
  );
  if (!on) return null;
  final status = ref.watch(
    customStatusesProvider(url).select((s) => s.value?[userId]),
  );
  if (status == null) return null;
  final now = ref.watch(wallClockProvider)();
  if (!customStatusActive(status, now)) return null;
  final ends = customStatusEnds(status);
  if (ends != null) {
    final timer = Timer(ends.difference(now), ref.invalidateSelf);
    ref.onDispose(timer.cancel);
  }
  return status;
}
