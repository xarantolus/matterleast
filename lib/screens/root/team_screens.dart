import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/team_actions.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/permissions.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/teams.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/channel_list/category_menu.dart';
import 'package:matterleast/screens/open_page.dart';
import 'package:matterleast/screens/root/rail_switch.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/failed_state.dart';
import 'package:matterleast/ui/try_action.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'team_screens.g.dart';

@riverpod
Future<TeamActions> teamActions(Ref ref, String url) async =>
    (await ref.watch(serverSessionProvider(url).future)).teams;

/// Open teams on [url] the user isn't in; asked again on each visit.
@Riverpod(retry: _noRetry)
Future<List<JoinableTeam>> joinableTeamList(Ref ref, String url) async =>
    (await ref.watch(teamActionsProvider(url).future)).joinable();

/// What the user may do about inviting people to a team.
@riverpod
Future<TeamInviteRights> teamInvite(Ref ref, String url, String teamId) async =>
    (await ref.watch(channelViewsProvider(url).future)).teamInvite(teamId);

/// Marks every unread channel of [teamId] read, with the server's reason in
/// a snackbar when that fails.
Future<void> markTeamRead(
  BuildContext context,
  WidgetRef ref,
  String url,
  String teamId,
) async {
  final list = await ref.read(channelListProvider(url, teamId).future);
  if (!context.mounted) return;
  await runCategoryAction(
    context,
    url,
    "Couldn't mark the team as read.",
    (a) => a.markAllRead(teamUnreadIds(list)),
  );
}

/// Whether [teamId] has anything unread, for offering "Mark all as read".
bool teamHasUnread(WidgetRef ref, String url, String teamId) {
  final list = ref.watch(channelListProvider(url, teamId)).value;
  return list != null && teamUnreadIds(list).isNotEmpty;
}

/// Shows the team behind an invite link and joins it when the user agrees.
Future<void> joinFromInvite(
  NavigatorState navigator,
  String url,
  String inviteId,
) async {
  final ref = ProviderScope.containerOf(navigator.context, listen: false);
  final messenger = ScaffoldMessenger.of(navigator.context);
  await tryAction(
    navigator.context,
    hostOf(url),
    failure: "Couldn't join the team.",
    () async {
      final actions = await ref.read(teamActionsProvider(url).future);
      final team = await actions.invitedTeam(inviteId);
      if (team == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('This invite link is no longer valid.')),
        );
        return;
      }
      final session = await ref.read(serverSessionProvider(url).future);
      final member = await (session.db.select(
        session.db.myTeams,
      )..where((t) => t.teamId.equals(team.id))).getSingleOrNull();
      if (member == null) {
        if (!navigator.mounted) return;
        final yes = await confirm(
          navigator.context,
          title: 'Join ${team.displayName}?',
          body: team.description.isEmpty
              ? 'You will see its channels and be able to post.'
              : team.description,
          action: 'Join',
        );
        if (!yes) return;
        await actions.joinByInvite(inviteId, team.id);
        messenger.showSnackBar(
          SnackBar(content: Text('Joined ${team.displayName}')),
        );
      }
      if (navigator.mounted) {
        await showPlace(navigator, RailTarget(url: url, teamId: team.id));
      }
    },
  );
}

/// Email invitations and the invite link, as a short popout.
class InvitePeopleScreen extends ConsumerStatefulWidget {
  const InvitePeopleScreen({
    required this.url,
    required this.teamId,
    required this.teamName,
    required this.rights,
    super.key,
  });

  final String url;
  final String teamId;
  final String teamName;
  final TeamInviteRights rights;

  @override
  ConsumerState<InvitePeopleScreen> createState() => _InvitePeopleState();
}

class _InvitePeopleState extends ConsumerState<InvitePeopleScreen> {
  final _text = TextEditingController();
  var _sending = false;
  String? _problem;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final parsed = parseEmails(_text.text);
    if (parsed.good.isEmpty || parsed.bad.isNotEmpty) {
      setState(
        () => _problem = parsed.bad.isNotEmpty
            ? '${parsed.bad.first} is not an email address.'
            : 'Enter at least one email address.',
      );
      return;
    }
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _sending = true;
      _problem = null;
    });
    try {
      await (await ref.read(teamActionsProvider(widget.url).future))
          .inviteByEmail(widget.teamId, parsed.good);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            parsed.good.length == 1
                ? 'Invitation sent'
                : '${parsed.good.length} invitations sent',
          ),
        ),
      );
      navigator.pop();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _problem =
            "Couldn't send the invitations. "
            '${requestProblemText(e, hostOf(widget.url))}';
      });
    }
  }

  @override
  Widget build(BuildContext context) => ContentPage(
    title: Text('Invite people to ${widget.teamName}'),
    progress: _sending,
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.rights.byEmail) ...[
          TextField(
            controller: _text,
            enabled: !_sending,
            minLines: 2,
            maxLines: 6,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email addresses',
              helperText: 'Separate several with commas or spaces.',
              errorText: _problem,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _sending ? null : _send,
              child: const Text('Send invitations'),
            ),
          ),
        ],
      ],
    ),
  );
}

Duration? _noRetry(int retryCount, Object error) => null;

/// The open teams on one server, each with a Join button.
class JoinTeamScreen extends ConsumerStatefulWidget {
  const JoinTeamScreen({required this.url, super.key});

  final String url;

  @override
  ConsumerState<JoinTeamScreen> createState() => _JoinTeamScreenState();
}

class _JoinTeamScreenState extends ConsumerState<JoinTeamScreen> {
  String? _joining;

  String get _host => hostOf(widget.url);

  Future<void> _join(JoinableTeam team) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _joining = team.id);
    final joined = await tryAction(
      context,
      _host,
      failure: "Couldn't join ${team.displayName}.",
      () async =>
          (await ref.read(teamActionsProvider(widget.url).future))
              .join(team.id),
    );
    if (!mounted) return;
    if (!joined) {
      setState(() => _joining = null);
      return;
    }
    messenger.showSnackBar(
      SnackBar(content: Text('Joined ${team.displayName}')),
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final teams = ref.watch(joinableTeamListProvider(widget.url));
    return ContentPage(
      title: const Text('Join a team'),
      progress: _joining != null,
      body: switch (teams) {
        AsyncData(:final value) when value.isEmpty => const EmptyState(
          icon: Icons.groups_outlined,
          title: 'No teams to join',
          body:
              'There are no open teams you are not in. Ask a team member '
              'for an invite link.',
        ),
        AsyncData(:final value) => ListView.builder(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          itemCount: value.length,
          itemBuilder: (context, i) {
            final team = value[i];
            return ListTile(
              leading: CircleAvatar(
                child: Text(
                  team.displayName.isEmpty
                      ? '?'
                      : team.displayName.characters.first.toUpperCase(),
                ),
              ),
              title: Text(team.displayName),
              subtitle: team.description.isEmpty
                  ? null
                  : Text(
                      team.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
              trailing: FilledButton.tonal(
                onPressed: _joining == null ? () => _join(team) : null,
                child: const Text('Join'),
              ),
            );
          },
        ),
        AsyncError(:final error) => FailedState(
          title: "Couldn't load the teams",
          error: error,
          host: _host,
          onRetry: () => ref.invalidate(joinableTeamListProvider(widget.url)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// The shown team's menu: join another team, copy the invite link and
/// leave the team.
class TeamMenu extends ConsumerWidget {
  const TeamMenu({
    required this.url,
    required this.teamId,
    required this.teamName,
    super.key,
  });

  final String url;
  final String teamId;
  final String teamName;

  String get _host => hostOf(url);

  Future<void> _copyInvite(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    await tryAction(
      context,
      _host,
      failure: "Couldn't get the invite link.",
      () async {
        final link = await (await ref.read(teamActionsProvider(url).future))
            .inviteLink(teamId);
        if (link == null) {
          messenger.showSnackBar(
            SnackBar(content: Text("You can't invite people to $teamName.")),
          );
          return;
        }
        await Clipboard.setData(ClipboardData(text: link.toString()));
        messenger.showSnackBar(
          const SnackBar(content: Text('Invite link copied')),
        );
      },
    );
  }

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final sure = await confirm(
      context,
      title: 'Leave $teamName?',
      body:
          'You leave all its channels too. To come back, join it again or '
          'ask for an invite.',
      action: 'Leave',
      destructive: true,
    );
    if (!sure || !context.mounted) return;
    await tryAction(
      context,
      _host,
      failure: "Couldn't leave $teamName.",
      () async =>
          (await ref.read(teamActionsProvider(url).future)).leave(teamId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invite = ref.watch(teamInviteProvider(url, teamId)).value;
    return MenuAnchor(
      menuChildren: [
        if (teamHasUnread(ref, url, teamId))
          MenuItemButton(
            leadingIcon: const Icon(Icons.done_all),
            onPressed: () => unawaited(markTeamRead(context, ref, url, teamId)),
            child: const Text('Mark all as read'),
          ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.group_add_outlined),
          onPressed: () => openPage(
            Navigator.of(context),
            JoinTeamScreen(url: url),
            popout: true,
          ),
          child: const Text('Join another team'),
        ),
        if (invite != null && invite.byEmail)
          MenuItemButton(
            leadingIcon: const Icon(Icons.mail_outline),
            onPressed: () => openPage(
              Navigator.of(context),
              InvitePeopleScreen(
                url: url,
                teamId: teamId,
                teamName: teamName,
                rights: invite,
              ),
              popout: true,
            ),
            child: const Text('Invite people'),
          ),
        if (invite == null || invite.byLink)
          MenuItemButton(
            leadingIcon: const Icon(Icons.link),
            onPressed: () => _copyInvite(context, ref),
            child: const Text('Copy invite link'),
          ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.logout),
          onPressed: () => _leave(context, ref),
          child: Text('Leave $teamName'),
        ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: 'Team',
        icon: const Icon(Icons.groups_outlined),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
