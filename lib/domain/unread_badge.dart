import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/rail.dart';

/// Pure: what one server adds to the window's badge: the mentions of its
/// teams, as the rail counts them, and the unread messages of its direct
/// and group messages, as Home counts them.
int unreadMentions({
  required Iterable<RailTeam> teams,
  required Iterable<InboxItem> unread,
}) =>
    teams.fold(0, (sum, t) => sum + t.mentions) +
    unread
        .where((i) => i.kind == InboxKind.direct || i.kind == InboxKind.group)
        .fold(0, (sum, i) => sum + i.count);

/// What the tray icon and the taskbar button show for [count] unread
/// mentions and direct messages.
typedef WindowBadge = ({
  /// The tray icon with a dot.
  bool dot,

  /// The taskbar overlay: none (0), the number (1–9), or "9+" (10).
  int overlay,
});

WindowBadge windowBadge(int count) =>
    (dot: count > 0, overlay: count <= 0 ? 0 : (count > 9 ? 10 : count));

/// Pure: whether the taskbar button flashes as the count goes from
/// [before] to [now]: only when a mention or direct message arrived while
/// the window isn't focused. The first count after launch ([before] null)
/// never flashes, nor does reading or a count going down.
bool flashesTaskbar({
  required int? before,
  required int now,
  required bool focused,
}) => !focused && before != null && now > before;
