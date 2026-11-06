import 'dart:async';

import 'package:flutter/services.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/log.dart';

const browserSignInTimeout = Duration(minutes: 10);

const browserSignInTimedOutText =
    "The sign-in in the browser wasn't finished within 10 minutes. Try again.";

/// SSO: opens the provider's login in the browser (a Custom Tab on Android)
/// and waits for the `<scheme>://callback` the browser hands back to the app. Any web page can launch such a link, so one only counts while a
/// sign-in started here is waiting, and only once: the first one ends the
/// wait, and the sign-in checks it like the Android redirect, so a callback
/// that fails those checks says why instead of leaving the user waiting.
class BrowserAuthSession {
  BrowserAuthSession({
    required this.launch,
    this._launchExternal,
    this.onReturn,
    this.timeout = browserSignInTimeout,
  });

  final Future<bool> Function(Uri url) launch;
  final Future<bool> Function(Uri url)? _launchExternal;

  /// Called when a callback ends the wait, to bring the app back over the
  /// browser.
  final void Function()? onReturn;
  final Duration timeout;
  _Waiting? _waiting;

  /// Matches `OpenAuthSession`. Throws a `CANCELED` [PlatformException] when
  /// [cancel] is called and a [LoginRejected] after [timeout].
  Future<Uri> open(Uri url, String scheme) => _open(url, launch);

  /// Like [open], in the full browser, for servers that ask for it.
  Future<Uri> openExternal(Uri url, String scheme) =>
      _open(url, _launchExternal ?? launch);

  Future<Uri> _open(Uri url, Future<bool> Function(Uri url) launch) async {
    cancel();
    final waiting = _Waiting();
    _waiting = waiting;
    final result = waiting.result.future.timeout(
      timeout,
      onTimeout: () => throw const LoginRejected(browserSignInTimedOutText),
    )..ignore();
    try {
      if (!await launch(url)) {
        throw PlatformException(code: 'LAUNCH_FAILED');
      }
      return await result;
    } finally {
      if (identical(_waiting, waiting)) _waiting = null;
    }
  }

  /// Hands over a callback link that reached the app. It ends a waiting
  /// sign-in and returns true; with none waiting it returns false.
  bool deliver(Uri link) {
    final waiting = _waiting;
    if (waiting == null) return false;
    Log.info('sso', 'A sign-in callback arrived');
    _waiting = null;
    waiting.result.complete(link);
    onReturn?.call();
    return true;
  }

  void cancel() {
    final waiting = _waiting;
    if (waiting == null) return;
    _waiting = null;
    waiting.result.completeError(PlatformException(code: 'CANCELED'));
  }
}

class _Waiting {
  final result = Completer<Uri>();
}
