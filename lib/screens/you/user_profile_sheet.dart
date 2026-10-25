import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/data/time_zones.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/user_profile.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/ui/presence_dot.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

/// Someone's profile in a bottom sheet, with a button to message them.
Future<void> showUserProfile(
  BuildContext context, {
  required String url,
  required String userId,
}) => showModalBottomSheet<void>(
  context: context,
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
    ref.watch(profileRefreshProvider(url, userId));
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    if (profile == null) {
      return const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final custom = profile.customStatus;
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
                child: PresenceDot(status: profile.status, size: 22),
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
              presenceLabel(profile.status),
            ].join(' · '),
            style: text.bodyMedium?.copyWith(color: tokens.muted),
            textAlign: TextAlign.center,
          ),
          if (custom != null) ...[
            const SizedBox(height: Spacing.md),
            CustomStatusLine(status: custom, style: text.bodyLarge),
          ],
          const SizedBox(height: Spacing.md),
          if (profile.nickname.isNotEmpty)
            _Detail(label: 'Nickname', value: profile.nickname),
          if (profile.position.isNotEmpty)
            _Detail(label: 'Position', value: profile.position),
          if (profile.timezone case final zone?) _LocalTime(zone: zone),
          if (!profile.isMe && !profile.isBot) ...[
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
  ) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final actions = await ref.read(channelActionsProvider(url).future);
      final channelId = await actions.directChannel(profile.id);
      unawaited(
        openChannel(
          navigator,
          ref,
          url: url,
          channelId: channelId,
          title: profile.name,
        ),
      );
      navigator.pop();
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't open the conversation. "
            '${requestProblemText(e, Uri.parse(url).host)}',
          ),
        ),
      );
    }
  }
}

/// A custom status as one line: its emoji, text and when it clears.
class CustomStatusLine extends StatelessWidget {
  const CustomStatusLine({required this.status, this.style, super.key});

  final CustomStatus status;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final strings = MaterialLocalizations.of(context);
    final expires = status.expiresAt?.toLocal();
    final until = status.duration.isEmpty || expires == null
        ? null
        : _isToday(expires)
        ? 'until ${strings.formatTimeOfDay(TimeOfDay.fromDateTime(expires), alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context))}'
        : 'until ${strings.formatMediumDate(expires)}';
    return Text.rich(
      TextSpan(
        children: [
          if (status.emoji.isNotEmpty)
            TextSpan(text: '${emojiText(status.emoji)} '),
          TextSpan(text: status.text),
          if (until != null)
            TextSpan(
              text: ' · $until',
              style: TextStyle(color: context.tokens.muted),
            ),
        ],
      ),
      style: style,
      textAlign: TextAlign.center,
    );
  }

  static bool _isToday(DateTime t) {
    final now = DateTime.now();
    return t.year == now.year && t.month == now.month && t.day == now.day;
  }
}

/// An emoji by its short name; a custom emoji shows as `:name:`.
String emojiText(String name) => unicodeForName(name) ?? ':$name:';

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
    final strings = MaterialLocalizations.of(context);
    final clock = strings.formatTimeOfDay(
      TimeOfDay.fromDateTime(time),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    return _Detail(
      label: 'Local time',
      value: '$clock (${widget.zone.replaceAll('_', ' ')})',
    );
  }
}
