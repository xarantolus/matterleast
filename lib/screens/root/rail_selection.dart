import 'dart:async';

import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rail_selection.g.dart';

/// The team (or server) picked in the rail; null is Home.
@Riverpod(keepAlive: true)
class RailSelection extends _$RailSelection {
  @override
  RailTarget? build() => null;

  void select(RailTarget? target) {
    state = target;
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
