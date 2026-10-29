import 'package:matterleast/domain/conversation_open.dart';
import 'package:matterleast/domain/open_history.dart';
import 'package:matterleast/ui/anchored_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reading_places.g.dart';

/// A channel, or the thread of [rootId] in it, on a server.
typedef ConversationKey = ({String url, String channelId, String? rootId});

/// Where each shown conversation is read; handed to its next view after a window change.
@Riverpod(keepAlive: true)
ReadingPlaces readingPlaces(Ref ref) => ReadingPlaces();

class ReadingPlaces {
  final _live = <ConversationKey, List<_Shown>>{};
  final _handed = <ConversationKey, ({OpenAt at, DateTime until})>{};

  /// A handed-on place is for the views built right after it.
  static const _lifetime = Duration(seconds: 2);

  /// A place from history waits for a conversation that still loads.
  static const _loadTime = Duration(seconds: 15);

  /// [postIdOf] names the message a row of [list] shows, null for others.
  void attach(
    ConversationKey conversation,
    AnchoredListController list, {
    required String? Function(Object rowKey) postIdOf,
  }) => (_live[conversation] ??= []).add((list: list, postIdOf: postIdOf));

  void detach(ConversationKey conversation, AnchoredListController list) {
    final lists = _live[conversation];
    lists?.removeWhere((s) => s.list == list);
    if (lists?.isEmpty ?? false) _live.remove(conversation);
  }

  /// Notes where every shown conversation is read, for the views that
  /// replace them.
  void captureAll() {
    _handed.clear();
    final until = DateTime.now().add(_lifetime);
    for (final MapEntry(:key, value: lists) in _live.entries) {
      for (final shown in lists) {
        final list = shown.list;
        if (list.position case final p?) {
          _handed[key] = (
            at: list.pinned ? const OpenAtBottom() : OpenAtRow(p.key, p.offset),
            until: until,
          );
          break;
        }
      }
    }
  }

  /// Where a new view of [conversation] opens, once, after a capture or restore.
  OpenAt? take(ConversationKey conversation) {
    final handed = _handed.remove(conversation);
    return handed != null && DateTime.now().isBefore(handed.until)
        ? handed.at
        : null;
  }

  /// Null at the bottom, or when [conversation] is not shown.
  ReadingAt? placeOf(ConversationKey conversation) {
    for (final shown in _live[conversation] ?? const <_Shown>[]) {
      final p = shown.list.position;
      if (p == null) continue;
      if (shown.list.pinned) return null;
      final postId = shown.postIdOf(p.key);
      if (postId != null) return (postId: postId, offset: p.offset);
    }
    return null;
  }

  /// Jumps the shown views to [at], or sets where the next view opens.
  void restore(ConversationKey conversation, ReadingAt at) {
    final shown = _live[conversation];
    if (shown != null && shown.isNotEmpty) {
      for (final s in shown) {
        s.list.jumpTo(at.postId, offset: at.offset);
      }
      return;
    }
    _handed[conversation] = (
      at: OpenAtRow(at.postId, at.offset),
      until: DateTime.now().add(_loadTime),
    );
  }
}

typedef _Shown = ({
  AnchoredListController list,
  String? Function(Object rowKey) postIdOf,
});
