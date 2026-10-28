import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/channel_info/people_list.dart';
import 'package:matterleast/screens/channel_info/people_picker_screen.dart';
import 'package:matterleast/screens/open_page.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/you/user_profile_sheet.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/content_page.dart';

/// Who is in a channel, admins first, with search and presence.
class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({
    required this.url,
    required this.channelId,
    required this.teamId,
    required this.title,
    required this.canAdd,
    this.canRemove = false,
    super.key,
  });

  final String url;
  final String channelId;
  final String teamId;
  final String title;
  final bool canAdd;

  /// Whether each other member has a button to take them out.
  final bool canRemove;

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  final _removed = ValueNotifier<Set<String>>(const {});
  var _refused = false;

  @override
  void dispose() {
    _removed.dispose();
    super.dispose();
  }

  Future<void> _remove(String userId, String name) async {
    final ok = await confirm(
      context,
      title: 'Remove from Channel',
      body: 'Are you sure you want to remove $name from the channel?',
      action: 'Remove',
      destructive: true,
    );
    if (!ok || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final host = Uri.parse(widget.url).host;
    try {
      final actions = await ref.read(channelActionsProvider(widget.url).future);
      await actions.removeMember(widget.channelId, userId);
      _removed.value = {..._removed.value, userId};
    } on Object catch (e) {
      final said = e is ServerError ? e.message : null;
      if (e is ServerError && const {403, 404, 501}.contains(e.statusCode)) {
        if (mounted) setState(() => _refused = true);
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't remove $name. "
            '${said != null && said.isNotEmpty ? said : requestProblemText(e, host)}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.url;
    final me = widget.canRemove && !_refused
        ? ref.watch(myUserIdProvider(url)).value
        : null;
    return ContentPage(
      title: Text('Members of ${widget.title}'),
      actions: [
        if (widget.canAdd)
          IconButton(
            tooltip: 'Add people',
            icon: const Icon(Icons.person_add_alt),
            onPressed: () => openPage(
              Navigator.of(context),
              addMembersScreen(
                url: url,
                teamId: widget.teamId,
                channelId: widget.channelId,
                channelTitle: widget.title,
              ),
            ),
          ),
      ],
      body: SafeArea(
        top: false,
        bottom: false,
        child: ValueListenableBuilder<Set<String>>(
          valueListenable: _removed,
          builder: (context, removed, _) => PeopleList(
            url: url,
            hidden: removed,
            loadPage: (page) async =>
                (await ref.read(directoryProvider(url).future))
                    .members(widget.channelId, page: page),
            search: (term) async =>
                (await ref.read(directoryProvider(url).future)).searchPeople(
                  term,
                  teamId: widget.teamId,
                  inChannel: widget.channelId,
                ),
            onTap: (person) =>
                showUserProfile(context, url: url, userId: person.id),
            trailing: me == null
                ? null
                : (person) => person.id == me
                      ? const SizedBox.shrink()
                      : IconButton(
                          tooltip: 'Remove ${person.title} from channel',
                          icon: const Icon(Icons.person_remove_outlined),
                          onPressed: () =>
                              unawaited(_remove(person.id, person.title)),
                        ),
            emptyTitle: 'Nobody here yet',
            emptyBody: widget.canAdd
                ? 'Add people with the button at the top.'
                : 'Members show up here once they join.',
          ),
        ),
      ),
    );
  }
}
