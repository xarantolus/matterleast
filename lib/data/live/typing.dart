import 'dart:async';

/// Who is writing where, from `typing` events. Kept in memory only; each
/// entry ends after [expiry] unless the person keeps typing, or when their
/// post arrives.
class TypingTracker {
  TypingTracker({this.expiry = defaultExpiry});

  static const defaultExpiry = Duration(seconds: 5);

  /// The server's `TimeBetweenUserTypingUpdatesMilliseconds`, the pace at
  /// which a typing person is announced again.
  Duration expiry;

  final _typing = <(String, String), Map<String, Timer>>{};
  final _changed = StreamController<(String, String)>.broadcast();
  var _closed = false;

  void typing(String channelId, String rootId, String userId) {
    if (_closed) return;
    final key = (channelId, rootId);
    final people = _typing.putIfAbsent(key, () => {});
    final isNew = !people.containsKey(userId);
    people[userId]?.cancel();
    people[userId] = Timer(expiry, () => stopped(channelId, rootId, userId));
    if (isNew) _changed.add(key);
  }

  void stopped(String channelId, String rootId, String userId) {
    final key = (channelId, rootId);
    final people = _typing[key];
    final timer = people?.remove(userId);
    if (timer == null) return;
    timer.cancel();
    if (people!.isEmpty) _typing.remove(key);
    if (!_closed) _changed.add(key);
  }

  /// Ids of the people writing in the channel (empty [rootId]) or thread,
  /// first to start first; emits the current list, then each change.
  Stream<List<String>> watch(String channelId, {String rootId = ''}) {
    final key = (channelId, rootId);
    StreamSubscription<(String, String)>? changes;
    late final StreamController<List<String>> out;
    out = StreamController(
      onListen: () {
        changes = _changed.stream
            .where((k) => k == key)
            .listen((_) => out.add(_now(key)));
        out.add(_now(key));
      },
      onCancel: () async {
        await changes?.cancel();
        await out.close();
      },
    );
    return out.stream;
  }

  List<String> _now((String, String) key) => [...?_typing[key]?.keys];

  void close() {
    _closed = true;
    for (final people in _typing.values) {
      for (final timer in people.values) {
        timer.cancel();
      }
    }
    _typing.clear();
    unawaited(_changed.close());
  }
}
