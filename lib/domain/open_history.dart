import 'package:matterleast/domain/conversation_restore.dart';
import 'package:matterleast/domain/rail.dart';

/// The message at the bottom of the screen and its bottom edge's offset.
typedef ReadingAt = ({String postId, double offset});

/// A conversation or thread with the reading position, or Home or a team's list.
class Location {
  const Location({
    this.place,
    this.conversation,
    this.highlightPostId,
    this.at,
  });

  final RailTarget? place;
  final SavedConversation? conversation;

  /// The message it was opened at; reopening shows it again.
  final String? highlightPostId;

  /// Null at the bottom, or when [highlightPostId] says where to open.
  final ReadingAt? at;

  /// The same place, wherever the reader was in it.
  bool isSameSpot(Location other) {
    final mine = conversation;
    final theirs = other.conversation;
    if (mine == null || theirs == null) {
      return mine == theirs && place == other.place;
    }
    return mine.url == theirs.url &&
        mine.channelId == theirs.channelId &&
        mine.rootId == theirs.rootId;
  }

  /// Going here again right after [current] adds nothing.
  bool repeats(Location current) =>
      isSameSpot(current) &&
      (highlightPostId == null || highlightPostId == current.highlightPostId);

  /// This place at reading position [now]; one opened at a message keeps that.
  Location readAt(ReadingAt? now) => highlightPostId != null
      ? this
      : Location(
          place: place,
          conversation: conversation,
          highlightPostId: highlightPostId,
          at: now,
        );

  @override
  bool operator ==(Object other) =>
      other is Location &&
      other.place == place &&
      other.conversation == conversation &&
      other.highlightPostId == highlightPostId &&
      other.at == at;

  @override
  int get hashCode => Object.hash(place, conversation, highlightPostId, at);
}

/// Whether [location]'s server is signed in and its channel is joined and open; an unasked server stays.
bool locationExists(
  Location location, {
  required Set<String> signedIn,
  required Map<String, Set<String>> channels,
}) {
  final url = location.conversation?.url ?? location.place?.url;
  if (url == null) return true;
  if (!signedIn.contains(url)) return false;
  final id = location.conversation?.channelId;
  return id == null || (channels[url]?.contains(id) ?? true);
}

/// Places visited, oldest first; Back and Forward work like a browser's.
class OpenHistory<T> {
  OpenHistory({this.limit = 100, bool Function(T entry, T current)? repeats})
    : _repeats = repeats ?? ((entry, current) => entry == current);

  final int limit;
  final bool Function(T entry, T current) _repeats;
  final _entries = <T>[];
  var _at = -1;

  List<T> get entries => List.unmodifiable(_entries);

  T? get current => _at >= 0 ? _entries[_at] : null;

  /// Going somewhere new drops what was ahead; a repeat changes nothing.
  void push(T entry) {
    final now = current;
    if (now != null && _repeats(entry, now)) return;
    _entries.removeRange(_at + 1, _entries.length);
    _entries.add(entry);
    if (_entries.length > limit) _entries.removeAt(0);
    _at = _entries.length - 1;
  }

  void replaceCurrent(T entry) {
    if (_at >= 0) _entries[_at] = entry;
  }

  /// Moves to the nearest entry before (or after) the current one that
  /// [exists] and returns it; entries that don't are dropped. Null, and
  /// nothing moved, when there is none.
  T? step({required bool forward, required bool Function(T) exists}) {
    var i = _at + (forward ? 1 : -1);
    while (i >= 0 && i < _entries.length) {
      if (exists(_entries[i])) {
        _at = i;
        return _entries[i];
      }
      _entries.removeAt(i);
      if (!forward) {
        _at--;
        i--;
      }
    }
    return null;
  }
}

/// Records the reading position in the current entry when it is the same place.
void noteReading(OpenHistory<Location> history, Location now) {
  final current = history.current;
  if (current != null && current.isSameSpot(now)) {
    history.replaceCurrent(current.readAt(now.at));
  }
}

/// Updates the current entry, or adds [now] when it is a new conversation or Home.
void settleHistory(OpenHistory<Location> history, Location now) {
  final current = history.current;
  if (current != null && current.isSameSpot(now)) {
    noteReading(history, now);
  } else if (now.conversation != null || now.place == null) {
    history.push(now);
  }
}
