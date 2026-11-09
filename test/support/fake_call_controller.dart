import 'package:flutter/foundation.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/domain/call_controller.dart';

/// A call controller the test drives: set [connection] and [current], and
/// see what the user asked for.
class FakeCallController implements CallController {
  final currentCall = ValueNotifier<CallRef?>(null);
  final connectionState = ValueNotifier(const CallConnection());

  @override
  ValueListenable<CallRef?> get current => currentCall;

  @override
  ValueListenable<CallConnection> get connection => connectionState;

  /// The server's address, set by the test.
  var url = '';
  final joined = <String>[];
  final started = <String>[];
  final hand = <bool>[];
  final reactions = <String>[];
  var left = 0;
  final muting = <bool>[];

  @override
  Future<void> join(String url, String channelId) async {
    joined.add(channelId);
    currentCall.value = (url: url, channelId: channelId);
  }

  @override
  Future<void> start(
    String url,
    String channelId, {
    String? title,
    String? rootId,
  }) async => started.add(channelId);

  @override
  Future<void> leave() async {
    left++;
    currentCall.value = null;
  }

  @override
  Future<void> setMuted({required bool muted}) async => muting.add(muted);

  @override
  Future<void> setRoute(AudioRoute route) async {}

  final devices = <({bool input, String id})>[];

  @override
  Future<void> setDevice({required bool input, required String id}) async =>
      devices.add((input: input, id: id));

  @override
  Future<void> setHandRaised({required bool raised}) async => hand.add(raised);

  @override
  Future<void> react(String name, String character) async =>
      reactions.add(name);
}
