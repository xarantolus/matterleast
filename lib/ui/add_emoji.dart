import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/emoji_providers.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/domain/emoji_rules.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/tokens.dart';

/// An image the user chose for a new emoji.
typedef EmojiImage = ({String fileName, Uint8List bytes, int size});

/// Lets the user pick an image file; null when they backed out.
typedef EmojiImagePicker = Future<EmojiImage?> Function();

Future<EmojiImage?> pickEmojiImage() async {
  final picked = (await FilePicker.pickFiles(type: FileType.image))
      .singleOrNull;
  if (picked == null) return null;
  final size = await picked.xFile.length();
  // Larger files are refused from their size alone, without reading them.
  final bytes = size > maxEmojiImageBytes
      ? Uint8List(0)
      : await picked.xFile.readAsBytes();
  return (fileName: picked.name, bytes: bytes, size: size);
}

/// Asks for an image and a name and adds the custom emoji; completes with
/// its name, or null when nothing was added.
Future<String?> showAddEmoji(
  BuildContext context,
  String url, {
  EmojiImagePicker pick = pickEmojiImage,
}) => showAppSheet<String>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => AddEmojiForm(url: url, pick: pick),
);

class AddEmojiForm extends ConsumerStatefulWidget {
  const AddEmojiForm({required this.url, required this.pick, super.key});

  final String url;
  final EmojiImagePicker pick;

  @override
  ConsumerState<AddEmojiForm> createState() => _AddEmojiFormState();
}

class _AddEmojiFormState extends ConsumerState<AddEmojiForm> {
  final _name = TextEditingController();
  EmojiImage? _image;
  String? _failure;
  var _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String? _imageProblem() => switch (_image) {
    final image? => emojiImageProblem(
      fileName: image.fileName,
      bytes: image.size,
    ),
    null => null,
  };

  String? _nameProblem(Set<String> custom) => emojiNameProblem(
    _name.text,
    taken: (n) => isKnownEmoji(n) || custom.contains(n),
  );

  Future<void> _choose() async {
    final image = await widget.pick();
    if (image == null || !mounted) return;
    setState(() {
      _image = image;
      _failure = null;
      if (_name.text.isEmpty) {
        _name.text = suggestedEmojiName(image.fileName);
      }
    });
  }

  Future<void> _add() async {
    final image = _image;
    if (image == null) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    final name = _name.text;
    try {
      final actions = await ref.read(emojiActionsOnProvider(widget.url).future);
      await actions.add(
        name: name,
        bytes: image.bytes,
        fileName: image.fileName,
      );
      if (mounted) Navigator.of(context).pop(name);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _failure = requestProblemText(e, hostOf(widget.url));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final custom =
        ref.watch(customEmojiProvider(widget.url)).value?.keys.toSet() ??
        const <String>{};
    final image = _image;
    final imageProblem = _imageProblem();
    final nameProblem = _nameProblem(custom);
    final shownNameProblem = _name.text.isEmpty ? null : nameProblem;
    final ready =
        image != null && imageProblem == null && nameProblem == null && !_busy;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        Spacing.lg,
        0,
        Spacing.lg,
        Spacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add custom emoji', style: text.titleLarge),
          const SizedBox(height: Spacing.lg),
          Center(
            child: Tooltip(
              message: image == null ? 'Choose an image' : 'Choose another',
              child: InkWell(
                mouseCursor: clickCursor,
                borderRadius: BorderRadius.circular(Spacing.md),
                onTap: _busy ? null : _choose,
                child: SizedBox.square(
                  dimension: 96,
                  child: image == null || imageProblem != null
                      ? Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color: colors.onSurfaceVariant,
                        )
                      : Image.memory(
                          image.bytes,
                          cacheWidth: 192,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.broken_image_outlined, size: 40),
                        ),
                ),
              ),
            ),
          ),
          if (imageProblem != null)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: Text(
                imageProblem,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: colors.error),
              ),
            )
          else if (image == null)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: Text(
                'PNG, JPEG or GIF, up to ${maxEmojiImageBytes ~/ 1024} KB.',
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: context.tokens.muted),
              ),
            ),
          const SizedBox(height: Spacing.lg),
          TextField(
            controller: _name,
            enabled: !_busy,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: (_) => setState(() => _failure = null),
            onSubmitted: (_) {
              if (ready) _add();
            },
            decoration: InputDecoration(
              labelText: 'Name',
              prefixText: ':',
              suffixText: ':',
              errorText: shownNameProblem,
            ),
          ),
          if (_failure != null)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.md),
              child: Text(
                _failure!,
                style: text.bodyMedium?.copyWith(color: colors.error),
              ),
            ),
          const SizedBox(height: Spacing.lg),
          if (_busy) const LinearProgressIndicator(),
          if (_busy) const SizedBox(height: Spacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: ready ? _add : null,
              child: const Text('Add emoji'),
            ),
          ),
        ],
      ),
    );
  }
}
