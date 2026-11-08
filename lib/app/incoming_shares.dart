import 'package:matterleast/app/platform.dart';
import 'package:share_intake/share_intake.dart';

/// What other apps share into this one: Android's share sheet and the iOS
/// Share Extension. Desktops share nothing this way.
abstract final class IncomingShares {
  static Stream<ShareEvent> get events =>
      isDesktop ? const Stream.empty() : ShareIntake.instance.events;

  /// Starts delivering shares, copied below [cacheDir]; true when the app
  /// was launched by one. Listen to [events] first.
  static Future<bool> start(String cacheDir) async =>
      !isDesktop && await ShareIntake.instance.start(cacheDir);

  static Future<void> cancel() => ShareIntake.instance.cancel();
}

/// Pure: whether [uri] is the iOS Share Extension bringing the app forward;
/// the share itself arrives through [IncomingShares.events].
bool isShareWakeLink(Uri uri) => uri.scheme == 'matterleast-share';
