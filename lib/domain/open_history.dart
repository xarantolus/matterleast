import 'package:matterleast/domain/conversation_restore.dart';
import 'package:matterleast/domain/rail.dart';

/// The message at the bottom of the screen and its bottom edge's offset.
typedef ReadingAt = ({String postId, double offset});

/// A team-wide page that is a history entry of its own.
enum PlaceView { threads, drafts, agents }

/// A conversation or thread with the reading position, a [view] of a team, or Home.
class Location {
  const Location({
    this.place,
    this.conversation,
    this.view,
    this.highlightPostId,
    this.at,
  });

  final RailTarget? place;
  final SavedConversation? conversation;

  /// The page shown over [place]'s list, when no conversation is.
  final PlaceView? view;

  /// The message it was opened at; reopening shows it again.
  final String? highlightPostId;

  /// Null at the bottom, or when [highlightPostId] says where to open.
  final ReadingAt? at;

  /// The same place, wherever the reader was in it.
  bool isSameSpot(Location other) {
    final mine = conversation;
    final theirs = other.conversation;
    if (mine == null || theirs == null) {
      return mine == theirs && place == other.place && view == other.view;
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
          view: view,
          highlightPostId: highlightPostId,
          at: now,
        );

  @override
  bool operator ==(Object other) =>
      other is Location &&
      other.place == place &&
      other.conversation == conversation &&
      other.view == view &&
      other.highlightPostId == highlightPostId &&
      other.at == at;

  @override
  int get hashCode =>
      Object.hash(place, conversation, view, highlightPostId, at);
}

/// Whether [location]'s server is signed in, its team still there and its channel joined and open; an unasked server stays.
bool locationExists(
  Location location, {
  required Set<String> signedIn,
  required Map<String, Set<String>> channels,
  Map<String, Set<String>> teams = const {},
}) {
  final url = location.conversation?.url ?? location.place?.url;
  if (url == null) return true;
  if (!signedIn.contains(url)) return false;
  final team = location.place?.teamId;
  if (team != null && !(teams[url]?.contains(team) ?? true)) return false;
  final id = location.conversation?.channelId;
  return id == null || (channels[url]?.contains(id) ?? true);
}

/// What Back does at [shown], with [current] the entry the history is at.
enum HistoryMove { closePage, reopenCurrent, step }

/// Back first goes where the user is: it closes a page that is no entry, and
/// returns to the entry when the window shows something else.
HistoryMove historyMove({
  required bool forward,
  required bool pageOnTop,
  required Location shown,
  required Location? current,
}) {
  if (forward) return HistoryMove.step;
  if (pageOnTop) return HistoryMove.closePage;
  if (current != null && !current.isSameSpot(shown)) {
    return HistoryMove.reopenCurrent;
  }
  return HistoryMove.step;
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
  } else if (now.conversation != null ||
      now.view != null ||
      now.place == null) {
    history.push(now);
  }
}
