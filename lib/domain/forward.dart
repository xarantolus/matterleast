/// Pure: the web link of a message, `<server>/<team>/pl/<post id>`.
String postPermalink(String serverUrl, String teamName, String postId) =>
    '${serverUrl.replaceFirst(RegExp(r'/+$'), '')}/$teamName/pl/$postId';

/// Pure: the post that forwards a message: the comment, then the link on
/// its own line, which readers see as the linked message's card.
String forwardText(String comment, String permalink) {
  final note = comment.trim();
  return note.isEmpty ? permalink : '$note\n$permalink';
}

/// Pure: whether a message can be reported: someone else's, sent, and not
/// a system or ephemeral one, on a server whose team has reporting on.
bool canReport({
  required bool enabled,
  required bool mine,
  required bool system,
  required bool unsent,
  required bool ephemeral,
}) => enabled && !mine && !system && !unsent && !ephemeral;
