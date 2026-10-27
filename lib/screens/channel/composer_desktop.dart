import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/screens/channel/composer_controller.dart';
import 'package:matterleast/ui/tokens.dart';

typedef AttachFile = Future<void> Function({
  required Stream<List<int>> Function() open,
  required String name,
  required int size,
  String? path,
});

/// The last part of a path, whichever separator it uses.
String baseName(String path) => path.split(RegExp(r'[\\/]')).last;

/// Starts an upload for each dropped file that fits beside the [have] files
/// already attached. Returns how many were left out for the limit.
Future<int> attachDropped(
  Iterable<XFile> files, {
  required int have,
  required AttachFile attach,
}) async {
  final list = files.toList();
  final room = (maxAttachments - have).clamp(0, maxAttachments);
  final taken = list.take(room).toList();
  final sizes = [for (final f in taken) await f.length()];
  for (var i = 0; i < taken.length; i++) {
    final f = taken[i];
    final name = baseName(f.name.isEmpty ? f.path : f.name);
    // Not awaited: the uploads run side by side and report their own
    // progress and failures.
    attach(open: f.openRead, name: name, size: sizes[i], path: f.path).ignore();
  }
  return list.length - taken.length;
}

/// Pure: whether a key press is typing that belongs in the composer. A
/// space is left to a button that has the focus.
bool typesIntoComposer({
  required String? character,
  required bool control,
  required bool alt,
  required bool meta,
  required bool textFocused,
  required bool otherFocused,
  required bool routeCurrent,
}) {
  if (character == null || character.isEmpty) return false;
  if (control || alt || meta || textFocused || !routeCurrent) return false;
  final code = character.runes.first;
  if (code < 0x20 || code == 0x7f) return false;
  if (character == ' ' && otherFocused) return false;
  return true;
}

/// [value] with [text] typed at its cursor, or at the end.
TextEditingValue typedInto(TextEditingValue value, String text) {
  final selection = value.selection.isValid
      ? value.selection
      : TextSelection.collapsed(offset: value.text.length);
  return TextEditingValue(
    text: value.text.replaceRange(selection.start, selection.end, text),
    selection: TextSelection.collapsed(offset: selection.start + text.length),
  );
}

/// Whether the focus sits in a text field.
bool textHasFocus() =>
    FocusManager.instance.primaryFocus?.context
        ?.findAncestorWidgetOfExactType<EditableText>() !=
    null;

/// A name for a pasted image, distinct enough to tell several apart.
String pastedImageName(DateTime now) {
  String two(int n) => n.toString().padLeft(2, '0');
  return 'image-${now.year}${two(now.month)}${two(now.day)}-'
      '${two(now.hour)}${two(now.minute)}${two(now.second)}.png';
}

/// The image on the clipboard, when there is one and no text beside it
/// (a copied table has both; its text is what the user means).
Future<Uint8List?> clipboardImage(
  Future<Uint8List?> Function() image,
  Future<String?> Function() text,
) async {
  final bytes = await image();
  if (bytes == null || bytes.isEmpty) return null;
  final words = await text();
  return words == null || words.isEmpty ? bytes : null;
}

/// Takes files dropped anywhere on the pane and attaches them to the
/// message being written in [channelId] / [rootId]. A veil with [target]
/// shows while files hover; it floats over the pane and changes no layout.
class ConversationDropTarget extends ConsumerStatefulWidget {
  const ConversationDropTarget({
    required this.url,
    required this.channelId,
    required this.rootId,
    required this.target,
    required this.child,
    super.key,
  });

  final String url;
  final String channelId;
  final String rootId;

  /// What the files go to: "#town-square", "this thread".
  final String target;
  final Widget child;

  @override
  ConsumerState<ConversationDropTarget> createState() =>
      _ConversationDropTargetState();
}

class _ConversationDropTargetState
    extends ConsumerState<ConversationDropTarget> {
  bool _over = false;

  ComposerDraftProvider get _draft =>
      composerDraftProvider(widget.url, widget.channelId, widget.rootId);

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) return widget.child;
    final uploads =
        ref.watch(featuresProvider(widget.url)).value?.fileUploads ?? true;
    final editing = ref.watch(_draft.select((v) => v.editing != null));
    // A route on top (a dialog, the gallery) must not take the drop.
    final current = ModalRoute.isCurrentOf(context) ?? true;
    final enabled = uploads && !editing && current;
    final scheme = Theme.of(context).colorScheme;
    return DropTarget(
      enable: enabled,
      onDragEntered: (_) => setState(() => _over = true),
      onDragExited: (_) => setState(() => _over = false),
      onDragDone: (details) {
        setState(() => _over = false);
        dropFiles(details.files);
      },
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _over && enabled ? 1 : 0,
                duration: const Duration(milliseconds: 120),
                child: ColoredBox(
                  color: scheme.scrim.withValues(alpha: 0.45),
                  child: Center(
                    child: Card(
                      color: scheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.lg),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.upload_file,
                              color: scheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: Spacing.md),
                            Flexible(
                              child: Text(
                                'Drop to attach to ${widget.target}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: scheme.onPrimaryContainer,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// What a drop does; also what the widget test calls.
  Future<void> dropFiles(List<XFile> dropped) async {
    final messenger = ScaffoldMessenger.of(context);
    final files = dropped.where((f) => f is! DropItemDirectory).toList();
    final draft = ref.read(_draft.notifier);
    final skipped = await attachDropped(
      files,
      have: ref.read(_draft).attachments.length,
      attach: ({required open, required name, required size, path}) =>
          draft.attach(open: open, name: name, size: size, path: path),
    );
    if (!mounted) return;
    if (skipped > 0) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('A message can carry $maxAttachments files at most.'),
        ),
      );
    } else if (files.length < dropped.length) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Folders can't be attached.")),
      );
    }
  }
}
