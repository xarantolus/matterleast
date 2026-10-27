import 'package:freezed_annotation/freezed_annotation.dart';

part 'panes.freezed.dart';

/// Material 3 window size classes, by the window's width in dp.
enum WindowClass {
  compact,
  medium,
  expanded,
  large;

  /// The channel list and the conversation sit side by side.
  bool get showsPanes => index >= WindowClass.expanded.index;

  /// A thread opens in a third pane beside its channel.
  bool get showsThreadPane => this == WindowClass.large;
}

WindowClass windowClassOf(double width) => switch (width) {
  >= 1200 => WindowClass.large,
  >= 840 => WindowClass.expanded,
  >= 600 => WindowClass.medium,
  _ => WindowClass.compact,
};

/// Width of the channel list beside the rail when panes show.
double listPaneWidth(WindowClass windowClass) =>
    windowClass == WindowClass.large ? 360 : 320;

/// Width of the thread pane beside the channel.
const threadPaneWidth = 400.0;

/// Message columns wider than this are hard to read; wider panes centre it.
const readableWidth = 840.0;

/// A conversation that can be open in a pane or a route.
@freezed
sealed class ConversationTarget with _$ConversationTarget {
  const factory ConversationTarget.channel({
    required String url,
    required String channelId,
    required String title,
    String? teamId,
    String? highlightPostId,

    /// The composer takes the keyboard when it shows, as after Reply.
    @Default(false) bool focusComposer,
  }) = ChannelTarget;

  const factory ConversationTarget.thread({
    required String url,
    required String channelId,
    required String rootId,
    required String channelName,
    String? teamId,
    String? highlightPostId,
    @Default(false) bool focusComposer,
  }) = ThreadTarget;
}

/// The conversations open beside the channel list on a wide screen.
@freezed
abstract class Panes with _$Panes {
  const factory Panes({ChannelTarget? channel, ThreadTarget? thread}) = _Panes;

  const Panes._();

  static const none = Panes();

  bool get isEmpty => channel == null && thread == null;

  /// [target] opened: a channel replaces the channel and keeps its own
  /// thread; a thread comes with its channel beside it.
  Panes open(ConversationTarget target) => switch (target) {
    ChannelTarget() => Panes(
      channel: target,
      thread: _sameChannel(thread, target) ? thread : null,
    ),
    ThreadTarget() => Panes(
      channel: _sameChannel(channel, target) ? channel : _channelOf(target),
      thread: target,
    ),
  };

  /// Back: the thread closes first, then the channel.
  /// Without what shows the channel [channelId] of [url], which the user
  /// left.
  Panes without(String url, String channelId) {
    bool shows(ConversationTarget? t) =>
        t != null && t.url == url && t.channelId == channelId;
    return Panes(
      channel: shows(channel) ? null : channel,
      thread: shows(thread) ? null : thread,
    );
  }

  Panes back() => thread != null ? Panes(channel: channel) : none;

  /// What the conversation routes stacked on a narrow screen, oldest
  /// first, leave open once the screen is wide: the top one, with its
  /// channel when it is a thread.
  static Panes fromStack(List<ConversationTarget> stack) {
    if (stack.isEmpty) return none;
    return switch (stack.last) {
      final ChannelTarget channel => Panes(channel: channel),
      final ThreadTarget thread => Panes(
        channel:
            stack.whereType<ChannelTarget>().lastWhereOrNull(
              (c) => _sameChannel(c, thread),
            ) ??
            _channelOf(thread),
        thread: thread,
      ),
    };
  }

  /// The routes that show these panes on a narrow screen, bottom first.
  List<ConversationTarget> get stack => [?channel, ?thread];

  /// The conversation in the main pane, and the thread beside it when the
  /// window has room for a third pane.
  ({ConversationTarget? main, ThreadTarget? side}) shownIn(
    WindowClass windowClass,
  ) => windowClass.showsThreadPane
      ? (main: channel ?? thread, side: channel == null ? null : thread)
      : (main: thread ?? channel, side: null);

  static bool _sameChannel(ConversationTarget? a, ConversationTarget b) =>
      a != null && a.url == b.url && a.channelId == b.channelId;

  static ChannelTarget _channelOf(ThreadTarget thread) => ChannelTarget(
    url: thread.url,
    channelId: thread.channelId,
    title: thread.channelName,
    teamId: thread.teamId,
  );
}

extension<T> on Iterable<T> {
  T? lastWhereOrNull(bool Function(T) test) {
    T? found;
    for (final e in this) {
      if (test(e)) found = e;
    }
    return found;
  }
}
