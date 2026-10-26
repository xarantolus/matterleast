import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/data/files/local_copies.dart';
import 'package:matterleast/domain/autocomplete.dart';
import 'package:matterleast/domain/permissions.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/screens/channel/composer_controller.dart';
import 'package:matterleast/screens/channel/link_opener.dart';
import 'package:matterleast/screens/channel/posting_rules.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/emoji_picker.dart';
import 'package:matterleast/ui/message_display.dart';
import 'package:matterleast/ui/person_tile.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'composer.g.dart';

/// Whether messages can be marked important or urgent, and whether they
/// can ask for acknowledgement.
@riverpod
Stream<({bool priority, bool acknowledgements})> postPriorityOptions(
  Ref ref,
  String url,
) async* {
  final db = (await ref.watch(serverSessionProvider(url).future)).db;
  yield* db
      .watchFeatures()
      .map(
        (f) => (priority: f.postPriority, acknowledgements: f.acknowledgements),
      )
      .distinct();
}

/// The longest message the server takes.
@riverpod
Stream<int> maxPostSize(Ref ref, String url) async* {
  final db = (await ref.watch(serverSessionProvider(url).future)).db;
  yield* db.watchFeatures().map((f) => f.maxPostSize).distinct();
}

/// The counter shows from this share of the limit on.
const _counterFrom = 0.9;

/// Where a message is written: suggestions above the field, then the field
/// and the send button. Where the user can't post, a notice says why.
class Composer extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final rights = ref.watch(channelRightsProvider(url, channelId)).value;
    final block = archived ? PostingBlock.archived : rights?.block;
    if (block != null) return PostingNotice(block: block);
    return _ComposerField(
      url: url,
      channelId: channelId,
      rootId: rootId,
      teamId: teamId,
      hint: hint,
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
    ref.read(_provider.notifier).inTeam(widget.teamId);
  }

  @override
  void didUpdateWidget(_ComposerField old) {
    super.didUpdateWidget(old);
    if (old.teamId != widget.teamId) {
      ref.read(_provider.notifier).inTeam(widget.teamId);
    }
  }

  /// After the message menu has closed, which would take the focus back.
  void _focusSoon() {
    _focusLater?.cancel();
    _focusLater = Timer(const Duration(milliseconds: 350), _focus.requestFocus);
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
    for (final path in _picked) {
      unawaited(_deletePicked(path));
    }
    super.dispose();
  }

  /// Picker copies still shown as a preview; deleted when the composer goes.
  final _picked = <String>{};

  static Future<void> _deletePicked(String path) async =>
      LocalCopies.deletePicked(await LocalCopies.cacheDirectory(), path);

  @override
  Widget build(BuildContext context) {
    ref.listen(_provider, (before, next) {
      if (_text.value != next.text) _text.value = next.text;
      if ((next.editing != null && before?.editing != next.editing) ||
          next.quotes > (before?.quotes ?? 0)) {
        _focusSoon();
      }
    });
    final value = ref.watch(_provider);
    final tokens = context.tokens;
    final limit =
        ref.watch(maxPostSizeProvider(widget.url)).value ??
        ServerFeatures.defaultMaxPostSize;
    final length = value.text.text.length;
    final editing = value.editing;
    final files = value.attachments;
    final options = ref.watch(postPriorityOptionsProvider(widget.url)).value;
    final uploads =
        ref.watch(featuresProvider(widget.url)).value?.fileUploads ?? true;
    final canPrioritize = widget.rootId.isEmpty && (options?.priority ?? false);
    final sendable = canSend(value, limit);
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
            if (files.isNotEmpty && editing == null)
              AttachmentStrip(
                attachments: files,
                onRemove: ref.read(_provider.notifier).detach,
              ),
            if (value.priority case final priority?
                when canPrioritize && editing == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.sm,
                  Spacing.md,
                  0,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: PriorityChip(
                    priority: priority,
                    onPressed: () => _pickPriority(options!.acknowledgements),
                    onDeleted: () =>
                        ref.read(_provider.notifier).setPriority(null),
                  ),
                ),
              ),
            if (length >= limit * _counterFrom)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.lg,
                  Spacing.xs,
                  Spacing.lg,
                  0,
                ),
                child: Text(
                  '$length / $limit',
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: length > limit
                        ? Theme.of(context).colorScheme.error
                        : tokens.muted,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.xs,
                Spacing.sm,
                Spacing.xs,
                Spacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (editing == null && (uploads || canPrioritize))
                    IconButton(
                      tooltip: 'Attach',
                      onPressed:
                          (!uploads || files.length >= maxAttachments) &&
                              !canPrioritize
                          ? null
                          : () => _attach(
                              uploads: uploads,
                              acknowledgements: canPrioritize
                                  ? options!.acknowledgements
                                  : null,
                            ),
                      icon: const Icon(Icons.add_circle_outline),
                    )
                  else
                    const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Stack(
                      children: [
                        // A hardware keyboard sends with Ctrl+Enter and
                        // leaves editing with Escape.
                        CallbackShortcuts(
                          bindings: {
                            const SingleActivator(
                              LogicalKeyboardKey.enter,
                              control: true,
                            ): () {
                              if (sendable) unawaited(_send());
                            },
                            const SingleActivator(
                              LogicalKeyboardKey.escape,
                            ): () {
                              if (editing != null) {
                                ref.read(_provider.notifier).stopEditing();
                              }
                            },
                          },
                          child: TextField(
                            controller: _text,
                            focusNode: _focus,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.forMessages(context, fallbackSize: 16),
                            minLines: 1,
                            maxLines: 6,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: widget.hint,
                              hintMaxLines: 1,
                              filled: true,
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding:
                                  const EdgeInsetsDirectional.fromSTEB(
                                    Spacing.lg,
                                    Spacing.md,
                                    48,
                                    Spacing.md,
                                  ),
                            ),
                          ),
                        ),
                        // At the bottom like send, so a long message keeps
                        // it next to the line being written.
                        PositionedDirectional(
                          end: 0,
                          bottom: 0,
                          child: IconButton(
                            tooltip: 'Emoji',
                            onPressed: _pickEmoji,
                            icon: const Icon(Icons.mood),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  IconButton.filled(
                    tooltip: editing != null ? 'Save' : 'Send',
                    onPressed: sendable ? _send : null,
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

  Future<void> _pickEmoji() async {
    final draft = ref.read(_provider.notifier);
    final name = await showEmojiPicker(context, widget.url);
    if (name == null) return;
    final unicode = unicodeForName(name);
    draft.insert(unicode ?? ':$name: ');
    _focus.requestFocus();
  }

  Future<void> _pickPriority(bool acknowledgements) async {
    final draft = ref.read(_provider.notifier);
    final picked = await showModalBottomSheet<api.PostPriority>(
      context: context,
      showDragHandle: true,
      builder: (_) => PriorityPicker(
        initial: ref.read(_provider).priority,
        acknowledgements: acknowledgements,
      ),
    );
    if (picked == null) return;
    draft.setPriority(
      picked.priority == api.PostPriorityPriority.empty ? null : picked,
    );
  }

  /// Files only with [uploads]; priority unless [acknowledgements] is null.
  Future<void> _attach({
    required bool uploads,
    required bool? acknowledgements,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final room = maxAttachments - ref.read(_provider).attachments.length;
    final source = await showModalBottomSheet<PickSource>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (uploads)
              for (final (source, icon, label) in const [
                (
                  PickSource.camera,
                  Icons.photo_camera_outlined,
                  'Take a photo',
                ),
                (
                  PickSource.media,
                  Icons.photo_library_outlined,
                  'Photos and videos',
                ),
                (PickSource.files, Icons.attach_file, 'Files'),
              ])
                ListTile(
                  leading: Icon(icon),
                  title: Text(label),
                  enabled: room > 0,
                  onTap: () => Navigator.of(sheet).pop(source),
                ),
            if (acknowledgements != null)
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Message priority'),
                onTap: () {
                  Navigator.of(sheet).pop();
                  unawaited(_pickPriority(acknowledgements));
                },
              ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await pickFiles(source, room);
    if (!mounted) return;
    if (picked.length > room) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A message can carry $maxAttachments files at most.'),
        ),
      );
    }
    final draft = ref.read(_provider.notifier);
    for (final f in picked.take(room)) {
      final copy = f.file.path;
      // A copy with a preview stays until the composer goes, so the
      // thumbnail can still be read.
      if (f.path != null) _picked.add(copy);
      unawaited(
        draft
            .attach(
              open: f.file.openRead,
              name: f.name,
              size: f.size,
              path: f.path,
            )
            .whenComplete(() async {
              if (f.path == null) await _deletePicked(copy);
            }),
      );
    }
  }

  Future<void> _send() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final outcome = await ref
        .read(_provider.notifier)
        .submit(
          teamId: widget.teamId,
          confirmMention: (message) async =>
              mounted &&
              await confirmChannelMention(
                context,
                ref,
                widget.url,
                widget.channelId,
                message,
              ),
        );
    switch (outcome) {
      case SubmitOpenLink(:final uri):
        await openLinkFromMessage(navigator, uri);
      case SubmitFailed(:final text):
        messenger.showSnackBar(SnackBar(content: Text(text)));
      case SubmitDone():
    }
  }
}

/// The priority the message will be sent with, above the field; a tap
/// changes it.
class PriorityChip extends StatelessWidget {
  const PriorityChip({
    required this.priority,
    required this.onPressed,
    required this.onDeleted,
    super.key,
  });

  final api.PostPriority priority;
  final VoidCallback onPressed;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final urgent = priority.priority == api.PostPriorityPriority.urgent;
    final colors = Theme.of(context).colorScheme;
    return InputChip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(
        urgent ? Icons.error : Icons.info,
        color: urgent ? colors.error : colors.primary,
      ),
      label: Text(
        [
          if (urgent) 'Urgent' else 'Important',
          if (priority.requestedAck ?? false) 'acknowledgement requested',
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      tooltip: 'Message priority',
      onPressed: onPressed,
      onDeleted: onDeleted,
      deleteButtonTooltipMessage: 'Remove priority',
    );
  }
}

/// Standard, important or urgent, and whether to ask for acknowledgement.
class PriorityPicker extends StatefulWidget {
  const PriorityPicker({
    required this.initial,
    required this.acknowledgements,
    super.key,
  });

  final api.PostPriority? initial;
  final bool acknowledgements;

  @override
  State<PriorityPicker> createState() => _PriorityPickerState();
}

class _PriorityPickerState extends State<PriorityPicker> {
  late var _level = widget.initial?.priority ?? api.PostPriorityPriority.empty;
  late var _ack = widget.initial?.requestedAck ?? false;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Message priority',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        RadioGroup<api.PostPriorityPriority>(
          groupValue: _level,
          onChanged: (v) => setState(() => _level = v ?? _level),
          child: Column(
            children: [
              for (final (level, icon, label) in const [
                (
                  api.PostPriorityPriority.empty,
                  Icons.flag_outlined,
                  'Standard',
                ),
                (api.PostPriorityPriority.important, Icons.info, 'Important'),
                (api.PostPriorityPriority.urgent, Icons.error, 'Urgent'),
              ])
                RadioListTile(
                  value: level,
                  secondary: Icon(icon),
                  title: Text(label),
                ),
            ],
          ),
        ),
        if (widget.acknowledgements)
          SwitchListTile(
            value: _ack,
            onChanged: (v) => setState(() => _ack = v),
            title: const Text('Request acknowledgement'),
          ),
        Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(
                api.PostPriority(
                  priority: _level,
                  requestedAck: widget.acknowledgements && _ack,
                ),
              ),
              child: const Text('Apply'),
            ),
          ),
        ),
      ],
    ),
  );
}

enum PickSource { camera, media, files }

typedef PickedFile = ({XFile file, String? path, String name, int size});

/// Files the user picks from the camera, the photo picker or the
/// documents UI. The photo picker needs no media permission.
Future<List<PickedFile>> pickFiles(PickSource source, int room) async {
  final platform = ImagePickerPlatform.instance;
  if (platform is ImagePickerAndroid) platform.useAndroidPhotoPicker = true;
  Future<PickedFile> of(XFile f) async =>
      (file: f, path: f.path, name: f.name, size: await f.length());
  switch (source) {
    case PickSource.camera:
      final photo = await ImagePicker().pickImage(source: ImageSource.camera);
      return [if (photo != null) await of(photo)];
    case PickSource.media:
      final media = await ImagePicker().pickMultipleMedia(
        limit: room > 1 ? room : null,
      );
      return [for (final m in media) await of(m)];
    case PickSource.files:
      final result = await FilePicker.pickFiles();
      return [
        for (final f in result)
          (
            file: f.xFile,
            path: null,
            name: f.name,
            size: await f.xFile.length(),
          ),
      ];
  }
}

/// The files of the message being written, each with its progress and a
/// way to take it off.
class AttachmentStrip extends StatelessWidget {
  const AttachmentStrip({
    required this.attachments,
    required this.onRemove,
    super.key,
  });

  final List<Attachment> attachments;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    // The file cards hold two lines of text, which grow with the font.
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    return SizedBox(
      height: 96 + 40 * (scale - 1),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.sm,
          Spacing.lg,
          0,
        ),
        children: [
          for (final a in attachments)
            Padding(
              padding: const EdgeInsets.only(right: Spacing.sm),
              child: Semantics(
                container: true,
                label: [
                  a.name,
                  a.error ?? (a.uploading ? 'uploading' : 'attached'),
                ].join(', '),
                child: SizedBox(
                  width: a.isImage && a.path != null ? 88 : 180,
                  child: Card.outlined(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (a.isImage && a.path != null)
                          ExcludeSemantics(
                            child: Image.file(
                              File(a.path!),
                              fit: BoxFit.cover,
                              cacheWidth: 264,
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              Spacing.sm,
                              Spacing.sm,
                              Spacing.xl,
                              Spacing.sm,
                            ),
                            child: ExcludeSemantics(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.insert_drive_file_outlined,
                                    color: tokens.muted,
                                  ),
                                  Text(
                                    a.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.labelMedium,
                                  ),
                                  Text(
                                    a.error ?? fileSizeText(a.size),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.bodySmall?.copyWith(
                                      color: a.error != null
                                          ? Theme.of(context).colorScheme.error
                                          : tokens.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (a.error != null && a.isImage && a.path != null)
                          ColoredBox(
                            color: Theme.of(context).colorScheme.errorContainer
                                .withValues(alpha: 0.85),
                            child: Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        if (a.uploading)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: LinearProgressIndicator(
                              value: a.progress > 0 ? a.progress : null,
                            ),
                          ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton.filledTonal(
                            iconSize: 16,
                            tooltip: a.uploading ? 'Cancel upload' : 'Remove',
                            onPressed: () => onRemove(a.clientId),
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Pure: a byte count in the units people read.
String fileSizeText(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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
    final tokens = context.tokens;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.3,
      ),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        // An edge, so a single suggestion doesn't read as a message.
        shape: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: suggestions.length,
          itemBuilder: (context, i) {
            final s = suggestions[i];
            Widget row(Widget leading, String title, String subtitle) =>
                ListTile(
                  dense: true,
                  leading: SizedBox(width: 32, child: Center(child: leading)),
                  title: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
            return switch (s) {
              UserSuggestion() => PersonTile(
                dense: true,
                serverUrl: url,
                userId: s.id,
                name: [
                  '${s.firstName} ${s.lastName}'.trim(),
                  if (s.nickname.isNotEmpty) '(${s.nickname})',
                ].where((p) => p.isNotEmpty).join(' '),
                username: s.username,
                note: s.outOfChannel ? 'not in channel' : null,
                onTap: () => onPick(s),
              ),
              SpecialMention() => row(
                const Icon(Icons.campaign_outlined),
                '@${s.handle}',
                s.onlineOnly
                    ? 'Notifies everyone online in this channel'
                    : 'Notifies everyone in this channel',
              ),
              GroupSuggestion() => row(
                const Icon(Icons.groups_outlined),
                '@${s.name}',
                s.displayName == s.name ? '' : s.displayName,
              ),
              ChannelSuggestion() => row(
                Icon(s.type == 'P' ? Icons.lock_outline : Icons.tag),
                s.displayName,
                '~${s.name}',
              ),
              EmojiSuggestion() => row(
                EmojiGlyph(name: s.name, size: 24, serverUrl: url),
                ':${s.name}:',
                '',
              ),
              CommandSuggestion() => row(
                const Icon(Icons.terminal),
                '/${s.complete}${s.hint.isEmpty ? '' : ' ${s.hint}'}',
                s.description,
              ),
            };
          },
        ),
      ),
    );
  }
}
