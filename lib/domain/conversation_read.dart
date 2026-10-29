import 'package:matterleast/domain/time_labels.dart';

/// Pure: whether the open conversation is marked read now. The newest
/// message must be in view while the app is in front, and something new
/// must have arrived since the last mark; [ready] is false while the
/// opening refresh still runs, which may fetch newer messages.
bool shouldMarkRead({
  required bool atNewest,
  required bool inFront,
  required bool pending,
  required bool ready,
}) => atNewest && inFront && pending && ready;

/// "12 new messages since 14:05", or "since yesterday at 14:05".
String newMessagesText(
  int count,
  DateTime? since,
  DateTime now, {
  required bool use24,
}) {
  final what = count == 1 ? '1 new message' : '$count new messages';
  return since == null
      ? what
      : '$what since ${whenLabel(since, now, use24: use24)}';
}
