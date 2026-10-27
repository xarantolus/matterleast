import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/domain/panes.dart';

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
}

/// The step that opens [target] over the conversations [open], bottom first.
StackStep stackStepFor(
  List<ConversationTarget> open,
  ConversationTarget target,
) {
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
