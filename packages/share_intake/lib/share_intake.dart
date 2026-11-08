import 'dart:async';

import 'package:flutter/services.dart';

/// A shared file as the platform copied it into the app's cache.
class SharedFile {
  const SharedFile({required this.path, required this.name, this.mime});

  final String path;
  final String name;
  final String? mime;
}

/// What another app shared. Paths, names and [target] come from the
/// platform and other apps: untrusted.
class IncomingShare {
  const IncomingShare({
    this.text = '',
    this.files = const [],
    this.refused = const [],
    this.target,
  });

  final String text;
  final List<SharedFile> files;

  /// Names of files that could not be copied.
  final List<String> refused;

  /// The conversation picked in the share sheet, if any.
  final String? target;
}

sealed class ShareEvent {
  const ShareEvent();
}

/// A copy is taking a moment: [done] of [total] bytes (null when unknown).
class ShareProgress extends ShareEvent {
  const ShareProgress(this.done, this.total);

  final int done;
  final int? total;
}

class ShareArrived extends ShareEvent {
  const ShareArrived(this.share);

  final IncomingShare share;
}

/// The copy stopped, e.g. the disk is full; [message] is the system's.
class ShareFailed extends ShareEvent {
  const ShareFailed(this.message);

  final String message;
}

class ShareCancelled extends ShareEvent {
  const ShareCancelled();
}

/// Shares from other apps: Android's share intents and the iOS Share
/// Extension. Does nothing where the plugin is absent.
class ShareIntake {
  ShareIntake._() {
    _channel.setMethodCallHandler((call) async {
      final event = eventOf(call.method, call.arguments);
      if (event != null) _events.add(event);
    });
  }

  static final instance = ShareIntake._();

  static const _channel = MethodChannel('matterleast/share_intake');
  final _events = StreamController<ShareEvent>.broadcast();

  Stream<ShareEvent> get events => _events.stream;

  /// Starts delivering shares to [events], copied into
  /// `[cacheDir]/share/<uuid>/`; true when the app was launched by a share.
  Future<bool> start(String cacheDir) async {
    try {
      return await _channel.invokeMethod<bool>('start', {
            'cacheDir': cacheDir,
          }) ??
          false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Stops the copy that is running, which then reports [ShareCancelled].
  Future<void> cancel() async {
    try {
      await _channel.invokeMethod<void>('cancel');
    } on MissingPluginException {
      return;
    }
  }

  /// The event a platform call stands for; null for anything unknown.
  static ShareEvent? eventOf(String method, Object? arguments) {
    final map = arguments is Map ? arguments : const <Object?, Object?>{};
    return switch (method) {
      'progress' => ShareProgress(_int(map['done']) ?? 0, switch (_int(
        map['total'],
      )) {
        final t? when t >= 0 => t,
        _ => null,
      }),
      'shared' => ShareArrived(
        IncomingShare(
          text: _string(map['text']) ?? '',
          files: [
            for (final f in _list(map['files']))
              if (f is Map)
                if ((_string(f['path']), _string(f['name'])) case (
                  final path?,
                  final name?,
                ))
                  SharedFile(
                    path: path,
                    name: name,
                    mime: switch (_string(f['mime'])) {
                      final m? when m.isNotEmpty => m,
                      _ => null,
                    },
                  ),
          ],
          refused: [
            for (final r in _list(map['refused']))
              if (r is String) r,
          ],
          target: _string(map['target']),
        ),
      ),
      'failed' => ShareFailed(_string(map['message']) ?? ''),
      'cancelled' => const ShareCancelled(),
      _ => null,
    };
  }

  static String? _string(Object? value) => value is String ? value : null;
  static int? _int(Object? value) => value is int ? value : null;
  static List<Object?> _list(Object? value) => value is List ? value : const [];
}
