import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/views/permission_views.dart';
import 'package:matterleast/domain/channel_mentions.dart';
import 'package:matterleast/domain/permissions.dart';
import 'package:matterleast/ui/tokens.dart';

/// Pure: what the composer's place says when the user can't post.
String postingBlockText(PostingBlock block) => switch (block) {
  PostingBlock.archived =>
    'This channel is archived. You can read it but not post in it.',
  PostingBlock.readOnly =>
    'This channel is read-only. Only administrators can post here.',
  PostingBlock.notAllowed => "You don't have permission to post here.",
};

/// Takes the composer's place where the user can't post.
class PostingNotice extends StatelessWidget {
  const PostingNotice({required this.block, super.key});

  final PostingBlock block;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: double.infinity,
      color: tokens.panel,
      padding: const EdgeInsets.all(Spacing.lg),
      child: SafeArea(
        top: false,
        child: Text(
          postingBlockText(block),
          textAlign: TextAlign.center,
          style: TextStyle(color: tokens.muted),
        ),
      ),
    );
  }
}

/// Asks before [text] notifies everyone in a larger channel, when the
/// server wants that asked; true to send.
Future<bool> confirmChannelMention(
  BuildContext context,
  WidgetRef ref,
  String url,
  String channelId,
  String text,
) async {
  if (channelWideMention(text) == null) return true;
  final session = await ref.read(serverSessionProvider(url).future);
  final db = session.db;
  final channel = await (db.select(
    db.channels,
  )..where((c) => c.id.equals(channelId))).getSingleOrNull();
  final rights = await PermissionViews(db).channel(channelId);
  final question = channelMentionQuestion(
    text,
    confirm: (await db.features()).confirmChannelMentions,
    allowed: rights.channelMentions,
    memberCount: channel?.memberCount,
  );
  if (question == null) return true;
  if (!context.mounted) return false;
  return await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: const Text('Notify the entire channel?'),
          content: Text(question),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialog).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialog).pop(true),
              child: const Text('Send'),
            ),
          ],
        ),
      ) ??
      false;
}
