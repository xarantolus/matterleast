import 'dart:async';

import 'package:matterleast/api/websocket/dialog.dart';
import 'package:matterleast/domain/dialog_rules.dart';

/// Dialogs integrations open for this user. As in the official app, one is
/// shown only when it answers this device's last command or action, so a
/// command run on another device doesn't pop up here. Dialogs stack, and
/// only [maxOpenDialogs] are shown at once.
class DialogInbox {
  final _dialogs = StreamController<OpenDialog>.broadcast();

  /// Triggers answered to this device whose dialog hasn't arrived, oldest
  /// first; a button pressed twice before the first dialog shows keeps both.
  final _expected = <String>[];
  static const _expectedMax = 6;

  /// Dialogs that arrived before the answer naming their trigger: an
  /// integration may open its dialog before it answers the command.
  final _early = <String, (OpenDialog, DateTime)>{};
  static const _earlyFor = Duration(seconds: 30);

  var _open = 0;

  Stream<OpenDialog> get dialogs => _dialogs.stream;

  /// Whether another dialog may be shown over the ones open now.
  bool get canOpen => canOpenDialog(_open);

  /// A dialog was put on screen; call [closed] when it leaves.
  void opened() => _open++;
  void closed() => _open--;

  /// A command or action answered with [triggerId].
  void expect(String triggerId) {
    final now = DateTime.now();
    _early.removeWhere((_, e) => now.difference(e.$2) > _earlyFor);
    final early = _early.remove(triggerId);
    if (early != null) {
      if (!_dialogs.isClosed) _dialogs.add(early.$1);
      return;
    }
    _expected.add(triggerId);
    if (_expected.length > _expectedMax) _expected.removeAt(0);
  }

  void offer(OpenDialog dialog) {
    final trigger = dialog.triggerId;
    if (trigger == null || _dialogs.isClosed) return;
    if (!_expected.remove(trigger)) {
      _early[trigger] = (dialog, DateTime.now());
      return;
    }
    _dialogs.add(dialog);
  }

  void close() => unawaited(_dialogs.close());
}
