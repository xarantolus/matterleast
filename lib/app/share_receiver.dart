import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/incoming_shares.dart';
import 'package:matterleast/data/files/local_copies.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/screens/share/share_copy_dialog.dart';
import 'package:matterleast/screens/share/share_screen.dart';
import 'package:matterleast/ui/slide_route.dart';
import 'package:share_intake/share_intake.dart';

/// Opens the share screen for each share, with a progress dialog while
/// the phone copies files that take a moment.
class ShareReceiver {
  ShareReceiver(this.navigator, {required this.target});

  final NavigatorState navigator;

  /// The conversation a share names, if it is one of the user's.
  final Future<SwitchItem?> Function(String? id) target;

  StreamSubscription<ShareEvent>? _events;
  final _progress = ValueNotifier(const ShareProgress(0, null));
  Route<void>? _dialog;

  /// Starts taking shares; true when the app was launched by one.
  Future<bool> start(Future<String> cacheDir) async {
    _events = IncomingShares.events.listen((e) => unawaited(_handle(e)));
    return IncomingShares.start(await cacheDir);
  }

  Future<void> _handle(ShareEvent event) async {
    switch (event) {
      case ShareProgress():
        _progress.value = event;
        _showDialog();
      case ShareArrived(:final share):
        _closeDialog();
        await _open(share);
      case ShareFailed(:final message):
        _closeDialog();
        if (!navigator.mounted) return;
        ScaffoldMessenger.maybeOf(navigator.context)?.showSnackBar(
          SnackBar(content: Text("Couldn't take the shared files: $message")),
        );
      case ShareCancelled():
        _closeDialog();
    }
  }

  void _showDialog() {
    if (_dialog != null || !navigator.mounted) return;
    final route = DialogRoute<void>(
      context: navigator.context,
      barrierDismissible: false,
      builder: (_) => ShareCopyDialog(
        progress: _progress,
        onCancel: () => unawaited(IncomingShares.cancel()),
      ),
    );
    _dialog = route;
    unawaited(navigator.push(route));
  }

  void _closeDialog() {
    final route = _dialog;
    _dialog = null;
    if (route != null && route.isActive) navigator.removeRoute(route);
  }

  Future<void> _open(IncomingShare share) async {
    final cacheDir = await LocalCopies.cacheDirectory();
    final shared = sharedContentOf(
      share,
      cacheDir: LocalCopies.resolveDirectory(cacheDir),
      resolve: LocalCopies.resolveFile,
    );
    final channel = await target(share.target);
    if (shared == null || !navigator.mounted) return;
    unawaited(
      navigator.push(
        SlideRoute<void>.page(
          builder: (_) => ShareScreen(shared: shared, target: channel),
        ),
      ),
    );
  }

  void dispose() {
    unawaited(_events?.cancel());
    _progress.dispose();
  }
}
