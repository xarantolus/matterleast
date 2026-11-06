import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/live_providers.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/data/time_zones.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/domain/user_profile.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/you/profile_attributes_list.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/failed_state.dart';
import 'package:matterleast/ui/presence_dot.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/try_action.dart';
import 'package:matterleast/ui/user_avatar.dart';

/// Someone's profile in a bottom sheet, or a popup at [anchor] on desktop, with a button to message them.
Future<void> showUserProfile(
  BuildContext context, {
  required String url,
  required String userId,
  Rect? anchor,
}) => showAppSheet<void>(
  context: context,
  anchor: anchor,
  showDragHandle: true,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => UserProfileSheet(url: url, userId: userId),
);

class UserProfileSheet extends ConsumerWidget {
  const UserProfileSheet({required this.url, required this.userId, super.key});

  final String url;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider(url, userId)).value;
    final refresh = ref.watch(profileRefreshProvider(url, userId));
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    if (profile == null) {
      return SizedBox(
        height: 240,
        child: switch (refresh) {
          AsyncError(:final error) when !refresh.isLoading => FailedState(
            icon: Icons.person_off_outlined,
            title: "Couldn't load the profile",
            error: error,
            host: hostOf(url),
            onRetry: () => ref.invalidate(profileRefreshProvider(url, userId)),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      );
    }
    final custom = ref.watch(activeCustomStatusProvider(url, userId));
    final presenceKnown = ref.watch(presenceKnownProvider(url, userId));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              UserAvatar(
                serverUrl: url,
                userId: profile.id,
                name: profile.name,
                lastPictureUpdate: profile.pictureUpdate,
                size: 96,
              ),
              PositionedDirectional(
                end: 2,
                bottom: 2,
                child: presenceKnown
                    ? PresenceDot(status: profile.status, size: 22)
                    : const SizedBox.square(dimension: 22),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(
            profile.name,
            style: text.headlineSmall,
            textAlign: TextAlign.center,
          ),
          Text(
            [
              '@${profile.username}',
              if (profile.isBot) 'Bot',
              if (profile.isGuest) 'Guest',
              if (presenceKnown) presenceLabel(profile.status),
            ].join(' · '),
            style: text.bodyMedium?.copyWith(color: tokens.muted),
            textAlign: TextAlign.center,
          ),
          if (custom != null) ...[
            const SizedBox(height: Spacing.md),
            CustomStatusLine(url: url, status: custom, style: text.bodyLarge),
          ],
          const SizedBox(height: Spacing.md),
          if (profile.nickname.isNotEmpty)
            _Detail(label: 'Nickname', value: profile.nickname),
          if (profile.position.isNotEmpty)
            _Detail(label: 'Position', value: profile.position),
          if (profile.timezone case final zone?) _LocalTime(zone: zone),
          ProfileAttributesList(url: url, userId: userId),
          if (!profile.isMe) ...[
            const SizedBox(height: Spacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Message'),
                onPressed: () => _message(context, ref, profile),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _message(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) {
    final navigator = Navigator.of(context);
    return messagePerson(
      context,
      ref,
      url: url,
      userId: profile.id,
      name: profile.name,
      // The sheet goes first: the conversation is pushed at once, so a
      // pop after it would close the conversation instead.
      before: navigator.pop,
    );
  }
}

/// Opens the DM with [userId]; [before] runs just before, e.g. a sheet pop.
Future<void> messagePerson(
  BuildContext context,
  WidgetRef ref, {
  required String url,
  required String userId,
  required String name,
  VoidCallback? before,
}) async {
  final navigator = Navigator.of(context);
  await tryAction(
    context,
    hostOf(url),
    failure: "Couldn't open the conversation.",
    () async {
      final actions = await ref.read(channelActionsProvider(url).future);
      final channelId = await actions.directChannel(userId);
      before?.call();
      unawaited(
        openConversation(
          navigator,
          url: url,
          channelId: channelId,
          title: name,
          followed: true,
        ),
      );
    },
  );
}

/// A custom status as one line: its emoji, text and when it clears.
class CustomStatusLine extends ConsumerWidget {
  const CustomStatusLine({
    required this.url,
    required this.status,
    this.style,
    this.textAlign = TextAlign.center,
    super.key,
  });

  final String url;
  final CustomStatus status;
  final TextStyle? style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expires = status.expiresAt;
    final until = status.duration.isEmpty || expires == null
        ? null
        : 'until ${untilLabel(expires, ref.watch(todayProvider), use24: MediaQuery.alwaysUse24HourFormatOf(context))}';
    return Text.rich(
      TextSpan(
        children: [
          if (status.emoji.isNotEmpty) ...[
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: EmojiGlyph(
                name: status.emoji,
                size:
                    (style ?? DefaultTextStyle.of(context).style).fontSize! *
                    1.25,
                serverUrl: url,
              ),
            ),
            const TextSpan(text: ' '),
          ],
          TextSpan(text: status.text),
          if (until != null)
            TextSpan(
              text: ' · $until',
              style: TextStyle(color: context.tokens.muted),
            ),
        ],
      ),
      style: style,
      textAlign: textAlign,
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label.toUpperCase(), style: context.tokens.smallCaps),
    subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
  );
}

/// The person's local time, kept current while shown.
class _LocalTime extends StatefulWidget {
  const _LocalTime({required this.zone});

  final String zone;

  @override
  State<_LocalTime> createState() => _LocalTimeState();
}

class _LocalTimeState extends State<_LocalTime> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Redraws on the minute.
    _timer = Timer(Duration(seconds: 60 - now.second), () {
      if (!mounted) return;
      setState(() {});
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final time = wallTimeIn(widget.zone, DateTime.now());
    if (time == null) return const SizedBox.shrink();
    final clock = wallClockLabel(
      time,
      DateTime.now(),
      use24: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    return _Detail(
      label: 'Local time',
      value: '$clock (${widget.zone.replaceAll('_', ' ')})',
    );
  }
}
