import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/emoji_providers.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/ui/confirm_dialog.dart';

/// Asks, then deletes the custom emoji [name] with id [id]; true when it
/// is gone. A refusal is told in a snackbar with what the server said.
Future<bool> deleteCustomEmoji(
  BuildContext context,
  WidgetRef ref, {
  required String url,
  required String id,
  required String name,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final actions = ref.read(emojiActionsOnProvider(url).future);
  final confirmed = await confirm(
    context,
    title: 'Delete :$name:?',
    body:
        'It goes for everyone on the server. Messages that already use it '
        'show :$name: as text.',
    action: 'Delete',
    destructive: true,
  );
  if (!confirmed) return false;
  try {
    await (await actions).delete(id);
    return true;
  } on Object catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          "Couldn't delete :$name:. "
          '${requestProblemText(e, Uri.parse(url).host)}',
        ),
      ),
    );
    return false;
  }
}
