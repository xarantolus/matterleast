import 'package:matterleast/app/platform.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// What other apps share into this one. Android only: iOS would need a
/// Share Extension, and desktops share nothing this way.
abstract final class IncomingShares {
  /// The share the app was launched with; empty when none.
  static Future<List<SharedMediaFile>> initial() async => !hasAndroidServices
      ? const []
      : ReceiveSharingIntent.instance.getInitialMedia();

  /// Shares arriving while the app runs.
  static Stream<List<SharedMediaFile>> later() => !hasAndroidServices
      ? const Stream.empty()
      : ReceiveSharingIntent.instance.getMediaStream();

  /// Forgets the launch share, so it is not handled again.
  static Future<void> reset() async {
    if (!hasAndroidServices) return;
    await ReceiveSharingIntent.instance.reset();
  }
}
