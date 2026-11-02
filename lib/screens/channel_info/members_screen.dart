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
import 'package:matterleast/ui/try_action.dart';

/// Who is in a channel, admins first, with search and presence.
class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({
    required this.url,
    required this.channelId,
    required this.teamId,
    required this.title,
    required this.canAdd,
    this.canRemove = false,
    this.canChangeRoles = false,
    super.key,
  });

  final String url;
  final String channelId;
  final String teamId;
  final String title;
  final bool canAdd;

  /// Whether each other member has a button to take them out.
  final bool canRemove;

  /// Whether each other member's menu offers making them a channel admin.
  final bool canChangeRoles;

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
    await tryAction(
      context,
      hostOf(widget.url),
      failure: "Couldn't remove $name.",
      problem: serverSaidText,
      onFailed: _refuse,
      () async {
        final actions = await ref.read(
          channelActionsProvider(widget.url).future,
        );
        await actions.removeMember(widget.channelId, userId);
        _removed.value = {..._removed.value, userId};
      },
    );
  }

  void _refuse(Object e) {
    if (e is ServerError && const {403, 404, 501}.contains(e.statusCode)) {
      if (mounted) setState(() => _refused = true);
    }
  }

  Future<void> _setAdmin(String userId, String name, bool admin) async {
    await tryAction(
      context,
      hostOf(widget.url),
      failure: "Couldn't change $name.",
      problem: serverSaidText,
      onFailed: _refuse,
      () async {
        final actions = await ref.read(
          channelActionsProvider(widget.url).future,
        );
        await actions.setChannelAdmin(widget.channelId, userId, admin: admin);
        ref.invalidate(channelAdminsProvider(widget.url, widget.channelId));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.url;
    final admins =
        ref.watch(channelAdminsProvider(url, widget.channelId)).value ??
        const <String>{};
    final changeRoles = widget.canChangeRoles && !_refused;
    final me = (widget.canRemove || changeRoles) && !_refused
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
            trailing: (person) {
              final isMe = person.id == me;
              final admin = admins.contains(person.id);
              final removable = me != null && widget.canRemove && !isMe;
              final roles = me != null && changeRoles && !isMe;
              if (!admin && !removable && !roles) {
                return const SizedBox.shrink();
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (admin) const _AdminTag(),
                  if (roles)
                    PopupMenuButton<bool>(
                      tooltip: 'Roles of ${person.title}',
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                      onSelected: (make) =>
                          unawaited(_setAdmin(person.id, person.title, make)),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: !admin,
                          child: Text(
                            admin
                                ? 'Remove channel admin'
                                : 'Make channel admin',
                          ),
                        ),
                      ],
                    ),
                  if (removable)
                    IconButton(
                      tooltip: 'Remove ${person.title} from channel',
                      icon: const Icon(Icons.person_remove_outlined),
                      onPressed: () =>
                          unawaited(_remove(person.id, person.title)),
                    ),
                ],
              );
            },
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

class _AdminTag extends StatelessWidget {
  const _AdminTag();

  @override
  Widget build(BuildContext context) => Chip(
    label: const Text('Admin'),
    visualDensity: VisualDensity.compact,
    padding: EdgeInsets.zero,
  );
}
