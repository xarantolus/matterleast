import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/preview_text.dart';

/// A stored draft as the list reads it.
typedef DraftInput = ({
  String channelId,
  String rootId,
  String message,
  int files,
  DateTime updatedAt,
});

/// One row of the drafts list.
typedef DraftItem = ({
  String channelId,

  /// Empty for a draft in the channel itself.
  String rootId,

  /// Where it goes: `#channel`, or the people of a direct message.
  String title,

  /// The partner of a direct message, for the avatar.
  String? userId,
  String preview,
  DateTime updatedAt,
});

/// Pure: the drafts in [channels] (one team's channels and the direct
/// messages), newest first. Drafts in channels the user is no longer in,
/// and empty ones, are left out.
List<DraftItem> buildDraftList(
  Iterable<DraftInput> drafts, {
  required Map<String, ChannelInput> channels,
  required String myId,
  required Map<String, PersonInput> people,
  String? nameFormat,
}) {
  final items = <DraftItem>[];
  for (final d in drafts) {
    final c = channels[d.channelId];
    if (c == null || (d.message.trim().isEmpty && d.files == 0)) continue;
    final conversation = c.type == 'D' || c.type == 'G';
    final name = conversationName(
      c,
      myId: myId,
      people: people,
      nameFormat: nameFormat,
    );
    final text = previewText(d.message);
    items.add((
      channelId: d.channelId,
      rootId: d.rootId,
      title: conversation ? name.title : '#${c.displayName}',
      userId: name.userId,
      preview: text.isNotEmpty
          ? text
          : d.files == 1
          ? '1 file'
          : '${d.files} files',
      updatedAt: d.updatedAt,
    ));
  }
  items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return items;
}
