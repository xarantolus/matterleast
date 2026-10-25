import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_ranges.freezed.dart';

/// A contiguous stretch of loaded posts in a channel or thread, by create
/// time. Everything between [earliest] and [latest] is known to be loaded,
/// so a list anchored in a range never shows a hole as "no messages".
@freezed
abstract class PostRange with _$PostRange {
  const factory PostRange({
    required DateTime earliest,
    required DateTime latest,
    @Default(false) bool reachesStart,
  }) = _PostRange;

  const PostRange._();

  /// Marks a channel that has no posts at all, so it is not "never loaded".
  static final empty = PostRange(
    earliest: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    latest: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    reachesStart: true,
  );

  bool contains(DateTime time) =>
      !time.isBefore(earliest) && !time.isAfter(latest);

  bool overlaps(PostRange other) =>
      !other.latest.isBefore(earliest) && !other.earliest.isAfter(latest);
}

/// Sorted by [PostRange.earliest], with overlapping ranges fused.
List<PostRange> mergeRanges(Iterable<PostRange> ranges) {
  final sorted = ranges.toList()
    ..sort((a, b) => a.earliest.compareTo(b.earliest));
  final out = <PostRange>[];
  for (final range in sorted) {
    if (out.isNotEmpty && out.last.overlaps(range)) {
      final last = out.removeLast();
      out.add(
        PostRange(
          earliest: last.earliest,
          latest: last.latest.isAfter(range.latest)
              ? last.latest
              : range.latest,
          reachesStart: last.reachesStart || range.reachesStart,
        ),
      );
    } else {
      out.add(range);
    }
  }
  return out;
}

PostRange? newestRange(List<PostRange> ranges) => ranges.isEmpty
    ? null
    : ranges.reduce((a, b) => a.latest.isAfter(b.latest) ? a : b);

PostRange? rangeContaining(List<PostRange> ranges, DateTime time) {
  for (final range in ranges) {
    if (range.contains(time)) return range;
  }
  return null;
}

/// A page of posts arrived that stands on its own (first page of a channel,
/// or the window around a permalink). An empty first page records that the
/// channel has no posts.
List<PostRange> withPage(
  List<PostRange> ranges, {
  required DateTime? earliest,
  required DateTime? latest,
  required bool reachesStart,
}) {
  if (earliest == null || latest == null) {
    return ranges.isEmpty ? [PostRange.empty] : ranges;
  }
  return mergeRanges([
    ...ranges.where((r) => r != PostRange.empty),
    PostRange(earliest: earliest, latest: latest, reachesStart: reachesStart),
  ]);
}

/// Posts older than [anchor] (which is inside a range) arrived; the range
/// grows down to [earliest]. An empty answer means there is nothing older.
List<PostRange> withOlder(
  List<PostRange> ranges, {
  required DateTime anchor,
  required DateTime? earliest,
  required bool reachesStart,
}) {
  final range = rangeContaining(ranges, anchor);
  if (range == null) return ranges;
  final grown = range.copyWith(
    earliest: earliest != null && earliest.isBefore(range.earliest)
        ? earliest
        : range.earliest,
    reachesStart: range.reachesStart || reachesStart,
  );
  return mergeRanges([...ranges.where((r) => r != range), grown]);
}

/// Posts newer than [anchor] (which is inside a range) arrived; the range
/// grows up to [latest]. Used for `after` paging and for `since` refreshes
/// on the newest range.
List<PostRange> withNewer(
  List<PostRange> ranges, {
  required DateTime anchor,
  required DateTime? latest,
}) {
  final range = rangeContaining(ranges, anchor);
  if (range == null || latest == null || !latest.isAfter(range.latest)) {
    return ranges;
  }
  return mergeRanges([
    ...ranges.where((r) => r != range),
    range.copyWith(latest: latest),
  ]);
}

/// A post arrived live (WebSocket or our own send). It extends the newest
/// range; a channel known to be empty starts its history at that post. A
/// channel never loaded stays so, since older posts may exist; its first
/// open fetches the newest page.
List<PostRange> withLivePost(List<PostRange> ranges, DateTime createAt) {
  final newest = newestRange(ranges);
  if (newest == null) return ranges;
  if (newest == PostRange.empty) {
    return [
      PostRange(earliest: createAt, latest: createAt, reachesStart: true),
    ];
  }
  if (!createAt.isAfter(newest.latest)) return ranges;
  return mergeRanges([
    ...ranges.where((r) => r != newest),
    newest.copyWith(latest: createAt),
  ]);
}

/// After pruning, no range may claim posts older than [oldestKept].
List<PostRange> withPruned(List<PostRange> ranges, DateTime oldestKept) => [
  for (final range in ranges)
    if (!range.latest.isBefore(oldestKept))
      range.earliest.isBefore(oldestKept)
          ? range.copyWith(earliest: oldestKept, reachesStart: false)
          : range,
];
