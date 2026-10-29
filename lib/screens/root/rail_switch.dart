import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/restore_conversation.dart';
import 'package:matterleast/domain/open_history.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/conversation_memory.dart';
import 'package:matterleast/screens/root/open_history.dart';
import 'package:matterleast/screens/root/rail_selection.dart';

/// Shows [place] (null is Home) and reopens what was open there, else its list.
Future<void> showPlace(NavigatorState navigator, RailTarget? place) async {
  if (!navigator.mounted) return;
  final container = ProviderScope.containerOf(navigator.context, listen: false);
  if (container.read(railSelectionProvider) == place) return;
  final remembered = container.read(conversationMemoryProvider).at(place);
  final before = shownLocation(container);
  container.read(railSelectionProvider.notifier).select(place);
  closePages(navigator);
  if (remembered == null) return;
  final stack = await openableStack(container, remembered);
  // The user may have moved on while the channels were read.
  if (!navigator.mounted || container.read(railSelectionProvider) != place) {
    return;
  }
  if (stack.isEmpty) return;
  final history = container.read(openHistoryProvider);
  settleHistory(history, before);
  history.push(Location(place: place, conversation: remembered));
  for (final target in stack) {
    unawaited(reopenConversation(navigator, target, instant: true));
  }
}
