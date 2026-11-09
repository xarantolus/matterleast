import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/json/calls.dart';
import 'package:matterleast/app/call_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/domain/call_controller.dart';
import 'package:matterleast/domain/calls.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/ui/call_actions_ui.dart';
import 'package:matterleast/ui/call_participants.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/tokens.dart';

final _props = <String, CallPostProps>{};

/// The props of a call [post], decoded once per version.
CallPostProps callPropsOf(PostItem post) {
  final json = post.propsJson ?? '';
  final key = '${post.id}:${json.hashCode}';
  final hit = _props[key];
  if (hit != null) return hit;
  final props = decodeCallPostProps(json);
  if (_props.length > 200) _props.remove(_props.keys.first);
  return _props[key] = props;
}

/// A call's post: that it started, who is in it and how it ended, with
/// Join while it runs.
class CallPostCard extends ConsumerWidget {
  const CallPostCard({required this.post, super.key});

  final PostItem post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = PostEnvironment.maybeOf(context)?.server.toString();
    final props = callPropsOf(post);
    final live = url == null
        ? null
        : ref.watch(callOfPostProvider(url, post.id));
    final controller = ref.watch(callControllerProvider);
    final me = url == null ? null : ref.watch(currentUserProvider(url)).value;
    final mine = me?.id == post.userId;
    final state = callCardState(
      endAt: props.endAt,
      status: props.callStatus ?? '',
      people: live?.call.participantUserIds.length ?? 0,
      callExists: live != null,
    );
    final over =
        state != CallCardState.calling && state != CallCardState.active;
    final today = ref.watch(todayProvider);
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final heading = switch (state) {
      CallCardState.calling => mine ? 'Calling…' : 'Incoming call…',
      CallCardState.active => 'Call started',
      _ => 'Call ended',
    };
    final start = props.startAt;
    final end = props.endAt;
    final sub = switch (state) {
      CallCardState.calling => null,
      CallCardState.noAnswer => mine ? 'No answer' : 'Missed call',
      CallCardState.canceled =>
        mine ? 'You canceled the call' : 'Canceled by ${post.authorName}',
      CallCardState.declined => mine ? 'Declined' : 'You declined the call',
      CallCardState.ended =>
        end == null
            ? null
            : [
                'Ended ${momentLabel(end, today, use24: use24)}',
                if (start != null)
                  'Lasted ${callDurationLabel(end.difference(start))}',
              ].join(' · '),
      CallCardState.active =>
        start == null
            ? null
            : 'Started ${momentLabel(start, today, use24: use24)}',
    };
    final title = props.title;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: tokens.hairline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Row(
            spacing: Spacing.md,
            children: [
              CircleAvatar(
                backgroundColor: over ? tokens.accentWash : tokens.online,
                foregroundColor: over ? tokens.muted : Colors.white,
                child: Icon(over ? Icons.call_end : Icons.call, size: 20),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null && title.isNotEmpty)
                      Text(title, style: text.titleSmall),
                    Text(heading, style: text.titleSmall),
                    if (sub != null)
                      Text(
                        sub,
                        style: text.bodySmall?.copyWith(color: tokens.muted),
                      ),
                    if (live != null && url != null)
                      Padding(
                        padding: const EdgeInsets.only(top: Spacing.xs),
                        child: CallParticipants(
                          url: url,
                          userIds: live.call.participantUserIds,
                        ),
                      ),
                  ],
                ),
              ),
              if (live != null && url != null)
                CallJoinButton(
                  controller: controller,
                  url: url,
                  channelId: live.channelId,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Join, or "Joined" while the user is in that call.
class CallJoinButton extends StatelessWidget {
  const CallJoinButton({
    required this.controller,
    required this.url,
    required this.channelId,
    super.key,
  });

  final CallController controller;
  final String url;
  final String channelId;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<CallRef?>(
    valueListenable: controller.current,
    builder: (context, current, _) {
      final here = current?.url == url && current?.channelId == channelId;
      return FilledButton.icon(
        onPressed: () =>
            joinCall(context, controller, url: url, channelId: channelId),
        icon: const Icon(Icons.call, size: 18),
        label: Text(here ? 'Open' : 'Join'),
      );
    },
  );
}
