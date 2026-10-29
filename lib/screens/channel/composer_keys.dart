import 'package:flutter/services.dart';
import 'package:matterleast/domain/post_list.dart';

/// What a key press in the composer does.
enum ComposerKey {
  send,
  acceptSuggestion,
  nextSuggestion,
  previousSuggestion,
  closeSuggestions,
  editLast,
  stopEditing,
  blur,

  /// An empty field leaves the page keys to the message list above.
  scrollUp,
  scrollDown,
}

/// Pure: what [key] does in the composer, or null when the text field is
/// left to handle it (typing, a new line, an IME). [enterSends] is a hardware
/// keyboard that sends with Enter; Ctrl+Enter sends everywhere.
ComposerKey? composerKey({
  required LogicalKeyboardKey key,
  required bool shift,
  required bool control,
  required bool alt,
  required bool meta,
  required bool enterSends,
  required bool composing,
  required bool suggestionsOpen,
  required bool editing,
  required bool empty,
  required bool desktop,
}) {
  if (composing) return null;
  final plain = !shift && !control && !alt && !meta;
  if (key == LogicalKeyboardKey.enter ||
      key == LogicalKeyboardKey.numpadEnter) {
    if (control && !alt && !meta) return ComposerKey.send;
    if (!plain) return null;
    if (suggestionsOpen) return ComposerKey.acceptSuggestion;
    return enterSends ? ComposerKey.send : null;
  }
  if (key == LogicalKeyboardKey.tab && plain && suggestionsOpen) {
    return ComposerKey.acceptSuggestion;
  }
  if (key == LogicalKeyboardKey.arrowDown && plain && suggestionsOpen) {
    return ComposerKey.nextSuggestion;
  }
  if (key == LogicalKeyboardKey.arrowUp && plain) {
    if (suggestionsOpen) return ComposerKey.previousSuggestion;
    if (empty && !editing && desktop) return ComposerKey.editLast;
    return null;
  }
  if (plain && empty && desktop && !suggestionsOpen) {
    if (key == LogicalKeyboardKey.pageUp) return ComposerKey.scrollUp;
    if (key == LogicalKeyboardKey.pageDown) return ComposerKey.scrollDown;
  }
  if (key == LogicalKeyboardKey.escape && plain) {
    if (suggestionsOpen) return ComposerKey.closeSuggestions;
    if (editing) return ComposerKey.stopEditing;
    if (desktop) return ComposerKey.blur;
  }
  return null;
}

/// The highlight after moving by [step] through [count] suggestions, which
/// wraps around.
int movedHighlight(int current, int step, int count) =>
    count == 0 ? 0 : (current + step) % count;

/// The messages of [userId] that can be edited, newest first: not system
/// messages, not deleted and not still being sent.
List<PostItem> ownPosts(List<ListRow> rows, String? userId) {
  if (userId == null) return const [];
  final own = [
    for (final row in rows)
      if (row is MessageRow &&
          row.post.userId == userId &&
          row.post.type.isEmpty &&
          !row.post.deleted &&
          row.post.sendState == null &&
          !row.post.isEphemeral)
        row.post,
  ];
  return own..sort((a, b) => b.createAt.compareTo(a.createAt));
}

/// The newest message of [userId] that can be edited.
PostItem? lastOwnPost(List<ListRow> rows, String? userId) =>
    ownPosts(rows, userId).firstOrNull;

/// The newest message that can be replied to: not a system message, not
/// deleted and not still being sent.
PostItem? newestReplyable(List<ListRow> rows) {
  PostItem? newest;
  for (final row in rows) {
    if (row is! MessageRow) continue;
    final post = row.post;
    if (post.isSystem ||
        post.deleted ||
        post.unreadable ||
        post.sendState != null ||
        post.isEphemeral) {
      continue;
    }
    if (newest == null || post.createAt.isAfter(newest.createAt)) {
      newest = post;
    }
  }
  return newest;
}
