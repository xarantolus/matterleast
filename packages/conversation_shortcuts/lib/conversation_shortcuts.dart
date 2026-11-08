import 'dart:async';

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

/// Android's long-lived conversation shortcuts. Every call does nothing where
/// the plugin is absent (desktops, tests).
class ConversationShortcuts {
  const ConversationShortcuts();

  static const _channel = MethodChannel('matterleast/conversation_shortcuts');

  /// How many shortcuts Android keeps for the app at once.
  Future<int> maxCount() async => await _call<int>('maxCount') ?? 0;

  Future<Set<String>> published() async =>
      {...?await _call<List<Object?>>('published')}.whereType<String>().toSet();

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

  /// The shortcut a share was sent to, once; untrusted.
  Future<String?> takeShareTarget() => _call<String>('takeShareTarget');

  /// The shortcut the app was opened by, once; untrusted.
  Future<String?> takeLaunch() => _call<String>('takeLaunch');

  /// Calls [onOpened] when a shortcut opens the running app.
  void listen(void Function() onOpened) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'opened') onOpened();
    });
  }

  Future<T?> _call<T>(String method, [Map<String, Object?>? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on MissingPluginException {
      return null;
    }
  }
}
