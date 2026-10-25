import 'dart:async';

import 'package:matterleast/app/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rail_selection.g.dart';

/// The server picked in the rail; null is Home.
@Riverpod(keepAlive: true)
class RailSelection extends _$RailSelection {
  @override
  String? build() => null;

  void select(String? url) {
    state = url;
    if (url != null) unawaited(ref.read(serverManagerProvider).markActive(url));
  }
}
