import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/paged_search.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/channel_info/people_list.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/window_bar.dart';

/// Picks people for a channel or a new conversation; the picked ones show
/// as chips above the list.
class PeoplePickerScreen extends ConsumerStatefulWidget {
  const PeoplePickerScreen({
    required this.url,
    required this.title,
    required this.action,
    required this.loadPage,
    required this.search,
    required this.onDone,
    required this.emptyTitle,
    required this.emptyBody,
    this.limit,
    this.limitText,
    super.key,
  });

  final String url;
  final String title;

  /// The button's label, such as "Add".
  final String action;
  final Future<ServerPage<String>> Function(int page) loadPage;
  final Future<List<String>> Function(String term) search;

  /// Does the work for the picked people; the screen closes itself first
  /// when [onDone] returns normally.
  final Future<void> Function(NavigatorState navigator, List<SwitchItem>)
  onDone;
  final String emptyTitle;
  final String emptyBody;
  final int? limit;
  final String? limitText;

  @override
  ConsumerState<PeoplePickerScreen> createState() => _PeoplePickerScreenState();
}

class _PeoplePickerScreenState extends ConsumerState<PeoplePickerScreen> {
  final _picked = <SwitchItem>[];
  var _working = false;

  void _toggle(SwitchItem person) {
    setState(() {
      if (_picked.any((p) => p.id == person.id)) {
        _picked.removeWhere((p) => p.id == person.id);
      } else if (widget.limit != null && _picked.length >= widget.limit!) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(widget.limitText ?? '')));
      } else {
        _picked.add(person);
      }
    });
  }

  Future<void> _done() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _working = true);
    try {
      await widget.onDone(navigator, List.of(_picked));
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _working = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(requestProblemText(e, Uri.parse(widget.url).host)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: WindowAppBar(
      title: Text(widget.title),
      actions: [
        TextButton(
          style: context.barButtonStyle,
          onPressed: _picked.isEmpty || _working ? null : _done,
          child: Text(widget.action),
        ),
      ],
      bottom: ProgressSlot(active: _working),
    ),
    body: SafeArea(
      top: false,
      bottom: false,
      child: PeopleList(
        url: widget.url,
        loadPage: widget.loadPage,
        search: widget.search,
        onTap: _toggle,
        emptyTitle: widget.emptyTitle,
        emptyBody: widget.emptyBody,
        trailing: (person) => Checkbox(
          value: _picked.any((p) => p.id == person.id),
          onChanged: (_) => _toggle(person),
        ),
        header: _picked.isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.sm,
                  Spacing.md,
                  0,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.xs,
                    children: [
                      for (final p in _picked)
                        InputChip(
                          label: Text(p.title),
                          onDeleted: () => _toggle(p),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    ),
  );
}

/// Adds people from the team to a channel.
Widget addMembersScreen({
  required String url,
  required String teamId,
  required String channelId,
  required String channelTitle,
}) => Consumer(
  builder: (context, ref, _) => PeoplePickerScreen(
    url: url,
    title: 'Add to $channelTitle',
    action: 'Add',
    loadPage: (page) async =>
        (await ref.read(directoryProvider(url).future))
            .nonMembers(teamId, channelId, page: page),
    search: (term) async =>
        (await ref.read(directoryProvider(url).future))
            .searchPeople(term, teamId: teamId, notInChannel: channelId),
    emptyTitle: 'Everyone is here',
    emptyBody: 'Everybody in the team is already in this channel.',
    onDone: (navigator, people) async {
      final actions = await ref.read(channelActionsProvider(url).future);
      await actions.addMembers(channelId, [for (final p in people) p.id]);
      navigator.pop();
    },
  ),
);

/// Starts a direct message with one person or a group message with up to
/// seven.
Widget newMessageScreen({required String url, required String teamId}) =>
    Consumer(
      builder: (context, ref, _) => PeoplePickerScreen(
        url: url,
        title: 'New message',
        action: 'Start',
        limit: 7,
        limitText: 'Group messages are limited to 7 people besides you.',
        loadPage: (page) async =>
            (await ref.read(directoryProvider(url).future))
                .people(teamId: teamId, page: page),
        search: (term) async =>
            (await ref.read(directoryProvider(url).future))
                .searchPeople(term, teamId: teamId),
        emptyTitle: 'Nobody to message yet',
        emptyBody: 'People on this server show up here.',
        onDone: (navigator, people) async {
          final actions = await ref.read(channelActionsProvider(url).future);
          final channelId = people.length == 1
              ? await actions.directChannel(people.single.id)
              : await actions.groupChannel([for (final p in people) p.id]);
          // The picker goes first, so the channel opens over the root.
          navigator.pop();
          unawaited(
            openConversation(
              navigator,
              url: url,
              channelId: channelId,
              title: [for (final p in people) p.title].join(', '),
              teamId: teamId,
            ),
          );
        },
      ),
    );
