import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/restore_conversation.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/conversation_memory.dart';
import 'package:matterleast/screens/root/rail_selection.dart';

/// Shows [place] in the rail (null is Home), the one way the rail and the
/// You page switch: what is open gives way, and what was open there last
/// opens again at its reading position. With nothing remembered, or once
/// it can't open any more, the place's list shows.
Future<void> showPlace(NavigatorState navigator, RailTarget? place) async {
  if (!navigator.mounted) return;
  final container = ProviderScope.containerOf(navigator.context, listen: false);
  if (container.read(railSelectionProvider) == place) return;
  final remembered = container.read(conversationMemoryProvider).at(place);
  container.read(railSelectionProvider.notifier).select(place);
  closeConversations(navigator);
  if (remembered == null) return;
  final stack = await openableStack(container, remembered);
  // The user may have moved on while the channels were read.
  if (!navigator.mounted || container.read(railSelectionProvider) != place) {
    return;
  }
  for (final target in stack) {
    unawaited(reopenConversation(navigator, target, instant: true));
  }
}
