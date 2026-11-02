import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/emoji_providers.dart';
import 'package:matterleast/data/emoji/custom_emoji.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/ui/add_emoji.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/delete_emoji.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/empty_state.dart';

/// The server's custom emoji with who added each, a way to add one and to
/// delete those the user may.
class CustomEmojiPage extends ConsumerWidget {
  const CustomEmojiPage({required this.server, super.key});

  final ServerEntry server;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = server.url;
    final loading = ref.watch(customEmojiCatalogProvider(url)).isLoading;
    final entries = ref.watch(emojiEntriesProvider(url)).value;
    final canAdd = ref.watch(emojiRightsOnProvider(url)).value?.create ?? false;
    return ContentPage(
      title: const Text('Custom emoji'),
      progress: loading,
      actions: [
        if (canAdd)
          IconButton(
            tooltip: 'Add custom emoji',
            icon: const Icon(Icons.add),
            onPressed: () => showAddEmoji(context, url),
          ),
      ],
      body: switch (entries) {
        null => const SizedBox.shrink(),
        [] when loading => const SizedBox.shrink(),
        [] => EmptyState(
          icon: Icons.add_reaction_outlined,
          title: 'No custom emoji yet',
          body: canAdd
              ? 'Add an image to make your own emoji for ${server.displayName}.'
              : '${server.displayName} has no custom emoji.',
        ),
        final entries => ListView.builder(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          itemCount: entries.length,
          itemBuilder: (_, i) => _EmojiRow(url: url, entry: entries[i]),
        ),
      },
    );
  }
}

class _EmojiRow extends ConsumerWidget {
  const _EmojiRow({required this.url, required this.entry});

  final String url;
  final EmojiEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creatorId = ref
        .watch(customEmojiCreatorProvider(url, entry.name))
        .value;
    final creator = creatorId == null || creatorId.isEmpty
        ? null
        : ref.watch(userProfileProvider(url, creatorId)).value;
    return ListTile(
      leading: ExcludeSemantics(
        child: EmojiGlyph(name: entry.name, size: 32, serverUrl: url),
      ),
      title: Text(':${entry.name}:'),
      subtitle: creator == null ? null : Text('Added by ${creator.name}'),
      trailing: entry.canDelete
          ? IconButton(
              tooltip: 'Delete :${entry.name}:',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => deleteCustomEmoji(
                context,
                ref,
                url: url,
                id: entry.id,
                name: entry.name,
              ),
            )
          : null,
    );
  }
}
