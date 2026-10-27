import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/team_actions.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/teams.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/slide_route.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'team_screens.g.dart';

@riverpod
Future<TeamActions> teamActions(Ref ref, String url) async =>
    (await ref.watch(serverSessionProvider(url).future)).teams;

/// Open teams on [url] the user isn't in; asked again on each visit.
@Riverpod(retry: _noRetry)
Future<List<JoinableTeam>> joinableTeamList(Ref ref, String url) async =>
    (await ref.watch(teamActionsProvider(url).future)).joinable();

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

  String get _host => Uri.parse(widget.url).host;

  Future<void> _join(JoinableTeam team) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _joining = team.id);
    try {
      await (await ref.read(teamActionsProvider(widget.url).future))
          .join(team.id);
      messenger.showSnackBar(
        SnackBar(content: Text('Joined ${team.displayName}')),
      );
      navigator.pop();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _joining = null);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't join ${team.displayName}. "
            '${requestProblemText(e, _host)}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final teams = ref.watch(joinableTeamListProvider(widget.url));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a team'),
        bottom: ProgressSlot(active: _joining != null),
      ),
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
        AsyncError(:final error) => EmptyState(
          icon: Icons.cloud_off_outlined,
          title: "Couldn't load the teams",
          body: requestProblemText(error, _host),
          action: FilledButton.tonal(
            onPressed: () =>
                ref.invalidate(joinableTeamListProvider(widget.url)),
            child: const Text('Retry'),
          ),
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

  String get _host => Uri.parse(url).host;

  Future<void> _copyInvite(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
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
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't get the invite link. ${requestProblemText(e, _host)}",
          ),
        ),
      );
    }
  }

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text('Leave $teamName?'),
        content: const Text(
          'You leave all its channels too. To come back, join it again or '
          'ask for an invite.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (sure != true) return;
    try {
      await (await ref.read(teamActionsProvider(url).future)).leave(teamId);
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't leave $teamName. ${requestProblemText(e, _host)}",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => MenuAnchor(
    menuChildren: [
      MenuItemButton(
        leadingIcon: const Icon(Icons.group_add_outlined),
        onPressed: () => Navigator.of(context)
            .push(SlideRoute<void>(builder: (_) => JoinTeamScreen(url: url))),
        child: const Text('Join another team'),
      ),
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
