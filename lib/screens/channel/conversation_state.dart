import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/domain/conversation_open.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/user_profile.dart';
import 'package:matterleast/screens/you/user_profile_sheet.dart';
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
    @Default(false) bool olderFailed,

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
  final hasData =
      (s.window?.posts.isNotEmpty ?? false) || s.window?.root != null;
  if (hasData && !s.refreshing) {
    switch (s.refreshFailure) {
      case Unreachable() || RequestTimeout():
        return 'Offline · showing saved data';
      case _?:
        return "Couldn't refresh · showing saved data";
      case null:
    }
  }
  switch (s.window?.channelType) {
    case 'D':
      if (partner == null) return null;
      final presence = presenceLabel(partner.status);
      final custom = partner.customStatus;
      if (custom == null) return presence;
      final words = [
        if (custom.emoji.isNotEmpty) emojiText(custom.emoji),
        if (custom.text.isNotEmpty) custom.text,
      ].join(' ');
      return '$presence · $words';
    case 'G':
      final names = s.window?.channelName ?? '';
      return names.isEmpty ? null : names;
  }
  final count = s.window?.memberCount;
  if (count == null) return null;
  return count == 1 ? '1 member' : '$count members';
}
