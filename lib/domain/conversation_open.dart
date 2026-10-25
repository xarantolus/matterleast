import 'package:matterleast/domain/post_list.dart';

/// Where a conversation opens: which row is anchored and how far its bottom
/// edge sits above the list's bottom edge.
sealed class OpenAt {
  const OpenAt();
}

final class OpenAtBottom extends OpenAt {
  const OpenAtBottom();
}

final class OpenAtRow extends OpenAt {
  const OpenAtRow(this.key, this.offset);
  final Object key;
  final double offset;
}

/// Centred and highlighted for a moment.
final class OpenCentred extends OpenAt {
  const OpenCentred(this.key);
  final Object key;
}

/// A saved reading position.
typedef SavedPlace = ({String postId, double offset, DateTime savedAt});

const savedPlaceLifetime = Duration(days: 30);

/// The message asked for first; then the new-messages line about a quarter
/// from the top; then where the reader left off, unless it is old or newer
/// messages came since; else the bottom. [rows] are newest first.
OpenAt openPosition({
  required List<ListRow> rows,
  required double height,
  required DateTime now,
  String? highlightKey,
  SavedPlace? saved,
}) {
  final keys = {for (final row in rows) row.key};
  if (highlightKey != null && keys.contains(highlightKey)) {
    return OpenCentred(highlightKey);
  }
  final line = rows.indexWhere((r) => r is NewMessagesLine);
  if (line >= 0) {
    // The row above the line is anchored by its bottom edge, which is the
    // line's top.
    return line + 1 < rows.length
        ? OpenAtRow(rows[line + 1].key, height * 0.75)
        : OpenAtRow(rows[line].key, height * 0.75 - 32);
  }
  if (saved != null &&
      keys.contains(saved.postId) &&
      now.difference(saved.savedAt) < savedPlaceLifetime) {
    final newest = rows.whereType<MessageRow>().firstOrNull?.post.createAt;
    if (newest == null || !newest.isAfter(saved.savedAt)) {
      return OpenAtRow(saved.postId, saved.offset);
    }
  }
  return const OpenAtBottom();
}

/// How to bring a channel up to date when it opens.
sealed class RefreshPlan {
  const RefreshPlan();
}

/// Nothing stored yet: the newest page.
final class FetchNewestPage extends RefreshPlan {
  const FetchNewestPage();
}

/// Everything created, edited or deleted since [since].
final class FetchSince extends RefreshPlan {
  const FetchSince(this.since);
  final DateTime since;
}

RefreshPlan refreshPlan({
  required bool hasRange,
  required DateTime? postsFetchedAt,
  required DateTime? newestStored,
}) {
  if (!hasRange) return const FetchNewestPage();
  final since = postsFetchedAt ?? newestStored;
  return since == null ? const FetchNewestPage() : FetchSince(since);
}

/// The team a thread's read mark goes to: its channel's, or for direct and
/// group messages (which belong to no team) the team in view. Null when
/// collapsed reply threads are off, which have no per-thread read state.
String? threadReadTeam({
  required bool collapsedThreads,
  required String channelTeamId,
  required String? currentTeamId,
}) {
  if (!collapsedThreads) return null;
  final team = channelTeamId.isNotEmpty ? channelTeamId : currentTeamId;
  return team == null || team.isEmpty ? null : team;
}
