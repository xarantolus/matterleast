import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'pane_widths.freezed.dart';
part 'pane_widths.g.dart';

/// The side pane widths the user dragged to, in logical pixels; null keeps
/// the default. The conversation always takes the rest. The channel list
/// is kept apart for when a thread pane is open beside the conversation
/// and when none is.
@freezed
abstract class PaneWidths with _$PaneWidths {
  const factory PaneWidths({
    double? list,
    double? listBesideThread,
    double? thread,
  }) = _PaneWidths;

  factory PaneWidths.fromJson(Map<String, Object?> json) =>
      _$PaneWidthsFromJson(json);
}

const minListWidth = 240.0;
const maxListWidth = 560.0;
const minThreadWidth = 300.0;
const maxThreadWidth = 720.0;
const minConversationWidth = 360.0;

/// How far an arrow key moves a focused divider.
const paneWidthStep = 16.0;

/// The widths the side panes get in [room], the width shared by the
/// channel list, the conversation and the thread pane ([thread] null when
/// none shows). Each is held within its limits; when the conversation
/// would get less than its minimum the thread pane gives first, then the
/// list. The stored widths are not changed, so a window that grows back
/// gets them again.
({double list, double? thread}) fitPanes({
  required double room,
  required double list,
  double? thread,
}) {
  var fittedList = list.clamp(minListWidth, maxListWidth);
  var fittedThread = thread?.clamp(minThreadWidth, maxThreadWidth);
  var over = fittedList + (fittedThread ?? 0) + minConversationWidth - room;
  if (over > 0 && fittedThread != null) {
    final give = math.min(over, fittedThread - minThreadWidth);
    fittedThread -= give;
    over -= give;
  }
  if (over > 0) {
    fittedList -= math.min(over, fittedList - minListWidth);
  }
  return (list: fittedList, thread: fittedThread);
}

/// The width a pane may be dragged or stepped to: within its limits and
/// leaving the conversation its minimum beside [others], the other side
/// pane's shown width.
double resizedPane(
  double wanted, {
  required double room,
  required double others,
  required bool isThread,
}) {
  final (low, high) = isThread
      ? (minThreadWidth, maxThreadWidth)
      : (minListWidth, maxListWidth);
  final fits = room - others - minConversationWidth;
  return wanted.clamp(low, math.max(low, math.min(high, fits)));
}
