import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/call_controller.dart';
import 'package:matterleast/screens/calls/call_screen.dart';
import 'package:matterleast/ui/confirm_dialog.dart';

/// Starts or joins the call of [channelId] and opens its screen. While in
/// another call it asks first and leaves that one; in this call already it
/// just opens the screen.
Future<void> joinCall(
  BuildContext context,
  CallController controller, {
  required String url,
  required String channelId,
  bool start = false,
}) async {
  final navigator = Navigator.of(context);
  final current = controller.current.value;
  if (current != null) {
    if (current.url == url && current.channelId == channelId) {
      unawaited(openCallScreen(navigator, url, channelId));
      return;
    }
    final leave = await confirm(
      context,
      title: 'Leave the current call?',
      body: 'You are in another call. Joining this one leaves it.',
      action: 'Leave and join',
    );
    if (!leave) return;
    await controller.leave();
  }
  await controller.askForPermissions();
  if (start) {
    await controller.start(url, channelId);
  } else {
    await controller.join(url, channelId);
  }
  if (navigator.mounted) unawaited(openCallScreen(navigator, url, channelId));
}
