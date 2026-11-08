import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A conversation as a shortcut: a [label], a picture (round PNG) and whether
/// it is a group, which Android shows without a person.
class ShortcutSpec {
  const ShortcutSpec({
    required this.id,
    required this.label,
    required this.rank,
    this.icon,
    this.group = false,
  });

  final String id;
  final String label;
  final int rank;
  final Uint8List? icon;
  final bool group;
}

/// Android's long-lived conversation shortcuts; on iOS the conversations
/// a message arrives in are donated for share-sheet suggestions. Every
/// call does nothing on other platforms and where the plugin is absent
/// (tests).
class ConversationShortcuts {
  const ConversationShortcuts();

  static const _channel = MethodChannel('matterleast/conversation_shortcuts');

  /// How many shortcuts Android keeps for the app at once.
  Future<int> maxCount() async => await _call<int>('maxCount') ?? 0;

  Future<Set<String>> published() async =>
      {...?await _call<List<Object?>>('published')}.whereType<String>().toSet();

  /// Publishes [spec] on Android; on iOS donates a message received in it.
  Future<void> push(ShortcutSpec spec) => _call('push', {
    'id': spec.id,
    'label': spec.label,
    'rank': spec.rank,
    'icon': spec.icon,
    'group': spec.group,
  });

  Future<void> remove(Iterable<String> ids) =>
      _call('remove', {'ids': ids.toList()});

  /// Tells Android the user opened or wrote in [id], which ranks it higher.
  Future<void> reportUsed(String id) => _call('reportUsed', {'id': id});

  /// The shortcut the app was opened by, once; untrusted.
  Future<String?> takeLaunch() => _call<String>('takeLaunch');

  /// Withdraws what iOS was told about the conversations of [serverUrl].
  Future<void> forgetServer(String serverUrl) =>
      _call('forgetServer', {'serverUrl': serverUrl});

  /// Calls [onOpened] when a shortcut opens the running app.
  void listen(void Function() onOpened) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'opened') onOpened();
    });
  }

  Future<T?> _call<T>(String method, [Map<String, Object?>? arguments]) async {
    final supported = switch (defaultTargetPlatform) {
      TargetPlatform.android => method != 'forgetServer',
      TargetPlatform.iOS => const {'push', 'forgetServer'}.contains(method),
      _ => false,
    };
    if (!supported) return null;
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on MissingPluginException {
      return null;
    }
  }
}
