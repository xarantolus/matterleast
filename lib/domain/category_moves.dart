import 'package:matterleast/domain/channel_list.dart';

/// One line of the channel list while it is being reordered: a category
/// header or a channel under it.
sealed class ReorderEntry {
  const ReorderEntry(this.categoryId);

  final String categoryId;
}

final class HeaderEntry extends ReorderEntry {
  const HeaderEntry(super.categoryId);
}

final class RowEntry extends ReorderEntry {
  const RowEntry(super.categoryId, this.channelId);

  final String channelId;
}

/// What a drag in the reorder list asks for.
sealed class Drop {
  const Drop();
}

/// [channelId] goes to [toCategory] at [index] among its shown rows.
final class ChannelDrop extends Drop {
  const ChannelDrop({
    required this.channelId,
    required this.fromCategory,
    required this.toCategory,
    required this.index,
  });

  final String channelId;
  final String fromCategory;
  final String toCategory;
  final int index;
}

/// The shown categories in their new order after one of them moved.
final class CategoryDrop extends Drop {
  const CategoryDrop({required this.categoryId, required this.shownOrder});

  final String categoryId;
  final List<String> shownOrder;
}

/// Pure: the entries after the line at [oldIndex] was dragged to [newIndex],
/// its place once it was taken out (as `onReorderItem` numbers it). A
/// moved header takes its rows along.
List<ReorderEntry> reorderEntries(
  List<ReorderEntry> entries,
  int oldIndex,
  int newIndex,
) {
  final drop = dropOf(entries, oldIndex, newIndex);
  switch (drop) {
    case null:
      return entries;
    case CategoryDrop(:final shownOrder):
      return [
        for (final id in shownOrder)
          for (final e in entries)
            if (e.categoryId == id) e,
      ];
    case ChannelDrop(:final channelId, :final toCategory, :final index):
      final rest = [
        for (final e in entries)
          if (e is! RowEntry || e.channelId != channelId) e,
      ];
      final header = rest.indexWhere(
        (e) => e is HeaderEntry && e.categoryId == toCategory,
      );
      return rest..insert(header + 1 + index, RowEntry(toCategory, channelId));
  }
}

/// Pure: what dragging the line at [oldIndex] to [newIndex] (counted as in
/// [reorderEntries]) means, or null when nothing changes (a channel dropped
/// above the first header, or back where it was).
Drop? dropOf(List<ReorderEntry> entries, int oldIndex, int newIndex) {
  final list = [...entries];
  final moved = list.removeAt(oldIndex);
  final at = newIndex.clamp(0, list.length);
  list.insert(at, moved);
  switch (moved) {
    case HeaderEntry(:final categoryId):
      final before = [
        for (final e in entries)
          if (e is HeaderEntry) e.categoryId,
      ];
      final after = [
        for (final e in list)
          if (e is HeaderEntry) e.categoryId,
      ];
      if (_same(before, after)) return null;
      return CategoryDrop(categoryId: categoryId, shownOrder: after);
    case RowEntry(:final categoryId, :final channelId):
      var header = at - 1;
      while (header >= 0 && list[header] is! HeaderEntry) {
        header--;
      }
      if (header < 0) return null;
      final to = list[header].categoryId;
      final index = at - header - 1;
      if (to == categoryId) {
        final was = entries.indexWhere(
          (e) => e is HeaderEntry && e.categoryId == categoryId,
        );
        if (oldIndex - was - 1 == index) return null;
      }
      return ChannelDrop(
        channelId: channelId,
        fromCategory: categoryId,
        toCategory: to,
        index: index,
      );
  }
}

/// Pure: whether a channel of [channel] kind may go into a [category].
/// Conversations stay out of Channels and channels out of Direct Messages,
/// as on the server.
bool canPlace(ChannelKind channel, CategoryKind category) {
  final conversation =
      channel == ChannelKind.direct || channel == ChannelKind.group;
  return switch (category) {
    CategoryKind.channels => !conversation,
    CategoryKind.directMessages => conversation,
    _ => true,
  };
}

/// Pure: a category's channel ids after [channelId] is put at [index] among
/// the [shown] ones, which keep the order the user sees. Stored channels
/// that are not shown (closed conversations, archived channels) follow in
/// their stored order.
List<String> placeChannel({
  required List<String> stored,
  required List<String> shown,
  required String channelId,
  required int index,
}) {
  final visible = [
    for (final id in shown)
      if (id != channelId) id,
  ];
  visible.insert(index.clamp(0, visible.length), channelId);
  final seen = visible.toSet();
  return [
    ...visible,
    for (final id in stored)
      if (!seen.contains(id)) id,
  ];
}

/// Pure: the team's full category order after [categoryId] moved, given the
/// [shown] order (the list hides empty Favourites, the server wants every
/// category). It goes right before the shown category that now follows it,
/// or after the one that now precedes it.
List<String> placeCategory({
  required List<String> stored,
  required List<String> shown,
  required String categoryId,
}) {
  final rest = [
    for (final id in stored)
      if (id != categoryId) id,
  ];
  final at = shown.indexOf(categoryId);
  if (at < 0) return stored;
  if (at + 1 < shown.length) {
    final next = rest.indexOf(shown[at + 1]);
    if (next >= 0) return rest..insert(next, categoryId);
  }
  if (at > 0) {
    final previous = rest.indexOf(shown[at - 1]);
    if (previous >= 0) return rest..insert(previous + 1, categoryId);
  }
  return rest..add(categoryId);
}

bool _same(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// The sidebar category a channel goes to when it is made a favourite or
/// taken out of Favourites, as the official app does: Favourites, or back
/// to Channels (Direct Messages for a conversation).
String favoriteTargetType(String channelType, {required bool favorite}) =>
    favorite
    ? 'favorites'
    : (channelType == 'D' || channelType == 'G')
    ? 'direct_messages'
    : 'channels';

/// Pure: the categories a channel leaves ([from], null when it is in none
/// yet) and joins ([to]) to become a favourite or stop being one. Null when
/// it is already there, or when the team has no such category yet (before
/// its categories synced).
({String? from, String to})? favoriteMove({
  required List<({String id, String type})> categories,
  required String? currentCategoryId,
  required String channelType,
  required bool favorite,
}) {
  final type = favoriteTargetType(channelType, favorite: favorite);
  final target = categories.where((c) => c.type == type).firstOrNull;
  if (target == null || target.id == currentCategoryId) return null;
  return (from: currentCategoryId, to: target.id);
}
