import 'dart:async';

import 'package:flutter/services.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/sso_callback.dart';
import 'package:matterleast/log.dart';

const browserSignInTimeout = Duration(minutes: 10);

const browserSignInTimedOutText =
    "The sign-in in the browser wasn't finished within 10 minutes. Try again.";

/// Desktop SSO: opens the provider's login in the system browser and waits
/// for the `<scheme>://callback` the browser hands back through the protocol
/// handler. Any web page can launch such a link, so one only counts while a
/// sign-in started here is waiting, once, and when its `accepts` check (the
/// same one the Android redirect goes through) passes.
class BrowserAuthSession {
  BrowserAuthSession({
    required this.launch,
    this.timeout = browserSignInTimeout,
  });

  final Future<bool> Function(Uri url) launch;
  final Duration timeout;
  _Waiting? _waiting;

  /// Matches `OpenAuthSession`. Throws a `CANCELED` [PlatformException] when
  /// [cancel] is called and a [LoginRejected] after [timeout].
  Future<Uri> open(Uri url, String scheme, bool Function(Uri) accepts) async {
    cancel();
    final waiting = _Waiting(scheme, accepts);
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

  /// Hands over a callback link that reached the app; anything that doesn't
  /// finish the waiting sign-in is dropped.
  void deliver(Uri link) {
    final waiting = _waiting;
    if (waiting == null) {
      Log.warn('sso', 'Ignored a sign-in callback: no sign-in is waiting');
    } else if (!isSsoCallbackFor(link, waiting.scheme)) {
      Log.warn('sso', 'Ignored a malformed sign-in callback');
    } else if (!waiting.accepts(link)) {
      Log.warn(
        'sso',
        'Ignored a sign-in callback naming another server or none',
      );
    } else {
      _waiting = null;
      waiting.result.complete(link);
    }
  }

  void cancel() {
    final waiting = _waiting;
    if (waiting == null) return;
    _waiting = null;
    waiting.result.completeError(PlatformException(code: 'CANCELED'));
  }
}

class _Waiting {
  _Waiting(this.scheme, this.accepts);
  final String scheme;
  final bool Function(Uri) accepts;
  final result = Completer<Uri>();
}
