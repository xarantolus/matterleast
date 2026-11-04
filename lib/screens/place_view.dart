import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/open_history.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/agents/agents_screen.dart';
import 'package:matterleast/screens/drafts/drafts_screen.dart';
import 'package:matterleast/screens/open_page.dart';
import 'package:matterleast/screens/root/open_history.dart';
import 'package:matterleast/screens/threads/team_threads_screen.dart';

/// Opens a team-wide page; unless [recordHistory] is false, Back and Forward
/// return to it like to a conversation.
Future<void> openPlaceView(
  NavigatorState navigator,
  PlaceView view, {
  required String url,
  required String teamId,
  required String teamName,
  bool recordHistory = true,
}) {
  if (recordHistory && navigator.mounted) {
    final container = ProviderScope.containerOf(
      navigator.context,
      listen: false,
    );
    settleLocation(container);
    container
        .read(openHistoryProvider)
        .push(
          Location(
            place: RailTarget(url: url, teamId: teamId),
            view: view,
          ),
        );
  }
  return openPage(navigator, switch (view) {
    PlaceView.threads => TeamThreadsScreen(
      url: url,
      teamId: teamId,
      teamName: teamName,
    ),
    PlaceView.drafts => DraftsScreen(
      url: url,
      teamId: teamId,
      teamName: teamName,
    ),
    PlaceView.agents => AgentsScreen(url: url),
  }, view: view);
}
