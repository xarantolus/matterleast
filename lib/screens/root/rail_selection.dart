import 'dart:async';

import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rail_selection.g.dart';

/// The team (or server) picked in the rail; null is Home. It starts where
/// the user left it, which the launch gate has read before the rail shows.
@Riverpod(keepAlive: true)
class RailSelection extends _$RailSelection {
  @override
  RailTarget? build() => ref.watch(savedRailTargetProvider).value;

  void select(RailTarget? target) {
    state = target;
    unawaited(
      ref.read(settingsStoreProvider).write(Settings.lastRailTarget, target),
    );
    if (target == null) return;
    unawaited(ref.read(serverManagerProvider).markActive(target.url));
    if (target.teamId case final teamId?) {
      unawaited(
        ref
            .read(channelActionsProvider(target.url).future)
            .then((actions) => actions.selectTeam(teamId)),
      );
    }
  }
}
