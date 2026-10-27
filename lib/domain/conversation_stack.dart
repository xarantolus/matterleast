import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/domain/quick_switch.dart';

part 'conversation_stack.freezed.dart';

/// What opening a conversation does to the conversations already open on a
/// narrow screen, so they never pile up and Back leads to the list.
@freezed
sealed class StackStep with _$StackStep {
  /// None is open: it opens over whatever shows.
  const factory StackStep.push() = PushStep;

  /// The one at [index] already shows it: go back to it, at the message
  /// asked for.
  const factory StackStep.returnTo(int index) = ReturnToStep;

  /// The one at [index] is the thread's channel: go back to it and open the
  /// thread over it.
  const factory StackStep.pushOver(int index) = PushOverStep;

  /// Other conversations are open: the lowest, at [index], gives way to it.
  const factory StackStep.replace(int index) = ReplaceStep;

  /// Opened from outside the app: whatever shows gives way, and it opens
  /// over the list.
  const factory StackStep.overList() = OverListStep;
}

/// The step that opens [target] over the conversations [open], bottom first.
/// Opened [fromOutside] the app, as from a notification, it keeps only the
/// conversation itself or the thread's channel; anything else gives way, so
/// Back leads to the list.
StackStep stackStepFor(
  List<ConversationTarget> open,
  ConversationTarget target, {
  bool fromOutside = false,
}) {
  final step = _stepFor(open, target);
  return fromOutside && (step is PushStep || step is ReplaceStep)
      ? const StackStep.overList()
      : step;
}

StackStep _stepFor(List<ConversationTarget> open, ConversationTarget target) {
  if (open.isEmpty) return const StackStep.push();
  final same = open.lastIndexWhere((o) => sameConversation(o, target));
  if (same >= 0) return StackStep.returnTo(same);
  if (target is ThreadTarget) {
    final channel = open.lastIndexWhere(
      (o) =>
          o is ChannelTarget &&
          o.url == target.url &&
          o.channelId == target.channelId,
    );
    if (channel >= 0) return StackStep.pushOver(channel);
  }
  return const StackStep.replace(0);
}

/// Whether [a] and [b] show the same channel or thread, wherever they open.
bool sameConversation(ConversationTarget a, ConversationTarget b) =>
    a.url == b.url &&
    a.channelId == b.channelId &&
    switch ((a, b)) {
      (ChannelTarget(), ChannelTarget()) => true,
      (final ThreadTarget a, final ThreadTarget b) => a.rootId == b.rootId,
      _ => false,
    };

/// Why a conversation can't stay open in its channel.
enum ChannelGone {
  /// The user isn't in the channel any more.
  removed,

  /// It was archived, and the server hides archived channels.
  archived,
}

/// Why a conversation in [channel], as the channel list has it now (null
/// when it isn't there), has to close; null while it can stay open.
ChannelGone? channelGone(SwitchItem? channel, {required bool archivedShown}) {
  if (channel == null || !channel.joined) return ChannelGone.removed;
  if (channel.kind == SwitchKind.archived && !archivedShown) {
    return ChannelGone.archived;
  }
  return null;
}
