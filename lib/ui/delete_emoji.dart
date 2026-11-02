import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/emoji_providers.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/try_action.dart';

/// Asks, then deletes the custom emoji [name] with id [id]; true when it
/// is gone. A refusal is told in a snackbar with what the server said.
Future<bool> deleteCustomEmoji(
  BuildContext context,
  WidgetRef ref, {
  required String url,
  required String id,
  required String name,
}) async {
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
  if (!confirmed || !context.mounted) return false;
  return tryAction(
    context,
    hostOf(url),
    failure: "Couldn't delete :$name:.",
    () async => (await actions).delete(id),
  );
}
