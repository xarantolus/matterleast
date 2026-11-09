import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

/// The pictures of the people in a call, overlapping, with how many more
/// there are.
class CallParticipants extends ConsumerWidget {
  const CallParticipants({
    required this.url,
    required this.userIds,
    this.size = 24,
    this.shown = 3,
    super.key,
  });

  final String url;
  final List<String> userIds;
  final double size;
  final int shown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userIds.isEmpty) return const SizedBox.shrink();
    final edge = Theme.of(context).colorScheme.surface;
    final step = size * 0.65;
    final people = userIds.take(shown).toList();
    final more = userIds.length - people.length;
    return Semantics(
      label: '${userIds.length} in the call',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size + step * (people.length - 1),
            height: size,
            child: Stack(
              children: [
                for (final (i, id) in people.indexed)
                  Positioned(
                    left: i * step,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: edge, width: 1.5),
                      ),
                      child: _Person(url: url, userId: id, size: size),
                    ),
                  ),
              ],
            ),
          ),
          if (more > 0)
            Padding(
              padding: const EdgeInsets.only(left: Spacing.xs),
              child: Text(
                '+$more',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
        ],
      ),
    );
  }
}

class _Person extends ConsumerWidget {
  const _Person({required this.url, required this.userId, required this.size});

  final String url;
  final String userId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider(url, userId)).value;
    return profile == null
        ? InitialsBadge(name: '?', size: size, round: true)
        : UserAvatar(
            serverUrl: url,
            userId: userId,
            name: profile.name,
            lastPictureUpdate: profile.pictureUpdate,
            size: size,
          );
  }
}
