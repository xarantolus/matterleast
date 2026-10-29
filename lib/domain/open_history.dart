import 'package:matterleast/domain/conversation_restore.dart';
import 'package:matterleast/domain/rail.dart';

/// Where the reader was in a conversation, as the saved view state keeps
/// it: the message at the bottom of the screen and how far its bottom edge
/// sits above the bottom of the list.
typedef ReadingAt = ({String postId, double offset});

/// A place the user was at: a conversation (or a thread in it) with where
/// they read, or, with no conversation, Home ([place] null) or a team's
/// list.
class Location {
  const Location({
    this.place,
    this.conversation,
    this.highlightPostId,
    this.at,
  });

  final RailTarget? place;
  final SavedConversation? conversation;

  /// The message the conversation was opened at; reopening shows it again.
  final String? highlightPostId;

  /// Where the reader was when they left; null when at the bottom, or when
  /// [highlightPostId] says where to open.
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

  /// Going here again, right after [current], adds nothing: it is the same
  /// place, and not a jump to a message in it.
  bool repeats(Location current) =>
      isSameSpot(current) &&
      (highlightPostId == null || highlightPostId == current.highlightPostId);

  /// This place with the reading position [now]; a place opened at a
  /// message keeps opening there.
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

/// Whether the user can still go to [location]: its server is signed in and
/// its channel is one they are in and that isn't archived. [channels] are
/// the joined channels by server; a server missing from it couldn't be
/// asked, so its entries stay.
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

/// The places the user went to, oldest first, with the one shown now, so
/// Back and Forward move through them like a browser. Going somewhere new
/// drops what was ahead.
class OpenHistory<T> {
  OpenHistory({this.limit = 100, bool Function(T entry, T current)? repeats})
    : _repeats = repeats ?? ((entry, current) => entry == current);

  final int limit;
  final bool Function(T entry, T current) _repeats;
  final _entries = <T>[];
  var _at = -1;

  List<T> get entries => List.unmodifiable(_entries);

  T? get current => _at >= 0 ? _entries[_at] : null;

  /// [entry] was gone to; a repeat of the current one changes nothing.
  void push(T entry) {
    final now = current;
    if (now != null && _repeats(entry, now)) return;
    _entries.removeRange(_at + 1, _entries.length);
    _entries.add(entry);
    if (_entries.length > limit) _entries.removeAt(0);
    _at = _entries.length - 1;
  }

  /// The current entry, as it is now.
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

/// Notes in [history] where the reader is in the current entry's place.
void noteReading(OpenHistory<Location> history, Location now) {
  final current = history.current;
  if (current != null && current.isSameSpot(now)) {
    history.replaceCurrent(current.readAt(now.at));
  }
}

/// Notes in [history] that the user is at [now] before they go somewhere
/// else: where they read updates the current entry when it is the same
/// place; a conversation, or Home, that isn't in it yet is added.
void settleHistory(OpenHistory<Location> history, Location now) {
  final current = history.current;
  if (current != null && current.isSameSpot(now)) {
    noteReading(history, now);
  } else if (now.conversation != null || now.place == null) {
    history.push(now);
  }
}
