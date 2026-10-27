import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/domain/post_list.dart';

/// What a screen reader says for one message, in one stop. Each part is
/// left out when empty; parts are read with a pause between them.
String messageLabel({
  required String author,
  required String time,
  String? tag,
  String? priority,
  bool ephemeral = false,
  bool pinned = false,
  bool saved = false,
  String text = '',
  String? edited,
  int files = 0,
  String? preview,
  LinkedPostPreview? linked,
  List<ReactionGroup> reactions = const [],
  bool acknowledged = false,
  String? replies,
  String? sendState,
}) => [
  [
    author,
    ?tag,
    time,
    ?priority,
    if (ephemeral) 'only visible to you',
    if (pinned) 'pinned',
    if (saved) 'saved',
  ].join(', '),
  [text, if (edited != null) '(edited $edited)'].join(' ').trim(),
  if (files == 1) '1 attachment',
  if (files > 1) '$files attachments',
  if (preview != null && preview.isNotEmpty) 'Link preview: $preview',
  if (linked != null)
    'Quoted message from ${linked.authorName}: ${linked.message.trim()}',
  if (reactions.isNotEmpty)
    'Reactions: ${[for (final r in reactions) reactionWords(r)].join(', ')}',
  if (acknowledged) 'acknowledged by you',
  ?replies,
  ?sendState,
].where((part) => part.isNotEmpty).join('\n');

/// Pure: a reaction in words: the emoji as its character, which TalkBack
/// names, how many, and whether the user is one of them.
String reactionWords(ReactionGroup group) => [
  emojiWords(group.emojiName),
  '${group.count}',
  if (group.mine) 'including you',
].join(' ');

/// Pure: an emoji's character, or its name in words for a custom one.
String emojiWords(String name) =>
    unicodeForName(name) ?? name.replaceAll('_', ' ');

/// Pure: a thread's replies in words, for the post that starts it.
String? repliesWords({
  required int count,
  required int unread,
  required bool draft,
  String? lastReply,
}) {
  if (count == 0) return draft ? 'Draft reply' : null;
  return [
    count == 1 ? '1 reply' : '$count replies',
    if (unread > 0) '$unread new',
    if (lastReply != null) 'last reply $lastReply',
    if (draft) 'draft reply',
  ].join(', ');
}
