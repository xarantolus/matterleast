import 'dart:async';

import 'package:matterleast/api/websocket/dialog.dart';

/// Dialogs integrations open for this user. As in the official app, one is
/// shown only when it answers this device's last command or action, so a
/// command run on another device doesn't pop up here.
class DialogInbox {
  final _dialogs = StreamController<OpenDialog>.broadcast();
  String? _expected;

  Stream<OpenDialog> get dialogs => _dialogs.stream;

  /// A command or action answered with [triggerId].
  void expect(String triggerId) => _expected = triggerId;

  void offer(OpenDialog dialog) {
    final trigger = dialog.triggerId;
    if (trigger == null || trigger != _expected || _dialogs.isClosed) return;
    _expected = null;
    _dialogs.add(dialog);
  }

  void close() => unawaited(_dialogs.close());
}
