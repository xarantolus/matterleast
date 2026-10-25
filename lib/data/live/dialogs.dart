import 'dart:async';

import 'package:matterleast/api/websocket/dialog.dart';

/// Dialogs integrations open for this user. As in the official app, one is
/// shown only when it answers this device's last command or action, so a
/// command run on another device doesn't pop up here.
class DialogInbox {
  final _dialogs = StreamController<OpenDialog>.broadcast();
  String? _expected;

  /// Dialogs that arrived before the answer naming their trigger: an
  /// integration may open its dialog before it answers the command.
  final _early = <String, (OpenDialog, DateTime)>{};
  static const _earlyFor = Duration(seconds: 30);

  Stream<OpenDialog> get dialogs => _dialogs.stream;

  /// A command or action answered with [triggerId].
  void expect(String triggerId) {
    final now = DateTime.now();
    _early.removeWhere((_, e) => now.difference(e.$2) > _earlyFor);
    final early = _early.remove(triggerId);
    if (early != null) {
      _expected = null;
      if (!_dialogs.isClosed) _dialogs.add(early.$1);
      return;
    }
    _expected = triggerId;
  }

  void offer(OpenDialog dialog) {
    final trigger = dialog.triggerId;
    if (trigger == null || _dialogs.isClosed) return;
    if (trigger != _expected) {
      _early[trigger] = (dialog, DateTime.now());
      return;
    }
    _expected = null;
    _dialogs.add(dialog);
  }

  void close() => unawaited(_dialogs.close());
}
