import 'package:matterleast/domain/conversation_open.dart';
import 'package:matterleast/ui/anchored_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reading_places.g.dart';

/// Hands the reading position of a conversation on to the next view of it
/// when a window change moves the conversation between a pane and a route,
/// so the reader stays where they were.
@Riverpod(keepAlive: true)
ReadingPlaces readingPlaces(Ref ref) => ReadingPlaces();

class ReadingPlaces {
  final _live = <Object, List<AnchoredListController>>{};
  final _handed = <Object, OpenAt>{};
  var _capturedAt = DateTime(0);

  /// A handed-on place is for the views built right after the capture.
  static const _lifetime = Duration(seconds: 2);

  void attach(Object conversation, AnchoredListController list) =>
      (_live[conversation] ??= []).add(list);

  void detach(Object conversation, AnchoredListController list) {
    final lists = _live[conversation];
    lists?.remove(list);
    if (lists?.isEmpty ?? false) _live.remove(conversation);
  }

  /// Notes where every shown conversation is read, for the views that
  /// replace them.
  void captureAll() {
    _handed.clear();
    _capturedAt = DateTime.now();
    for (final MapEntry(:key, value: lists) in _live.entries) {
      for (final list in lists) {
        if (list.position case final p?) {
          _handed[key] = list.pinned
              ? const OpenAtBottom()
              : OpenAtRow(p.key, p.offset);
          break;
        }
      }
    }
  }

  /// Where a new view of [conversation] opens, once, after a capture.
  OpenAt? take(Object conversation) {
    final at = _handed.remove(conversation);
    return DateTime.now().difference(_capturedAt) < _lifetime ? at : null;
  }
}
