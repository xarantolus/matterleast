import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/call_providers.dart';
import 'package:matterleast/screens/calls/host_sheet.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/screens/you/user_profile_sheet.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/hover_tint.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

const _avatar = 56.0;

/// One person in the call. It watches only its own session, so a change
/// to someone else's doesn't rebuild it.
class ParticipantRow extends ConsumerWidget {
  const ParticipantRow({
    required this.url,
    required this.channelId,
    required this.sessionId,
    required this.selfId,
    required this.selfSessionId,
    required this.hostOpen,
    required this.sharing,
    super.key,
  });

  final String url;
  final String channelId;
  final String sessionId;
  final String? selfId;
  final String selfSessionId;
  final bool hostOpen;
  final bool sharing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(callSessionOfProvider(url, channelId, sessionId));
    if (session == null) return const SizedBox.shrink();
    final profile = ref.watch(userProfileProvider(url, session.userId)).value;
    final isHost =
        ref.watch(callHostProvider(url, channelId)) == session.userId;
    final reaction = ref.watch(callReactionProvider(url, sessionId));
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final mine = sessionId == selfSessionId;
    final otherDevice = !mine && session.userId == selfId;
    final name = profile?.name ?? '…';
    final manage = hostOpen && !mine;
    void profileSheet() =>
        showUserProfile(context, url: url, userId: session.userId);
    void hostSheet() => showHostSheet(
      context,
      url: url,
      channelId: channelId,
      sessionId: sessionId,
    );
    return Semantics(
      label:
          '$name${mine ? ', you' : ''}${otherDevice ? ', other device' : ''}${session.muted ? ', muted' : ''}'
          '${session.raisedHand > 0 ? ', hand raised' : ''}',
      excludeSemantics: true,
      child: HoverTint(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: profileSheet,
          onLongPress: manage ? hostSheet : null,
          onSecondaryTap: manage ? hostSheet : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.sm,
            ),
            child: Row(
              spacing: Spacing.md,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: session.speaking
                              ? tokens.online
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: profile == null
                            ? InitialsBadge(
                                name: '?',
                                size: _avatar,
                                round: true,
                              )
                            : UserAvatar(
                                serverUrl: url,
                                userId: session.userId,
                                name: profile.name,
                                lastPictureUpdate: profile.pictureUpdate,
                                size: _avatar,
                              ),
                      ),
                    ),
                    if (reaction != null)
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: EmojiGlyph(
                              name: reaction,
                              size: 20,
                              serverUrl: url,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mine
                            ? '$name (you)'
                            : otherDevice
                            ? '$name (other device)'
                            : name,
                        style: text.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isHost || sharing)
                        Text(
                          [
                            if (isHost) 'Host',
                            if (sharing) 'Sharing their screen',
                          ].join(' · '),
                          style: text.bodyMedium?.copyWith(color: tokens.muted),
                        ),
                    ],
                  ),
                ),
                if (session.raisedHand > 0)
                  Icon(Icons.back_hand, size: 24, color: tokens.away),
                Icon(
                  session.muted ? Icons.mic_off : Icons.mic,
                  size: 24,
                  color: session.muted ? tokens.muted : tokens.online,
                ),
                if (manage)
                  IconButton(
                    tooltip: 'Manage $name',
                    icon: const Icon(Icons.more_vert),
                    onPressed: hostSheet,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
