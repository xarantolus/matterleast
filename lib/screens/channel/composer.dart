import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/app/emoji_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/domain/autocomplete.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel/composer_controller.dart';
import 'package:matterleast/screens/channel/link_opener.dart';
import 'package:matterleast/ui/custom_emoji_image.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'composer.g.dart';

/// The longest message the server takes.
@riverpod
Stream<int> maxPostSize(Ref ref, String url) async* {
  final db = (await ref.watch(serverSessionProvider(url).future)).db;
  yield* db
      .watchConfigJson('client_config')
      .map((c) => int.tryParse('${c['MaxPostSize'] ?? ''}') ?? 16383)
      .distinct();
}

/// The counter shows from this share of the limit on.
const _counterFrom = 0.9;

/// Where a message is written: suggestions above the field, then the field
/// and the send button. Archived channels show a notice instead.
class Composer extends StatelessWidget {
  const Composer({
    required this.url,
    required this.channelId,
    required this.teamId,
    required this.hint,
    this.rootId = '',
    this.archived = false,
    super.key,
  });

  final String url;
  final String channelId;
  final String rootId;
  final String teamId;
  final String hint;
  final bool archived;

  @override
  Widget build(BuildContext context) {
    if (!archived) {
      return _ComposerField(
        url: url,
        channelId: channelId,
        rootId: rootId,
        teamId: teamId,
        hint: hint,
      );
    }
    final tokens = context.tokens;
    return Container(
      width: double.infinity,
      color: tokens.panel,
      padding: const EdgeInsets.all(Spacing.lg),
      child: SafeArea(
        top: false,
        child: Text(
          'This channel is archived. You can read it but not post in it.',
          textAlign: TextAlign.center,
          style: TextStyle(color: tokens.muted),
        ),
      ),
    );
  }
}

class _ComposerField extends ConsumerStatefulWidget {
  const _ComposerField({
    required this.url,
    required this.channelId,
    required this.rootId,
    required this.teamId,
    required this.hint,
  });

  final String url;
  final String channelId;
  final String rootId;
  final String teamId;
  final String hint;

  @override
  ConsumerState<_ComposerField> createState() => _ComposerFieldState();
}

class _ComposerFieldState extends ConsumerState<_ComposerField> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  Timer? _focusLater;

  ComposerDraftProvider get _provider =>
      composerDraftProvider(widget.url, widget.channelId, widget.rootId);

  @override
  void initState() {
    super.initState();
    _text.value = ref.read(_provider).text;
    _text.addListener(_typed);
  }

  void _typed() {
    if (_text.value != ref.read(_provider).text) {
      ref.read(_provider.notifier).changed(_text.value);
    }
  }

  @override
  void dispose() {
    _focusLater?.cancel();
    _text.removeListener(_typed);
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(_provider, (before, next) {
      if (_text.value != next.text) _text.value = next.text;
      if (next.editing != null && before?.editing != next.editing) {
        // The message menu is still closing and would take the focus back.
        _focusLater?.cancel();
        _focusLater = Timer(
          const Duration(milliseconds: 350),
          _focus.requestFocus,
        );
      }
    });
    final value = ref.watch(_provider);
    ref.read(_provider.notifier).inTeam(widget.teamId);
    final tokens = context.tokens;
    final limit = ref.watch(maxPostSizeProvider(widget.url)).value ?? 16383;
    final length = value.text.text.length;
    final editing = value.editing;
    final canSend = value.text.text.trim().isNotEmpty && length <= limit;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (value.suggestions.isNotEmpty)
              SuggestionList(
                url: widget.url,
                suggestions: value.suggestions,
                onPick: ref.read(_provider.notifier).pick,
              ),
            if (editing != null)
              Padding(
                padding: const EdgeInsets.only(left: Spacing.lg),
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: tokens.muted),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        'Editing message',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cancel editing',
                      onPressed: ref.read(_provider.notifier).stopEditing,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.sm,
                Spacing.xs,
                Spacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      focusNode: _focus,
                      minLines: 1,
                      maxLines: 6,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        filled: true,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Spacing.lg,
                          vertical: Spacing.md,
                        ),
                        counterText: length >= limit * _counterFrom
                            ? '$length / $limit'
                            : null,
                        counterStyle: length > limit
                            ? TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  IconButton.filled(
                    tooltip: editing != null ? 'Save' : 'Send',
                    onPressed: canSend ? _send : null,
                    icon: Icon(editing != null ? Icons.check : Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final url = widget.url;
    final channelId = widget.channelId;
    final rootId = widget.rootId;
    final draft = ref.read(_provider.notifier);
    final value = ref.read(_provider);
    final message = value.text.text.trim();
    final editing = value.editing;
    try {
      if (editing != null) {
        draft.stopEditing();
        final posts = await ref.read(postActionsProvider(url).future);
        await posts.editPost(editing.id, message);
        return;
      }
      final actions = await ref.read(composerActionsProvider(url).future);
      if (message.startsWith('/')) {
        final outcome = await actions.executeCommand(
          channelId,
          teamId: widget.teamId,
          rootId: rootId,
          text: message,
        );
        if (!mounted) return;
        draft.sent();
        await actions.clearDraft(channelId, rootId: rootId);
        if (outcome case CommandGoto(:final location)) {
          final uri = Uri.tryParse(location);
          if (uri != null && mounted) {
            await openLinkFromMessage(
              navigator,
              ref,
              uri.hasScheme ? uri : Uri.parse(url).resolveUri(uri),
            );
          }
        }
        return;
      }
      draft.sent();
      await actions.send(channelId, rootId: rootId, message: message);
    } on ApiError catch (e) {
      final text = switch (e) {
        ServerError(:final message?) when message.isNotEmpty => message,
        _ => connectionProblemText(e, Uri.parse(url).host),
      };
      messenger.showSnackBar(SnackBar(content: Text(text)));
    }
  }
}

/// What completes the word at the cursor, newest match closest to the
/// field.
class SuggestionList extends ConsumerWidget {
  const SuggestionList({
    required this.url,
    required this.suggestions,
    required this.onPick,
    super.key,
  });

  final String url;
  final List<Suggestion> suggestions;
  final ValueChanged<Suggestion> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emoji = ref.watch(customEmojiProvider(url)).value ?? const {};
    final tokens = context.tokens;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.3,
      ),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: suggestions.length,
          itemBuilder: (context, i) {
            final s = suggestions[i];
            final (leading, title, subtitle) = switch (s) {
              UserSuggestion() => (
                UserAvatar(
                  serverUrl: url,
                  userId: s.id,
                  name: s.username,
                  size: 32,
                ),
                '@${s.username}',
                [
                  '${s.firstName} ${s.lastName}'.trim(),
                  if (s.nickname.isNotEmpty) '(${s.nickname})',
                  if (s.outOfChannel) '· not in channel',
                ].where((p) => p.isNotEmpty).join(' '),
              ),
              SpecialMention() => (
                const Icon(Icons.campaign_outlined),
                '@${s.handle}',
                s.onlineOnly
                    ? 'Notifies everyone online in this channel'
                    : 'Notifies everyone in this channel',
              ),
              ChannelSuggestion() => (
                Icon(s.type == 'P' ? Icons.lock_outline : Icons.tag),
                s.displayName,
                '~${s.name}',
              ),
              EmojiSuggestion(:final unicode?) => (
                Text(unicode, style: const TextStyle(fontSize: 24)),
                ':${s.name}:',
                '',
              ),
              EmojiSuggestion() => (
                SizedBox.square(
                  dimension: 24,
                  child: switch (emoji[s.name]) {
                    final id? => CustomEmojiImage(
                      serverUrl: url,
                      emojiId: id,
                      size: 24,
                      fallback: const Icon(Icons.mood),
                    ),
                    null => const Icon(Icons.mood),
                  },
                ),
                ':${s.name}:',
                '',
              ),
              CommandSuggestion() => (
                const Icon(Icons.terminal),
                '/${s.complete}${s.hint.isEmpty ? '' : ' ${s.hint}'}',
                s.description,
              ),
            };
            return ListTile(
              dense: true,
              leading: SizedBox(width: 32, child: Center(child: leading)),
              title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: subtitle.isEmpty
                  ? null
                  : Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: tokens.muted),
                    ),
              onTap: () => onPick(s),
            );
          },
        ),
      ),
    );
  }
}
