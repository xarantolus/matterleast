import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/keyboard_shortcuts.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/channel_info/people_picker_screen.dart';
import 'package:matterleast/screens/home/home_providers.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/open_page.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/rail_switch.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/you/you_page.dart';

/// Pure: the channel [forward] of [current] in [list]'s shown rows, or
/// before it, wrapping round; only unread ones with [unreadOnly]. From no
/// channel the first (or last) one. Null when there is none to go to.
ChannelItem? channelStep(
  ChannelList list,
  String? current, {
  required bool forward,
  bool unreadOnly = false,
}) {
  final seen = <String>{};
  final rows = [
    for (final section in list.sections)
      for (final row in section.shown)
        if (seen.add(row.id)) row,
  ];
  final count = rows.length;
  final at = rows.indexWhere((r) => r.id == current);
  final start = at >= 0 ? at : (forward ? -1 : count);
  for (var k = 1; k <= count; k++) {
    final row = rows[(start + (forward ? k : -k)) % count];
    if (row.id == current) continue;
    if (unreadOnly && !row.unread && row.mentions == 0) continue;
    return row;
  }
  return null;
}

/// The root's part of the keyboard shortcuts: the switcher, moving
/// through the shown team's channels, the You page, and Esc closing the
/// thread pane.
class RootShortcuts extends ConsumerWidget {
  const RootShortcuts({
    required this.onSwitcher,
    required this.child,
    super.key,
  });

  final VoidCallback onSwitcher;
  final Widget child;

  void _step(BuildContext context, WidgetRef ref, ChannelStepIntent intent) {
    final target = ref.read(railSelectionProvider);
    if (target == null) return;
    final url = target.url;
    final teams = ref.read(railTeamsProvider(url)).value ?? const [];
    final teamId = shownTeam(target, teams);
    if (teamId == null) return;
    final list = ref.read(channelListProvider(url, teamId)).value;
    if (list == null) return;
    final current =
        ref.read(openPanesProvider).channel?.channelId ??
        ref.read(conversationRoutesProvider).live.lastOrNull?.target.channelId;
    final next = channelStep(
      list,
      current,
      forward: intent.forward,
      unreadOnly: intent.unreadOnly,
    );
    if (next == null) return;
    unawaited(
      openConversation(
        Navigator.of(context),
        url: url,
        channelId: next.id,
        title: next.title,
        teamId: teamId,
      ),
    );
  }

  void _newMessage(BuildContext context, WidgetRef ref) {
    final target = ref.read(railSelectionProvider);
    if (target == null) return;
    final teams = ref.read(railTeamsProvider(target.url)).value ?? const [];
    final teamId = shownTeam(target, teams);
    if (teamId == null) return;
    unawaited(
      openPage(
        Navigator.of(context),
        newMessageScreen(url: target.url, teamId: teamId),
        popout: true,
      ),
    );
  }

  void _showMentions(BuildContext context, WidgetRef ref) {
    ref.read(homeFilterSelectionProvider.notifier).select(InboxFilter.mentions);
    unawaited(showPlace(Navigator.of(context), null));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Actions(
    actions: {
      OpenMentionsIntent: CallbackAction<OpenMentionsIntent>(
        onInvoke: (_) => _showMentions(context, ref),
      ),
      NewMessageIntent: CallbackAction<NewMessageIntent>(
        onInvoke: (_) => _newMessage(context, ref),
      ),
      OpenSwitcherIntent: CallbackAction<OpenSwitcherIntent>(
        onInvoke: (_) => onSwitcher(),
      ),
      ChannelStepIntent: CallbackAction<ChannelStepIntent>(
        onInvoke: (intent) => _step(context, ref, intent),
      ),
      OpenAccountIntent: CallbackAction<OpenAccountIntent>(
        onInvoke: (_) => openYou(context),
      ),
      DismissIntent: _CloseOnTop(ref),
    },
    // Lets the keys find these actions while nothing below has the focus.
    child: Focus(canRequestFocus: false, skipTraversal: true, child: child),
  );
}

/// Esc with nothing nearer to close: the content view over the
/// conversation, else the thread, else the conversation.
class _CloseOnTop extends Action<DismissIntent> {
  _CloseOnTop(this.ref);

  final WidgetRef ref;

  @override
  bool isEnabled(DismissIntent intent) =>
      ref.read(paneRoutesProvider).stack.isNotEmpty ||
      !ref.read(openPanesProvider).isEmpty;

  @override
  void invoke(DismissIntent intent) {
    final content = ref.read(paneRoutesProvider);
    final pane = content.navigator;
    if (content.stack.isNotEmpty && pane != null) {
      unawaited(pane.maybePop());
    } else {
      ref.read(openPanesProvider.notifier).back();
    }
  }
}
