import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/burn_on_read.dart';
import 'package:matterleast/domain/scheduled_posts.dart';
import 'package:matterleast/screens/drafts/drafts_providers.dart';
import 'package:matterleast/screens/drafts/drafts_screen.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'composer_extras.g.dart';

/// Whether the next message in a channel burns after it is read; off again
/// once it went out.
@riverpod
class BurnOnReadChoice extends _$BurnOnReadChoice {
  @override
  bool build(String url, String channelId) => false;

  void set({required bool on}) => state = on;
}

/// Above the field while the message will burn after reading.
class BurnOnReadChip extends StatelessWidget {
  const BurnOnReadChip({
    required this.duration,
    required this.onDeleted,
    super.key,
  });

  final Duration duration;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) => InputChip(
    avatar: Icon(
      Icons.local_fire_department_outlined,
      color: Theme.of(context).colorScheme.error,
    ),
    label: Text('Burn on read · ${burnDurationLabel(duration)}'),
    onDeleted: onDeleted,
    deleteButtonTooltipMessage: 'Send normally',
  );
}

/// Send (or save, while editing). Holding it offers to schedule the
/// message when [onSchedule] is set.
class SendButton extends StatelessWidget {
  const SendButton({
    required this.editing,
    required this.onSend,
    this.onSchedule,
    super.key,
  });

  final bool editing;
  final VoidCallback? onSend;
  final VoidCallback? onSchedule;

  @override
  Widget build(BuildContext context) {
    final button = IconButton.filled(
      // The tooltip would take the long press scheduling needs.
      tooltip: onSchedule == null ? (editing ? 'Save' : 'Send') : null,
      onPressed: onSend,
      icon: Icon(editing ? Icons.check : Icons.send),
    );
    if (onSchedule == null) return button;
    return Semantics(
      label: 'Send',
      onLongPressHint: 'schedule',
      onLongPress: onSchedule,
      child: GestureDetector(onLongPress: onSchedule, child: button),
    );
  }
}

/// "2 scheduled messages" above the composer of a conversation that has
/// some; a tap lists them.
class ScheduledNotice extends ConsumerWidget {
  const ScheduledNotice({
    required this.url,
    required this.channelId,
    required this.rootId,
    required this.teamId,
    super.key,
  });

  final String url;
  final String channelId;
  final String rootId;
  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count =
        ref.watch(scheduledCountProvider(url, channelId, rootId)).value ?? 0;
    final label = scheduledCountLabel(count);
    if (label == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme.labelLarge;
    return Material(
      color: scheme.surfaceContainerHigh,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DraftsScreen(
              url: url,
              teamId: teamId,
              teamName: '',
              scheduledFirst: true,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule_send_outlined,
                size: 18,
                color: scheme.primary,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(child: Text(label, style: text)),
              Text('See all', style: text?.copyWith(color: scheme.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
