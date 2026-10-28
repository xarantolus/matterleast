import 'package:matterleast/app/desktop/unread_count.dart';
import 'package:matterleast/domain/conversation_restore.dart';
import 'package:matterleast/domain/desktop_window.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'window_title.g.dart';

/// The conversation on top, or null while a channel list shows; set by
/// the conversation memory.
@Riverpod(keepAlive: true)
class OpenConversation extends _$OpenConversation {
  @override
  SavedConversation? build() => null;

  void set(SavedConversation? conversation) => state = conversation;
}

/// What the OS shows for the window: the open conversation and the unread
/// count.
@riverpod
String windowTitleText(Ref ref) {
  final open = ref.watch(openConversationProvider);
  final teams = open == null
      ? null
      : ref.watch(railTeamsProvider(open.url)).value;
  final team = teams
      ?.where((t) => t.id == open?.teamId)
      .map((t) => t.displayName)
      .firstOrNull;
  return windowTitle(
    conversation: open?.title,
    team: team,
    unread: ref.watch(unreadCountProvider),
  );
}
