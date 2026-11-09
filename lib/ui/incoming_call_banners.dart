import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/call_providers.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/calls.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/ui/call_actions_ui.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

/// Calls that ring the user on any server, with Join and Ignore, for as
/// long as the call runs and the user has neither joined nor ignored it.
/// Only while the app is open; nothing rings in the background.
class IncomingCallBanners extends ConsumerWidget {
  const IncomingCallBanners({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(callControllerProvider);
    final servers = ref.watch(serversProvider).value;
    if (controller == null || servers == null) return const SizedBox.shrink();
    final size = MediaQuery.sizeOf(context);
    final margin = isDesktop ? Spacing.md : Spacing.lg;
    final top = isDesktop
        ? kToolbarHeight + Spacing.sm
        : MediaQuery.paddingOf(context).top + Spacing.sm;
    return Positioned(
      top: top,
      right: margin,
      left: isDesktop ? null : margin,
      width: isDesktop
          ? math.min(math.max(320, size.width * 0.28), size.width - 2 * margin)
          : null,
      child: Column(
        spacing: Spacing.sm,
        children: [for (final s in servers) _ServerCalls(url: s.url)],
      ),
    );
  }
}

class _ServerCalls extends ConsumerWidget {
  const _ServerCalls({required this.url});

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calls = ref.watch(incomingCallsProvider(url));
    return Column(
      spacing: Spacing.sm,
      children: [
        for (final e in calls.entries)
          _IncomingCall(
            key: ValueKey('$url ${e.key}'),
            url: url,
            channelId: e.key,
            call: e.value,
          ),
      ],
    );
  }
}

class _IncomingCall extends ConsumerWidget {
  const _IncomingCall({
    required this.url,
    required this.channelId,
    required this.call,
    super.key,
  });

  final String url;
  final String channelId;
  final ActiveCall call;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owner = call.ownerId ?? '';
    final profile = ref.watch(userProfileProvider(url, owner)).value;
    final info = ref.watch(channelInfoProvider(url, channelId)).value;
    final text = Theme.of(context).textTheme;
    final group = info?.type == 'G';
    final name = profile?.name ?? 'Someone';
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Row(
          spacing: Spacing.md,
          children: [
            profile == null
                ? InitialsBadge(name: '?', size: 40, round: true)
                : UserAvatar(
                    serverUrl: url,
                    userId: owner,
                    name: profile.name,
                    lastPictureUpdate: profile.pictureUpdate,
                    size: 40,
                  ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$name is calling',
                    style: text.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (group && info != null)
                    Text(
                      info.title,
                      style: text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _ignore(ref),
              child: const Text('Ignore'),
            ),
            FilledButton(
              onPressed: () => _join(context, ref),
              child: const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _join(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(callControllerProvider);
    if (controller == null) return;
    final navigator = ref.read(conversationRoutesProvider).navigator;
    if (navigator == null || !navigator.mounted) return;
    await joinCall(
      navigator.context,
      controller,
      url: url,
      channelId: channelId,
    );
  }

  Future<void> _ignore(WidgetRef ref) async {
    final server = await ref.read(serverSessionProvider(url).future);
    server.connection.calls.dismiss(channelId);
    try {
      await server.calls.dismissNotification(channelId);
    } on Object catch (e) {
      Log.warn('calls', 'dismissing the ring failed: ${e.runtimeType}');
    }
  }
}
