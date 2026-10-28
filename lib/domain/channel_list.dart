import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/domain/people.dart';
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

    /// Some of the [mentions] are in urgent messages.
    @Default(false) bool urgent,

    /// Presence of the other person in a direct message.
    String? status,

    /// Other members of a group message.
    int? others,

    /// The other person of a direct message and their picture's version.
    String? userId,
    int? pictureUpdate,
  }) = _ChannelItem;
}

@freezed
abstract class CategorySection with _$CategorySection {
  const factory CategorySection({
    required String id,
    required String title,
    required CategoryKind kind,
    required bool collapsed,

    /// Every visible channel, also while [collapsed].
    required List<ChannelItem> rows,
  }) = _CategorySection;

  const CategorySection._();

  /// The rows the list shows: only unread ones while [collapsed].
  List<ChannelItem> get shown => collapsed
      ? [
          for (final item in rows)
            if (item.unread || item.mentions > 0) item,
        ]
      : rows;
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

  /// Mentions in messages marked urgent; 0 where the server has no message
  /// priority.
  int urgentMentionCount,
  bool muted,
  DateTime? lastViewedAt,
});

/// Pure: whether a mention badge says some mentions are urgent: only on a
/// server with message priority, and only while there are mentions.
bool urgentMentions({
  required bool postPriority,
  required int mentions,
  required int urgent,
}) => postPriority && mentions > 0 && urgent > 0;

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
    this.pictureUpdates = const {},
    this.hiddenDirect = const {},
    this.hiddenGroups = const {},
    this.draftChannels = const {},
    this.collapsedThreads = false,
    this.unreadThreads = 0,
    this.nameFormat = NameFormat.username,
    this.synced = true,
    this.currentChannelId,
    this.directLimit = defaultDirectLimit,
    this.viewTimes = const {},
    this.postPriority = false,
  });

  final String myId;
  final String teamName;

  /// The server marks messages urgent, so mention badges can say so.
  final bool postPriority;

  /// In the user's order.
  final List<CategoryInput> categories;

  /// Channel ids per category id, in the category's manual order.
  final Map<String, List<String>> channelIdsByCategory;
  final Map<String, ChannelInput> channels;

  /// By user id.
  final Map<String, PersonInput> people;

  /// `last_picture_update` by user id.
  final Map<String, int> pictureUpdates;

  /// Partner ids of direct messages and ids of group messages the user
  /// closed.
  final Set<String> hiddenDirect;
  final Set<String> hiddenGroups;
  final Set<String> draftChannels;
  final bool collapsedThreads;
  final int unreadThreads;

  final NameFormat nameFormat;
  final bool synced;

  /// Stays visible even when archived.
  final String? currentChannelId;

  /// How many read direct and group messages stay in their category (the
  /// `limit_visible_dms_gms` preference).
  final int directLimit;

  /// When the user last opened a channel, by id, from the `channel_open_time`
  /// and `channel_approximate_view_time` preferences.
  final Map<String, DateTime> viewTimes;
}

const defaultDirectLimit = 20;

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
    if (kind == CategoryKind.directMessages) {
      final visible = autoCloseDirect([
        for (final (item, channel, _) in rows)
          (
            id: item.id,
            unread: item.unread || item.mentions > 0,
            lastViewed: _latest(
              channel.lastViewedAt,
              source.viewTimes[channel.id],
            ),
            current: item.id == source.currentChannelId,
          ),
      ], limit: source.directLimit);
      rows.retainWhere((row) => visible.contains(row.$1.id));
    }
    _sort(rows, category.sorting, source.collapsedThreads);
    final items = [for (final (item, _, _) in rows) item];
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
  final name = conversationName(
    c,
    myId: source.myId,
    people: source.people,
    nameFormat: source.nameFormat,
  );
  return ChannelItem(
    id: c.id,
    title: name.title,
    kind: kind,
    unread: !c.muted && unreadCount > 0,
    mentions: crt ? c.mentionCountRoot : c.mentionCount,
    urgent: urgentMentions(
      postPriority: source.postPriority,
      mentions: crt ? c.mentionCountRoot : c.mentionCount,
      urgent: c.urgentMentionCount,
    ),
    muted: c.muted,
    favorite: favorite,
    hasDraft: source.draftChannels.contains(c.id),
    status: name.status,
    others: name.others,
    userId: name.userId,
    pictureUpdate: source.pictureUpdates[name.userId],
  );
}

/// The name a channel goes by in lists: the other person of a direct
/// message (with their presence), the others of a group message, else the
/// channel's display name.
({String title, String? status, int? others, String? userId}) conversationName(
  ChannelInput c, {
  required String myId,
  required Map<String, PersonInput> people,
  NameFormat nameFormat = NameFormat.username,
}) {
  var title = c.displayName;
  String? status;
  int? others;
  String? userId;
  if (c.type == 'D') {
    final partnerId = directPartnerId(c.name, myId);
    userId = partnerId;
    final partner = people[partnerId];
    if (partner != null) {
      title = personName(partner, nameFormat);
      if (partnerId == myId) title = '$title (you)';
      status = partner.status;
    }
  } else if (c.type == 'G') {
    final me = people[myId]?.username;
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
  return (
    title: title.isEmpty ? c.name : title,
    status: status,
    others: others,
    userId: userId,
  );
}

DateTime? _latest(DateTime? a, DateTime? b) =>
    a == null || (b != null && b.isAfter(a)) ? b : a;

/// Pure: which direct and group messages stay in their category, like the
/// official app: unread ones and the open one always, never one the user
/// hasn't viewed, and of the rest the most recently viewed until [limit]
/// is reached.
Set<String> autoCloseDirect(
  List<({String id, bool unread, DateTime? lastViewed, bool current})> rows, {
  required int limit,
}) {
  final alwaysShown = rows.where((r) => r.unread || r.current).length;
  final kept = [
    for (final r in rows)
      if (r.unread || r.current || r.lastViewed != null) r,
  ];
  int rank(({String id, bool unread, DateTime? lastViewed, bool current}) r) =>
      r.current ? 0 : (r.unread ? 1 : 2);
  kept.sort((a, b) {
    final byRank = rank(a).compareTo(rank(b));
    if (byRank != 0) return byRank;
    final aTime = a.lastViewed?.millisecondsSinceEpoch ?? 0;
    final bTime = b.lastViewed?.millisecondsSinceEpoch ?? 0;
    return bTime.compareTo(aTime);
  });
  final count = limit > alwaysShown ? limit : alwaysShown;
  return {for (final r in kept.take(count)) r.id};
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
String personName(PersonInput p, NameFormat format) {
  final full = fullName(p.firstName, p.lastName);
  return switch (format) {
    NameFormat.nickname when p.nickname.isNotEmpty => p.nickname,
    NameFormat.nickname || NameFormat.fullName when full.isNotEmpty => full,
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

/// Whose initials a direct message avatar shows.
String avatarName(String title) => title.replaceAll(' (you)', '');

/// The id of the one section the unreads filter shows.
const unreadsSectionId = 'unreads';

/// Pure: the list as the unreads filter shows it: one section with every
/// unread channel, in the order the categories list them; none when
/// nothing is unread.
List<CategorySection> unreadsOnly(List<CategorySection> sections) {
  final rows = [
    for (final section in sections)
      for (final item in section.rows)
        if (item.unread || item.mentions > 0) item,
  ];
  return rows.isEmpty
      ? const []
      : [
          CategorySection(
            id: unreadsSectionId,
            title: 'Unreads',
            kind: CategoryKind.channels,
            collapsed: false,
            rows: rows,
          ),
        ];
}

/// Pure: the nearest unread channel above and below what the reader sees.
/// [rows] are the list's channels in order; [placed] holds the rows laid
/// out now, by id, with their top and bottom relative to the top of the
/// visible part, which is [height] tall. Rows not laid out are further
/// away than every laid-out one, on the side their place in [rows] says.
({String? above, String? below}) unreadOutside({
  required List<({String id, bool unread})> rows,
  required Map<String, ({double top, double bottom})> placed,
  required double height,
}) {
  final firstPlaced = rows.indexWhere((r) => placed.containsKey(r.id));
  String? above;
  String? below;
  for (final (i, row) in rows.indexed) {
    if (!row.unread) continue;
    final at = placed[row.id];
    final isAbove = at == null
        ? firstPlaced >= 0 && i < firstPlaced
        : at.bottom <= 0;
    final isBelow = at == null
        ? firstPlaced < 0 || i > firstPlaced
        : at.top >= height;
    if (isAbove) above = row.id;
    if (isBelow) {
      below ??= row.id;
    }
  }
  return (above: above, below: below);
}
