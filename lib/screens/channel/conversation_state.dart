import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/domain/conversation_open.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/user_profile.dart';
import 'package:matterleast/ui/presence_dot.dart';

part 'conversation_state.freezed.dart';

/// Everything a channel or thread screen shows, apart from the scroll
/// position, which the list keeps.
@freezed
abstract class ConversationState with _$ConversationState {
  const factory ConversationState({
    /// Null until the database answered once.
    ConversationWindow? window,
    @Default(<ListRow>[]) List<ListRow> rows,

    /// The refresh after opening is running.
    @Default(false) bool refreshing,
    ApiError? refreshFailure,
    @Default(false) bool loadingOlder,
    ApiError? olderFailure,

    /// Messages that arrived live while the screen was open, by key, with
    /// when they arrived: they animate in and count towards "N new".
    @Default(<Object, DateTime>{}) Map<Object, DateTime> arrived,

    /// Grows when the list moves to another stretch of history, so it
    /// opens anew there.
    @Default(0) int generation,

    /// How this [generation] opens, once its rows are there.
    @Default(OpenIntent.usual) OpenIntent intent,
    SavedPlace? saved,
    String? highlightKey,
  }) = _ConversationState;
}

enum OpenIntent {
  /// At the message asked for, the new-messages line or the saved place.
  usual,

  /// At the newest message.
  bottom,
}

/// What fills the list area.
sealed class ConversationBody {
  const ConversationBody();
}

/// Nothing stored yet and the first page is on its way.
final class BodyLoading extends ConversationBody {
  const BodyLoading();
}

final class BodyFailed extends ConversationBody {
  const BodyFailed(this.text);
  final String text;
}

final class BodyEmpty extends ConversationBody {
  const BodyEmpty();
}

final class BodyReady extends ConversationBody {
  const BodyReady();
}

ConversationBody conversationBody(ConversationState s, {required String host}) {
  final window = s.window;
  if (window == null) return const BodyLoading();
  final shown = window.posts.isNotEmpty || window.root != null;
  if (shown) return const BodyReady();
  if (window.loaded && window.reachesStart) return const BodyEmpty();
  if (s.refreshFailure case final cause? when !s.refreshing) {
    return BodyFailed(connectionProblemText(cause, host));
  }
  return const BodyLoading();
}

/// The quiet line under the title: why the shown messages may be stale,
/// else the partner's presence and custom status for a direct message,
/// the members' names for a group message, the member count otherwise.
String? conversationSubtitle(ConversationState s, {UserProfile? partner}) {
  if (staleFailure(s) case final cause?) return staleDataNotice(cause);
  switch (s.window?.channelType) {
    case 'D':
      if (partner == null) return null;
      final presence = presenceLabel(partner.status);
      final text = partner.customStatus?.text ?? '';
      return text.isEmpty ? presence : '$presence · $text';
    case 'G':
      final names = s.window?.channelName ?? '';
      return names.isEmpty ? null : names;
  }
  final count = s.window?.memberCount;
  if (count == null) return null;
  return count == 1 ? '1 member' : '$count members';
}

/// The partner's custom status emoji, shown before the subtitle while it
/// tells their status.
String? conversationSubtitleEmoji(ConversationState s, {UserProfile? partner}) {
  if (s.window?.channelType != 'D' || staleFailure(s) != null) return null;
  final emoji = partner?.customStatus?.emoji ?? '';
  return emoji.isEmpty ? null : emoji;
}

/// The thread's subtitle: its channel, and why the shown replies may be
/// stale.
String threadSubtitle(ConversationState s, {required String channelName}) {
  final stored = s.window?.channelName ?? '';
  final name = stored.isNotEmpty ? stored : channelName;
  return switch (staleFailure(s)) {
    final cause? => '$name · ${staleDataNotice(cause)}',
    null => name,
  };
}

/// Messages are on screen, stored or fetched.
bool showsMessages(ConversationState s) =>
    (s.window?.posts.isNotEmpty ?? false) || s.window?.root != null;

/// Why the last refresh failed, while messages from before are shown.
ApiError? staleFailure(ConversationState s) =>
    showsMessages(s) && !s.refreshing ? s.refreshFailure : null;

/// What a screen reader is told when the conversation changes from
/// [before] to [after]: messages from others that arrived live, and the
/// user's own messages that failed to go out.
List<String> conversationNews(
  ConversationState before,
  ConversationState after, {
  required String? myUserId,
}) {
  final posts = after.window?.posts ?? const <PostItem>[];
  final arrived = [
    for (final p in posts)
      if (after.arrived.containsKey(p.key) &&
          !before.arrived.containsKey(p.key) &&
          p.userId != myUserId &&
          !p.isSystem)
        p,
  ];
  final wasFailed = {
    for (final p in before.window?.posts ?? const <PostItem>[])
      if (p.sendState == 'failed') p.key,
  };
  final failed = posts
      .where((p) => p.sendState == 'failed' && !wasFailed.contains(p.key))
      .length;
  return [
    if (arrived.length == 1) 'New message from ${arrived.single.authorName}',
    if (arrived.length > 1) '${arrived.length} new messages',
    if (failed == 1) 'Your message was not sent',
    if (failed > 1) '$failed of your messages were not sent',
  ];
}

/// The user just sent a message here: one waiting to go out that wasn't
/// there before.
bool sentJustNow(ConversationState before, ConversationState after) {
  final known = {
    for (final p in before.window?.posts ?? const <PostItem>[]) p.key,
  };
  return (after.window?.posts ?? const <PostItem>[]).any(
    (p) => p.sendState == 'pending' && !known.contains(p.key),
  );
}
