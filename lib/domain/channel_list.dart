import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/teams.dart';

part 'channel_list.freezed.dart';

enum ChannelKind { public, private, archived, direct, group }

enum CategoryKind { favorites, channels, directMessages, custom }

/// One row of the channel list.
@freezed
abstract class ChannelItem with _$ChannelItem {
  const factory ChannelItem({
    required String id,
    required String title,
    required ChannelKind kind,
    required bool unread,
    required int mentions,
    required bool muted,
    required bool favorite,
    required bool hasDraft,

    /// Presence of the other person in a direct message.
    String? status,

    /// Other members of a group message.
    int? others,
  }) = _ChannelItem;
}

@freezed
abstract class CategorySection with _$CategorySection {
  const factory CategorySection({
    required String id,
    required String title,
    required CategoryKind kind,
    required bool collapsed,
    required List<ChannelItem> rows,
  }) = _CategorySection;
}

/// Everything the channel list of one team shows.
@freezed
abstract class ChannelList with _$ChannelList {
  const factory ChannelList({
    required String teamName,
    required List<CategorySection> sections,

    /// Followed threads with unread replies; null when threads are not
    /// collapsed, so there is no Threads row.
    required int? unreadThreads,
    required int drafts,

    /// The team's channels were fetched at least once.
    required bool synced,
  }) = _ChannelList;

  const ChannelList._();

  bool get isEmpty => sections.every((s) => s.rows.isEmpty);
}

// Inputs, as read from the database.

typedef CategoryInput = ({
  String id,
  String type,
  String displayName,
  String sorting,
  bool collapsed,
});

typedef ChannelInput = ({
  String id,
  String type,
  String name,
  String displayName,
  bool archived,
  DateTime? createAt,
  DateTime? lastPostAt,
  DateTime? lastRootPostAt,
  int totalMsgCount,
  int totalMsgCountRoot,
  int msgCount,
  int msgCountRoot,
  int mentionCount,
  int mentionCountRoot,
  bool muted,
});

typedef PersonInput = ({
  String username,
  String firstName,
  String lastName,
  String nickname,
  String status,
});

class ChannelListSource {
  const ChannelListSource({
    required this.myId,
    required this.teamName,
    required this.categories,
    required this.channelIdsByCategory,
    required this.channels,
    this.people = const {},
    this.hiddenDirect = const {},
    this.hiddenGroups = const {},
    this.draftChannels = const {},
    this.collapsedThreads = false,
    this.unreadThreads = 0,
    this.nameFormat,
    this.synced = true,
    this.currentChannelId,
  });

  final String myId;
  final String teamName;

  /// In the user's order.
  final List<CategoryInput> categories;

  /// Channel ids per category id, in the category's manual order.
  final Map<String, List<String>> channelIdsByCategory;
  final Map<String, ChannelInput> channels;

  /// By user id.
  final Map<String, PersonInput> people;

  /// Partner ids of direct messages and ids of group messages the user
  /// closed.
  final Set<String> hiddenDirect;
  final Set<String> hiddenGroups;
  final Set<String> draftChannels;
  final bool collapsedThreads;
  final int unreadThreads;

  /// `username`, `full_name` or `nickname_full_name`.
  final String? nameFormat;
  final bool synced;

  /// Stays visible even when archived.
  final String? currentChannelId;
}

/// Pure: the sections of a team's channel list.
ChannelList buildChannelList(ChannelListSource source) {
  final sections = <CategorySection>[];
  for (final category in source.categories) {
    final kind = switch (category.type) {
      'favorites' => CategoryKind.favorites,
      'channels' => CategoryKind.channels,
      'direct_messages' => CategoryKind.directMessages,
      _ => CategoryKind.custom,
    };
    final ids = source.channelIdsByCategory[category.id] ?? const [];
    final rows = <(ChannelItem, ChannelInput, int)>[];
    for (final (order, id) in ids.indexed) {
      final channel = source.channels[id];
      if (channel == null) continue;
      final item = _item(source, channel, kind == CategoryKind.favorites);
      if (!_visible(source, channel, item)) continue;
      rows.add((item, channel, order));
    }
    _sort(rows, category.sorting, source.collapsedThreads);
    final items = [
      for (final (item, _, _) in rows)
        if (!category.collapsed || item.unread || item.mentions > 0) item,
    ];
    if (kind == CategoryKind.favorites && rows.isEmpty) continue;
    sections.add(
      CategorySection(
        id: category.id,
        title: category.displayName,
        kind: kind,
        collapsed: category.collapsed,
        rows: items,
      ),
    );
  }
  return ChannelList(
    teamName: source.teamName,
    sections: sections,
    unreadThreads: source.collapsedThreads ? source.unreadThreads : null,
    drafts: source.draftChannels.length,
    synced: source.synced,
  );
}

ChannelItem _item(ChannelListSource source, ChannelInput c, bool favorite) {
  final crt = source.collapsedThreads;
  final unreadCount = crt
      ? c.totalMsgCountRoot - c.msgCountRoot
      : c.totalMsgCount - c.msgCount;
  final kind = switch (c.type) {
    'D' => ChannelKind.direct,
    'G' => ChannelKind.group,
    _ when c.archived => ChannelKind.archived,
    'P' => ChannelKind.private,
    _ => ChannelKind.public,
  };
  var title = c.displayName;
  String? status;
  int? others;
  if (kind == ChannelKind.direct) {
    final partnerId = directPartnerId(c.name, source.myId);
    final partner = source.people[partnerId];
    if (partner != null) {
      title = personName(partner, source.nameFormat);
      if (partnerId == source.myId) title = '$title (you)';
      status = partner.status;
    }
  } else if (kind == ChannelKind.group) {
    final me = source.people[source.myId]?.username;
    final names = c.displayName
        .split(',')
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList();
    final otherNames = [
      for (final n in names)
        if (n != me) n,
    ];
    title = otherNames.join(', ');
    others = otherNames.length;
  }
  return ChannelItem(
    id: c.id,
    title: title.isEmpty ? c.name : title,
    kind: kind,
    unread: !c.muted && unreadCount > 0,
    mentions: crt ? c.mentionCountRoot : c.mentionCount,
    muted: c.muted,
    favorite: favorite,
    hasDraft: source.draftChannels.contains(c.id),
    status: status,
    others: others,
  );
}

bool _visible(ChannelListSource source, ChannelInput c, ChannelItem item) {
  if (c.id == source.currentChannelId) return true;
  if (c.archived) return false;
  if (item.unread || item.mentions > 0) return true;
  return switch (item.kind) {
    ChannelKind.direct => !source.hiddenDirect.contains(
      directPartnerId(c.name, source.myId),
    ),
    ChannelKind.group => !source.hiddenGroups.contains(c.id),
    _ => true,
  };
}

void _sort(
  List<(ChannelItem, ChannelInput, int)> rows,
  String sorting,
  bool crt,
) {
  int recent((ChannelItem, ChannelInput, int) row) {
    final c = row.$2;
    final last = crt ? c.lastRootPostAt : c.lastPostAt;
    final created = c.createAt?.millisecondsSinceEpoch ?? 0;
    final posted = last?.millisecondsSinceEpoch ?? 0;
    return posted > created ? posted : created;
  }

  switch (sorting) {
    case 'recent':
      rows.sort((a, b) => recent(b).compareTo(recent(a)));
    case 'manual':
      rows.sort((a, b) => a.$3.compareTo(b.$3));
    default:
      rows.sort((a, b) {
        if (a.$1.muted != b.$1.muted) return a.$1.muted ? 1 : -1;
        return compareNatural(a.$1.title, b.$1.title);
      });
  }
}

/// How a person is named, by the server's or the user's name format.
String personName(PersonInput p, String? format) {
  final full = '${p.firstName} ${p.lastName}'.trim();
  return switch (format) {
    'nickname_full_name' when p.nickname.isNotEmpty => p.nickname,
    'nickname_full_name' || 'full_name' when full.isNotEmpty => full,
    _ => p.username,
  };
}

/// Case-insensitive, with digit runs compared as numbers ("ch 2" < "ch 10").
int compareNatural(String a, String b) {
  final pattern = RegExp(r'\d+|\D+');
  final left = pattern.allMatches(a.toLowerCase()).map((m) => m[0]!).toList();
  final right = pattern.allMatches(b.toLowerCase()).map((m) => m[0]!).toList();
  for (var i = 0; i < left.length && i < right.length; i++) {
    final x = int.tryParse(left[i]);
    final y = int.tryParse(right[i]);
    final byPart = x != null && y != null
        ? x.compareTo(y)
        : left[i].compareTo(right[i]);
    if (byPart != 0) return byPart;
  }
  return left.length.compareTo(right.length);
}

/// Keeps rows where the reader last saw them while the list is not idle at
/// the top: rows still present keep their old order (with fresh content),
/// new rows go to the end of their section and removed ones drop out.
List<CategorySection> keepOrder(
  List<CategorySection> fresh,
  List<CategorySection> shown,
) {
  final oldOrder = {
    for (final section in shown)
      section.id: {for (final (i, row) in section.rows.indexed) row.id: i},
  };
  return [
    for (final section in fresh)
      section.copyWith(
        rows: () {
          final order = oldOrder[section.id] ?? const <String, int>{};
          final kept = [
            for (final row in section.rows)
              if (order.containsKey(row.id)) row,
          ]..sort((a, b) => order[a.id]!.compareTo(order[b.id]!));
          return [
            ...kept,
            for (final row in section.rows)
              if (!order.containsKey(row.id)) row,
          ];
        }(),
      ),
  ];
}

/// Initials for a direct message avatar.
String avatarInitials(String title) =>
    initialsOf(title.replaceAll(' (you)', ''));
