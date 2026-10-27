import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/agent_providers.dart';
import 'package:matterleast/app/extras_providers.dart';
import 'package:matterleast/data/actions/channel_actions.dart';
import 'package:matterleast/domain/channel_info.dart';
import 'package:matterleast/domain/message_search.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/screens/agents/ask_agents_sheet.dart';
import 'package:matterleast/screens/channel/bookmark_bar.dart';
import 'package:matterleast/screens/channel/message_environment.dart';
import 'package:matterleast/screens/channel_info/channel_missing.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/channel_info/edit_channel_screen.dart';
import 'package:matterleast/screens/channel_info/members_screen.dart';
import 'package:matterleast/screens/channel_info/notification_prefs_screen.dart';
import 'package:matterleast/screens/channel_info/people_picker_screen.dart';
import 'package:matterleast/screens/channel_info/pinned_screen.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/search/search_results_screen.dart';
import 'package:matterleast/screens/you/user_profile_sheet.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/slide_route.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

/// What a channel is about and what the user can do with it.
class ChannelInfoScreen extends ConsumerStatefulWidget {
  const ChannelInfoScreen({
    required this.url,
    required this.channelId,
    super.key,
  });

  final String url;
  final String channelId;

  @override
  ConsumerState<ChannelInfoScreen> createState() => _ChannelInfoScreenState();
}

class _ChannelInfoScreenState extends ConsumerState<ChannelInfoScreen> {
  String get _host => Uri.parse(widget.url).host;

  Future<ChannelActions> get _actions =>
      ref.read(channelActionsProvider(widget.url).future);

  /// Runs [action] and says what failed in words when it does.
  Future<bool> _run(
    String failure,
    Future<void> Function(ChannelActions) action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action(await _actions);
      return true;
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('$failure ${requestProblemText(e, _host)}')),
      );
      return false;
    }
  }

  void _push(Widget screen) => unawaited(
    Navigator.of(context).push(SlideRoute<void>(builder: (_) => screen)),
  );

  Future<void> _leave(ChannelInfo info) async {
    final navigator = Navigator.of(context);
    final ok = await confirmLeave(
      context,
      info.title,
      private: info.type == 'P',
    );
    if (!ok || !mounted) return;
    if (await _run("Couldn't leave ${info.title}.", (a) => a.leave(info.id))) {
      navigator.popUntil((route) => route.isFirst);
    }
  }

  Future<void> _archive(ChannelInfo info) async {
    final ok = await confirm(
      context,
      title: 'Archive ${info.title}?',
      body:
          'Nobody can post in it any more. Its messages stay readable and '
          'searchable, and an admin can bring it back.',
      action: 'Archive',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await _run("Couldn't archive ${info.title}.", (a) => a.archive(info.id));
  }

  @override
  Widget build(BuildContext context) {
    final infoState = ref.watch(
      channelInfoProvider(widget.url, widget.channelId),
    );
    final info = infoState.value;
    final stats = ref
        .watch(channelStatsProvider(widget.url, widget.channelId))
        .value;
    final loading = ref
        .watch(channelStatsProvider(widget.url, widget.channelId))
        .isLoading;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      appBar: AppBar(
        title: Text(info?.title ?? 'Channel'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: SizedBox(
            height: 3,
            child: loading && info != null
                ? const LinearProgressIndicator(minHeight: 3)
                : null,
          ),
        ),
      ),
      body: info == null
          ? ChannelMissing(
              state: infoState,
              host: _host,
              onRetry: () => ref.invalidate(
                channelInfoProvider(widget.url, widget.channelId),
              ),
            )
          : ListView(
              padding: EdgeInsets.only(bottom: bottom + Spacing.lg),
              children: [
                _Header(url: widget.url, info: info),
                if (info.archived)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.lg,
                      0,
                      Spacing.lg,
                      Spacing.md,
                    ),
                    child: Card.filled(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: const Icon(Icons.archive_outlined),
                        title: const Text('This channel is archived'),
                        subtitle: const Text(
                          'You can read it, but nobody can post.',
                        ),
                      ),
                    ),
                  ),
                if (info.joined) _buttons(info),
                const SizedBox(height: Spacing.sm),
                if (info.type != 'D')
                  ListTile(
                    leading: const Icon(Icons.group_outlined),
                    title: const Text('Members'),
                    trailing: _Count(info.memberCount ?? stats?.memberCount),
                    onTap: () => _push(
                      MembersScreen(
                        url: widget.url,
                        channelId: info.id,
                        teamId: info.teamId,
                        title: info.title,
                        canAdd:
                            info.canManageMembers &&
                            !info.archived &&
                            !info.conversation,
                      ),
                    ),
                  ),
                if (ref.watch(agentsAvailableProvider(widget.url)) &&
                    !info.archived)
                  ListTile(
                    leading: const Icon(Icons.auto_awesome_outlined),
                    title: const Text('Ask Agents'),
                    onTap: () => showAskAgentsSheet(
                      context,
                      url: widget.url,
                      channelId: info.id,
                    ),
                  ),
                ListTile(
                  leading: const Icon(Icons.push_pin_outlined),
                  title: const Text('Pinned messages'),
                  trailing: _Count(stats?.pinnedpostCount),
                  onTap: () => _push(
                    PinnedScreen(
                      url: widget.url,
                      channelId: info.id,
                      title: info.title,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Files'),
                  trailing: _Count(stats?.filesCount),
                  onTap: () => _push(
                    SearchResultsScreen(
                      url: widget.url,
                      teamId: info.teamId,
                      query: '',
                      files: true,
                      scope: SearchScope(
                        teamId: info.teamId,
                        channelId: info.id,
                        channelName: info.name,
                        channelLabel: info.conversation
                            ? info.title
                            : '#${info.title}',
                      ),
                    ),
                  ),
                ),
                if (ref
                        .watch(bookmarkRightsInProvider(widget.url, info.id))
                        .value
                        ?.add ??
                    false)
                  ListTile(
                    leading: const Icon(Icons.bookmark_add_outlined),
                    title: const Text('Add a bookmark'),
                    onTap: () => showAddBookmark(context, widget.url, info.id),
                  ),
                if (info.joined)
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Notification preferences'),
                    subtitle: Text(
                      info.muted
                          ? 'Muted'
                          : effectiveLevel(
                              info.notify.push,
                              info.notify.accountPush,
                            ),
                    ),
                    onTap: () => _push(
                      NotificationPrefsScreen(
                        url: widget.url,
                        channelId: info.id,
                      ),
                    ),
                  ),
                if (!info.archived && (info.canEdit || info.conversation))
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: Text(
                      info.conversation
                          ? 'Edit header'
                          : 'Edit name, purpose and header',
                    ),
                    onTap: () => _push(
                      EditChannelScreen(
                        url: widget.url,
                        teamId: info.teamId,
                        channel: info,
                      ),
                    ),
                  ),
                if (info.canArchive &&
                    !info.archived &&
                    !info.conversation &&
                    !info.isDefault)
                  ListTile(
                    leading: const Icon(Icons.archive_outlined),
                    title: const Text('Archive channel'),
                    onTap: () => _archive(info),
                  ),
                if (info.joined && !info.conversation && !info.isDefault)
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      'Leave channel',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    onTap: () => _leave(info),
                  ),
              ],
            ),
    );
  }

  Widget _buttons(ChannelInfo info) {
    final buttons = <Widget>[
      _ActionButton(
        icon: info.favorite ? Icons.star : Icons.star_border,
        label: info.favorite ? 'Favourited' : 'Favourite',
        selected: info.favorite,
        onPressed: () => _run(
          "Couldn't change favourites.",
          (a) => a.setFavorite(info.teamId, info.id, favorite: !info.favorite),
        ),
      ),
      _ActionButton(
        icon: info.muted
            ? Icons.notifications_off
            : Icons.notifications_outlined,
        label: info.muted ? 'Muted' : 'Mute',
        selected: info.muted,
        onPressed: () => _run(
          "Couldn't ${info.muted ? 'unmute' : 'mute'} ${info.title}.",
          (a) => a.setMuted(info.id, muted: !info.muted),
        ),
      ),
      if (info.canManageMembers && !info.archived && !info.conversation)
        _ActionButton(
          icon: Icons.person_add_alt,
          label: 'Add people',
          onPressed: () => _push(
            addMembersScreen(
              url: widget.url,
              teamId: info.teamId,
              channelId: info.id,
              channelTitle: info.title,
            ),
          ),
        ),
      if (!info.conversation)
        _ActionButton(
          icon: Icons.link,
          label: 'Copy link',
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            await Clipboard.setData(
              ClipboardData(
                text: channelLink(widget.url, info.teamName, info.name),
              ),
            );
            messenger.showSnackBar(
              const SnackBar(content: Text('Link copied')),
            );
          },
        ),
    ];
    // Large text gets two buttons a row, so labels keep whole words.
    final perRow = MediaQuery.textScalerOf(context).scale(10) > 14 ? 2 : 4;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Column(
        children: [
          for (var start = 0; start < buttons.length; start += perRow)
            Padding(
              padding: EdgeInsets.only(top: start == 0 ? 0 : Spacing.sm),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = start; i < start + perRow; i++) ...[
                      if (i > start) const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: i < buttons.length
                            ? buttons[i]
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.url, required this.info});

  final String url;
  final ChannelInfo info;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final partner = info.partnerId;
    return Padding(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (partner != null)
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () =>
                      showUserProfile(context, url: url, userId: partner),
                  child: UserAvatar(
                    serverUrl: url,
                    userId: partner,
                    name: info.title,
                    size: 56,
                  ),
                )
              else
                Icon(
                  switch (info.type) {
                    'P' => Icons.lock_outline,
                    'G' => Icons.group_outlined,
                    _ when info.archived => Icons.archive_outlined,
                    _ => Icons.tag,
                  },
                  size: 40,
                  color: tokens.accent,
                ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.title, style: text.headlineSmall),
                    if (!info.conversation)
                      Text(
                        [
                          '~${info.name}',
                          if (info.teamDisplayName.isNotEmpty)
                            info.teamDisplayName,
                        ].join(' · '),
                        style: text.bodyMedium?.copyWith(color: tokens.muted),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (info.purpose.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            Text('PURPOSE', style: tokens.smallCaps),
            const SizedBox(height: Spacing.xs),
            Text(info.purpose, style: text.bodyMedium),
          ],
          if (info.header.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            Text('HEADER', style: tokens.smallCaps),
            const SizedBox(height: Spacing.xs),
            // Keyed by the text, so an edited header is parsed again.
            MessageEnvironment(
              url: url,
              teamId: info.teamId,
              child: PostBody(
                postId: 'header:${info.id}:${info.header.hashCode}',
                message: info.header,
              ),
            ),
          ],
          if (!info.conversation && info.createAt != null) ...[
            const SizedBox(height: Spacing.md),
            Text(
              [
                'Created',
                if (info.creatorName case final name?) 'by $name',
                'on ${dateLabel(info.createAt!, DateTime.now(), alwaysYear: true)}',
              ].join(' '),
              style: text.bodySmall?.copyWith(color: tokens.muted),
            ),
          ],
        ],
      ),
    );
  }
}

/// One of the round tonal buttons under the header: icon above label.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  /// Drawn filled, for a setting that is on.
  final bool selected;

  @override
  Widget build(BuildContext context) => Semantics(
    toggled: selected,
    child: (selected ? FilledButton.new : FilledButton.tonal)(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.md,
          horizontal: Spacing.xs,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: Spacing.xs),
          Text(label, textAlign: TextAlign.center, maxLines: 2),
        ],
      ),
    ),
  );
}

class _Count extends StatelessWidget {
  const _Count(this.count);

  final int? count;

  @override
  Widget build(BuildContext context) => count == null
      ? const SizedBox.shrink()
      : Text(
          '$count',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: context.tokens.muted),
        );
}
