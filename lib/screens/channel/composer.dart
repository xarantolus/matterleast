import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/live_providers.dart';
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/data/files/local_copies.dart';
import 'package:matterleast/domain/autocomplete.dart';
import 'package:matterleast/domain/permissions.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/screens/channel/composer_controller.dart';
import 'package:matterleast/screens/channel/composer_desktop.dart';
import 'package:matterleast/screens/channel/composer_extras.dart';
import 'package:matterleast/screens/channel/composer_keys.dart';
import 'package:matterleast/screens/channel/link_opener.dart';
import 'package:matterleast/screens/channel/message_menu.dart';
import 'package:matterleast/screens/channel/posting_rules.dart';
import 'package:matterleast/screens/drafts/drafts_providers.dart';
import 'package:matterleast/screens/drafts/schedule_picker.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/emoji_picker.dart';
import 'package:matterleast/ui/message_display.dart';
import 'package:matterleast/ui/person_tile.dart';
import 'package:matterleast/ui/sheet_header.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:pasteboard/pasteboard.dart';
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
    this.autofocus = false,
    this.lastOwnPost,
    super.key,
  });

  final String url;
  final String channelId;
  final String rootId;
  final String teamId;
  final String hint;
  final bool archived;

  /// The newest message of the signed-in user here, for Up in an empty
  /// field.
  final PostItem? Function()? lastOwnPost;

  /// The field takes the keyboard when it first shows.
  final bool autofocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rights = ref.watch(channelRightsProvider(url, channelId)).value;
    final block = archived ? PostingBlock.archived : rights?.block;
    if (block != null) return PostingNotice(block: block);
    final field = _ComposerField(
      url: url,
      channelId: channelId,
      rootId: rootId,
      teamId: teamId,
      hint: hint,
      autofocus: autofocus,
      lastOwnPost: lastOwnPost,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScheduledNotice(
          url: url,
          channelId: channelId,
          rootId: rootId,
          teamId: teamId,
        ),
        field,
      ],
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
    required this.autofocus,
    required this.lastOwnPost,
  });

  final PostItem? Function()? lastOwnPost;
  final String url;
  final String channelId;
  final String rootId;
  final String teamId;
  final String hint;
  final bool autofocus;

  @override
  ConsumerState<_ComposerField> createState() => _ComposerFieldState();
}

class _ComposerFieldState extends ConsumerState<_ComposerField> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  final _suggestionsShown = OverlayPortalController()..show();
  Timer? _focusLater;

  /// The suggestion Enter and Tab take.
  int _highlight = 0;

  ComposerDraftProvider get _provider =>
      composerDraftProvider(widget.url, widget.channelId, widget.rootId);

  @override
  void initState() {
    super.initState();
    _text.value = ref.read(_provider).text;
    _text.addListener(_typed);
    _focus.onKeyEvent = _onKey;
    if (isDesktop) HardwareKeyboard.instance.addHandler(_typeToFocus);
    ref.read(_provider.notifier).inTeam(widget.teamId);
    // Taken once the field is in the tree, after anything that closed on
    // the way here gave the focus back.
    if (widget.autofocus) _focus.requestFocus();
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

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final keys = HardwareKeyboard.instance;
    if (isDesktop &&
        event.logicalKey == LogicalKeyboardKey.keyV &&
        keys.isControlPressed &&
        !keys.isAltPressed) {
      // The text paste goes on as usual; an image alone is attached.
      unawaited(_pasteImage());
    }
    final value = ref.read(_provider);
    final suggestions = value.suggestions;
    final field = _text.value;
    final action = composerKey(
      key: event.logicalKey,
      shift: keys.isShiftPressed,
      control: keys.isControlPressed,
      alt: keys.isAltPressed,
      meta: keys.isMetaPressed,
      // A phone's soft keyboard sends no key events, so a key event here
      // is a hardware keyboard, which sends with Enter as the official app
      // does.
      enterSends:
          isDesktop ||
          (defaultTargetPlatform == TargetPlatform.android &&
              event.deviceType == ui.KeyEventDeviceType.keyboard),
      composing: field.composing.isValid && !field.composing.isCollapsed,
      suggestionsOpen: suggestions.isNotEmpty,
      editing: value.editing != null,
      empty: field.text.isEmpty,
      desktop: isDesktop,
    );
    if (action == null) return KeyEventResult.ignored;
    if (event is KeyRepeatEvent &&
        action != ComposerKey.nextSuggestion &&
        action != ComposerKey.previousSuggestion) {
      return KeyEventResult.handled;
    }
    final draft = ref.read(_provider.notifier);
    switch (action) {
      case ComposerKey.send:
        if (canSend(value, _limit)) unawaited(_send());
      case ComposerKey.acceptSuggestion:
        draft.pick(suggestions[_highlight.clamp(0, suggestions.length - 1)]);
      case ComposerKey.nextSuggestion:
        setState(
          () => _highlight = movedHighlight(_highlight, 1, suggestions.length),
        );
      case ComposerKey.previousSuggestion:
        setState(
          () => _highlight = movedHighlight(_highlight, -1, suggestions.length),
        );
      case ComposerKey.closeSuggestions:
        draft.dismissSuggestions();
      case ComposerKey.editLast:
        unawaited(_editLast());
      case ComposerKey.stopEditing:
        draft.stopEditing();
      case ComposerKey.blur:
        node.unfocus();
    }
    return KeyEventResult.handled;
  }

  Future<void> _pasteImage() async {
    final bytes = await clipboardImage(
      () => Pasteboard.image,
      () => Pasteboard.text,
    );
    if (bytes == null || !mounted) return;
    unawaited(
      ref
          .read(_provider.notifier)
          .attach(
            open: () => Stream.value(bytes),
            name: pastedImageName(DateTime.now()),
            size: bytes.length,
          ),
    );
  }

  static KeyEvent? _typedEvent;

  /// Typing while no text field has the focus starts the message.
  bool _typeToFocus(KeyEvent event) {
    if (event is KeyUpEvent) return false;
    final keys = HardwareKeyboard.instance;
    final focus = FocusManager.instance.primaryFocus;
    final typed = typesIntoComposer(
      character: event.character,
      control: keys.isControlPressed,
      alt: keys.isAltPressed,
      meta: keys.isMetaPressed,
      textFocused: textHasFocus(),
      otherFocused: focus != null && focus is! FocusScopeNode,
      routeCurrent: ModalRoute.isCurrentOf(context) ?? true,
    );
    if (!typed || !_focus.canRequestFocus || identical(event, _typedEvent)) {
      return false;
    }
    // Every composer on screen hears the key; only the first takes it.
    _typedEvent = event;
    _focus.requestFocus();
    _text.value = typedInto(_text.value, event.character!);
    return true;
  }

  int get _limit =>
      ref.read(maxPostSizeProvider(widget.url)).value ??
      ServerFeatures.defaultMaxPostSize;

  /// Edits the newest own message through the same checks as the message
  /// menu's Edit.
  Future<void> _editLast() async {
    final post = widget.lastOwnPost?.call();
    if (post == null) return;
    final facts = await ref.read(
      postMenuFactsProvider(widget.url, post, widget.teamId).future,
    );
    if (!mounted || !facts.rights.edit) return;
    ref.read(_provider.notifier).startEditing(post);
  }

  void _typed() {
    if (_text.value != ref.read(_provider).text) {
      ref.read(_provider.notifier).changed(_text.value);
    }
  }

  @override
  void dispose() {
    if (isDesktop) HardwareKeyboard.instance.removeHandler(_typeToFocus);
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
      if (before?.suggestions != next.suggestions) _highlight = 0;
      if ((next.editing != null && before?.editing != next.editing) ||
          next.quotes > (before?.quotes ?? 0)) {
        _focusSoon();
      }
    });
    final value = ref.watch(_provider);
    final suggestions = value.suggestions;
    // Over the messages, so the list doesn't shrink and move under the
    // reader while they come and go.
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _suggestionsShown,
      overlayChildBuilder: (context, info) {
        if (suggestions.isEmpty) return const SizedBox.shrink();
        final field = MatrixUtils.transformRect(
          info.childPaintTransform,
          Offset.zero & info.childSize,
        );
        return Positioned(
          left: field.left,
          width: field.width,
          bottom: info.overlaySize.height - field.top,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: math.max(0, field.top)),
            child: TextFieldTapRegion(
              child: SuggestionList(
                url: widget.url,
                suggestions: suggestions,
                highlighted: _highlight,
                onPick: ref.read(_provider.notifier).pick,
              ),
            ),
          ),
        );
      },
      child: _field(context, value),
    );
  }

  Widget _field(BuildContext context, ComposerValue value) {
    final tokens = context.tokens;
    final limit =
        ref.watch(maxPostSizeProvider(widget.url)).value ??
        ServerFeatures.defaultMaxPostSize;
    final length = value.text.text.length;
    final editing = value.editing;
    final files = value.attachments;
    final options = ref.watch(postPriorityOptionsProvider(widget.url)).value;
    final features = ref.watch(featuresProvider(widget.url)).value;
    final uploads = features?.fileUploads ?? true;
    final canPrioritize = widget.rootId.isEmpty && (options?.priority ?? false);
    final sendable = canSend(value, limit);
    final canBurn = widget.rootId.isEmpty && (features?.burnOnRead ?? false);
    // Kept current for the schedule picker.
    ref.watch(manualTimeZoneProvider(widget.url));
    final burning =
        canBurn &&
        ref.watch(burnOnReadChoiceProvider(widget.url, widget.channelId));
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                stalled: !ref.watch(serverLiveProvider(widget.url)),
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
            if (burning && editing == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.sm,
                  Spacing.md,
                  0,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: BurnOnReadChip(
                    duration: features!.burnOnReadDuration,
                    onDeleted: () => ref
                        .read(
                          burnOnReadChoiceProvider(
                            widget.url,
                            widget.channelId,
                          ).notifier,
                        )
                        .set(on: false),
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
                  if (editing == null && (uploads || canPrioritize || canBurn))
                    IconButton(
                      tooltip: 'Attach',
                      onPressed:
                          (!uploads || files.length >= maxAttachments) &&
                              !canPrioritize &&
                              !canBurn
                          ? null
                          : () => _attach(
                              uploads: uploads,
                              acknowledgements: canPrioritize
                                  ? options!.acknowledgements
                                  : null,
                              burnOnRead: canBurn,
                            ),
                      icon: const Icon(Icons.add_circle_outline),
                    )
                  else
                    const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Stack(
                      children: [
                        TextField(
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
                        // At the bottom like send, so a long message keeps
                        // it next to the line being written.
                        PositionedDirectional(
                          end: 0,
                          bottom: 0,
                          child: Builder(
                            builder: (button) => IconButton(
                              tooltip: 'Emoji',
                              onPressed: () => _pickEmoji(globalRectOf(button)),
                              icon: const Icon(Icons.mood),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  SendButton(
                    editing: editing != null,
                    onSend: sendable ? _send : null,
                    onSchedule:
                        sendable &&
                            editing == null &&
                            !burning &&
                            (features?.scheduledPosts ?? false) &&
                            !value.text.text.trimLeft().startsWith('/')
                        ? _schedule
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickEmoji(Rect? anchor) async {
    final draft = ref.read(_provider.notifier);
    final name = await showEmojiPicker(context, widget.url, anchor: anchor);
    if (name == null) return;
    final unicode = unicodeForName(name);
    draft.insert(unicode ?? ':$name: ');
    _focus.requestFocus();
  }

  Future<void> _pickPriority(bool acknowledgements) async {
    final draft = ref.read(_provider.notifier);
    final picked = await showAppSheet<api.PostPriority>(
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

  /// Files only with [uploads]; priority unless [acknowledgements] is null;
  /// the burn-on-read switch with [burnOnRead].
  Future<void> _attach({
    required bool uploads,
    required bool? acknowledgements,
    bool burnOnRead = false,
  }) async {
    final room = maxAttachments - ref.read(_provider).attachments.length;
    final source = await showAppSheet<PickSource>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (uploads)
              for (final (source, icon, label) in pickSources(
                desktop: isDesktop,
              ))
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
            if (burnOnRead)
              Consumer(
                builder: (context, ref, _) {
                  final choice = burnOnReadChoiceProvider(
                    widget.url,
                    widget.channelId,
                  );
                  return SwitchListTile(
                    secondary: const Icon(Icons.local_fire_department_outlined),
                    title: const Text('Burn on read'),
                    subtitle: const Text(
                      'Hidden until opened, then deleted after a while',
                    ),
                    value: ref.watch(choice),
                    onChanged: (on) {
                      ref.read(choice.notifier).set(on: on);
                      Navigator.of(sheet).pop();
                    },
                  );
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

  Future<void> _schedule() async {
    // Down for good: a day and a time picker may follow the sheet.
    FocusManager.instance.primaryFocus?.unfocus();
    final zone = ref.read(manualTimeZoneProvider(widget.url)).value;
    final at = await pickScheduleTime(context, zone: zone);
    if (at != null && mounted) await _send(at: at);
  }

  String _when(DateTime at) => untilLabel(
    at,
    DateTime.now(),
    use24: MediaQuery.alwaysUse24HourFormatOf(context),
  );

  /// Sends now, or at [at] where the server schedules it.
  Future<void> _send({DateTime? at}) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final outcome = await ref
        .read(_provider.notifier)
        .submit(
          teamId: widget.teamId,
          at: at,
          burnOnRead:
              widget.rootId.isEmpty &&
              ref.read(
                burnOnReadChoiceProvider(widget.url, widget.channelId),
              ) &&
              (ref.read(featuresProvider(widget.url)).value?.burnOnRead ??
                  false),
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
      case SubmitScheduled(:final at):
        messenger.showSnackBar(
          SnackBar(content: Text('Scheduled for ${_when(at)}')),
        );
      case SubmitDone():
    }
    if (isDesktop && mounted) _focus.requestFocus();
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
        const SheetHeader('Message priority'),
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

typedef PickChoice = (PickSource, IconData, String);

/// What the + sheet offers; desktops have no camera to take a photo with.
List<PickChoice> pickSources({required bool desktop}) => [
  if (!desktop)
    (PickSource.camera, Icons.photo_camera_outlined, 'Take a photo'),
  (PickSource.media, Icons.photo_library_outlined, 'Photos and videos'),
  (PickSource.files, Icons.attach_file, 'Files'),
];

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
    this.stalled = false,
    super.key,
  });

  final List<Attachment> attachments;
  final ValueChanged<String> onRemove;

  /// The server isn't live, so the last progress may no longer hold; the
  /// bars wait without a value.
  final bool stalled;

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
                              value: a.progress > 0 && !stalled
                                  ? a.progress
                                  : null,
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
    this.highlighted,
    super.key,
  });

  final String url;
  final List<Suggestion> suggestions;
  final ValueChanged<Suggestion> onPick;

  /// The row the keyboard would pick, if it is in use.
  final int? highlighted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
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
        child: ListTileTheme(
          data: ListTileThemeData(
            selectedColor: scheme.onSecondaryContainer,
            selectedTileColor: scheme.secondaryContainer,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < suggestions.length; i++)
                  _Keep(
                    selected: i == highlighted,
                    child: _row(context, suggestions[i], i == highlighted),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, Suggestion s, bool selected) {
    final tokens = context.tokens;
    Widget row(Widget leading, String title, String subtitle) => ListTile(
      dense: true,
      selected: selected,
      leading: SizedBox(width: 32, child: Center(child: leading)),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: selected ? null : TextStyle(color: tokens.muted),
            ),
      onTap: () => onPick(s),
    );
    return switch (s) {
      UserSuggestion() => PersonTile(
        dense: true,
        selected: selected,
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
  }
}

/// Keeps the row the keyboard moved to in view.
class _Keep extends StatefulWidget {
  const _Keep({required this.selected, required this.child});

  final bool selected;
  final Widget child;

  @override
  State<_Keep> createState() => _KeepState();
}

class _KeepState extends State<_Keep> {
  @override
  void initState() {
    super.initState();
    _show();
  }

  @override
  void didUpdateWidget(_Keep old) {
    super.didUpdateWidget(old);
    if (!old.selected) _show();
  }

  void _show() {
    if (!widget.selected) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(Scrollable.ensureVisible(context));
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
