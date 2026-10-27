import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/person_tile.dart';
import 'package:matterleast/ui/tokens.dart';

/// Pure: whether the reader can still take an acknowledgement back; the
/// server allows it for five minutes.
bool canUnacknowledge(DateTime acknowledgedAt, DateTime now) =>
    now.difference(acknowledgedAt) < const Duration(minutes: 5);

/// "Acknowledge" under a message that asks for it, or how many did. A tap
/// acknowledges or takes it back while that's allowed; otherwise, and on a
/// long press, it lists who acknowledged.
class AcknowledgeButton extends StatelessWidget {
  const AcknowledgeButton({
    required this.post,
    required this.times,
    required this.onToggle,
    super.key,
  });

  final PostItem post;

  /// When each person acknowledged, by user id.
  final Map<String, DateTime?> times;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final env = PostEnvironment.maybeOf(context);
    final author =
        env != null &&
        env.myUsername.isNotEmpty &&
        post.authorUsername == env.myUsername;
    final at = post.acknowledgedAt;
    final people = post.acknowledgedBy;
    final toggles =
        onToggle != null &&
        !author &&
        (at == null || canUnacknowledge(at, DateTime.now()));
    void list() => _showAcknowledgements(context, people, times);
    return GestureDetector(
      onLongPress: people.isEmpty ? null : list,
      child: FilterChip(
        showCheckmark: false,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        selected: at != null,
        avatar: Icon(
          at != null ? Icons.check_circle : Icons.check_circle_outline,
          size: 18,
          color: context.tokens.online,
        ),
        label: Text(
          author || people.isNotEmpty ? '${people.length}' : 'Acknowledge',
        ),
        tooltip: 'Acknowledgements',
        onSelected: (_) {
          if (toggles) {
            onToggle!();
          } else if (people.isNotEmpty) {
            list();
          }
        },
      ),
    );
  }
}

void _showAcknowledgements(
  BuildContext context,
  List<PostPerson> people,
  Map<String, DateTime?> times,
) {
  final env = PostEnvironment.maybeOf(context);
  final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
  final now = DateTime.now();
  showAppSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheet) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(sheet).height * 0.6,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              0,
              Spacing.lg,
              Spacing.sm,
            ),
            child: Text(
              'Acknowledgements',
              style: Theme.of(sheet).textTheme.titleLarge,
            ),
          ),
          for (final person in people)
            if (env == null)
              ListTile(title: Text(person.name))
            else
              PersonTile(
                serverUrl: env.server.toString(),
                userId: person.id,
                name: person.name,
                username: person.username,
                pictureUpdate: person.pictureAt,
                trailing: switch (times[person.id]) {
                  final at? => Text(
                    momentLabel(at, now, use24: use24),
                    style: TextStyle(color: sheet.tokens.muted),
                  ),
                  null => null,
                },
              ),
        ],
      ),
    ),
  );
}
