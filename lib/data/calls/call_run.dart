import 'package:flutter/foundation.dart';
import 'package:matterleast/domain/call_connection.dart';

/// One call from the user's side, whatever carries its media. It runs once;
/// a finished call is replaced by a new run. [connection] is what the
/// screens render.
abstract interface class CallRun {
  ValueNotifier<CallConnection> get connection;

  /// Runs the join; the user may leave at any point.
  Future<void> start();
  Future<void> leave();
  Future<void> setMuted({required bool muted});
  Future<void> setRoute(AudioRoute route);
  Future<void> setDevice({required bool input, required String id});
  Future<void> setHandRaised({required bool raised});
  Future<void> react(String name, String character);
  Future<void> dispose();
}
