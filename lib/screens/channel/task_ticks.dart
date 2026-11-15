import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/markdown/task_list.dart';
import 'package:matterleast/screens/channel/message_menu.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/markdown/task_toggle.dart';

/// Lets the user tick the tasks in [target]'s message when they may edit
/// it; saves like any edit and reverts with the server's words on failure.
/// [builder] gets the screen reader actions for the tasks.
class TaskTicks extends ConsumerStatefulWidget {
  const TaskTicks({required this.target, required this.builder, super.key});

  final MessageTarget target;
  final Widget Function(
    BuildContext context,
    Map<CustomSemanticsAction, VoidCallback> actions,
  )
  builder;

  @override
  ConsumerState<TaskTicks> createState() => _TaskTicksState();
}

class _TaskTicksState extends ConsumerState<TaskTicks> {
  Future<void> _toggle(int index) async {
    final target = widget.target;
    final next = toggleTask(target.post.message, index);
    if (next == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final host = hostOf(target.url);
    try {
      final posts = await ref.read(postActionsProvider(target.url).future);
      await posts.editPost(target.post.id, next);
    } on ApiError catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't change the task. ${requestProblemText(e, host)}",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.target;
    final post = target.post;
    final facts = ref
        .watch(postMenuFactsProvider(target.url, post, target.teamId))
        .value;
    final allowed = facts?.rights.edit ?? false;
    final doc = markdownCache.get(
      post.id,
      post.editAt,
      post.message,
      PostEnvironment.maybeOf(context)?.options ?? const ParseOptions(),
    );
    final states = allowed ? taskStates(doc) : const <bool>[];
    return TaskToggle(
      onToggle: allowed ? _toggle : null,
      child: widget.builder(context, {
        for (final (i, done) in states.indexed)
          CustomSemanticsAction(
            label: 'Mark task ${i + 1} ${done ? 'not done' : 'done'}',
          ): () =>
              _toggle(i),
      }),
    );
  }
}
