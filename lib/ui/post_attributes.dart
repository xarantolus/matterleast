import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/app/post_attribute_providers.dart';
import 'package:matterleast/domain/post_attributes.dart';
import 'package:matterleast/domain/post_details.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/profile_attributes.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/try_action.dart';

/// Attribute values as the server has them, by field id, with the names
/// of the people they point at.
List<ShownAttribute> _shown(
  WidgetRef ref,
  String url,
  PostDetails details,
  List<PostAttributeField> fields,
) {
  final ids = {
    for (final f in fields)
      if (f.field.kind == AttributeKind.user)
        ...?details.attributes[f.field.id],
  }.toList()..sort();
  final names = ids.isEmpty
      ? null
      : ref.watch(attributeUserNamesProvider(url, ids.join(','))).value;
  return shownPostAttributes(
    fields,
    details.attributes,
    userName: (id) => names?[id] ?? id,
  );
}

/// The attributes under a message: two chips, then a "+N" badge; a tap
/// opens all of them.
class PostAttributeChips extends ConsumerWidget {
  const PostAttributeChips({
    required this.url,
    required this.post,
    required this.details,
    super.key,
  });

  final String url;
  final PostItem post;
  final PostDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (details.attributes.isEmpty && !details.attributesUnavailable) {
      return const SizedBox.shrink();
    }
    final text = Theme.of(context).textTheme;
    if (details.attributesUnavailable && details.attributes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: Spacing.xs),
        child: Text(
          'Attributes unavailable',
          style: text.bodySmall?.copyWith(color: context.tokens.muted),
        ),
      );
    }
    final fields =
        ref.watch(postAttributeSetupProvider(url, post.id)).value?.fields ??
        const <PostAttributeField>[];
    final shown = _shown(ref, url, details, fields);
    if (shown.isEmpty) return const SizedBox.shrink();
    final more = shown.length - visiblePostAttributes;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: Semantics(
        button: true,
        child: InkWell(
          mouseCursor: clickCursor,
          onTap: () => showPostAttributes(context, url, post),
          child: Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            children: [
              for (final a in shown.take(visiblePostAttributes))
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text('${a.name}: ${a.text}'),
                ),
              if (more > 0)
                Tooltip(
                  message: '$more more attributes',
                  child: Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text('+$more'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Every attribute of [post], each with its value; the ones the user may
/// set open an editor.
Future<void> showPostAttributes(
  BuildContext context,
  String url,
  PostItem post,
) => showAppSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _PostAttributesSheet(url: url, post: post),
);

class _PostAttributesSheet extends ConsumerStatefulWidget {
  const _PostAttributesSheet({required this.url, required this.post});

  final String url;
  final PostItem post;

  @override
  ConsumerState<_PostAttributesSheet> createState() => _SheetState();
}

class _SheetState extends ConsumerState<_PostAttributesSheet> {
  final _set = <String, List<String>>{};

  Future<void> _edit(PostAttributeField f, List<String> now) async {
    final field = f.field;
    final value = await _ask(context, field, now);
    if (value == null || !mounted) return;
    final ok = await tryAction(context, hostOf(widget.url), () async {
      final actions = await ref.read(postActionsProvider(widget.url).future);
      await actions.setAttribute(widget.post.id, field.id, value);
    }, failure: "Couldn't set ${field.name}.");
    if (ok && mounted) {
      setState(() => _set[field.id] = attributeValues(value));
    }
  }

  @override
  Widget build(BuildContext context) {
    final setup = ref.watch(
      postAttributeSetupProvider(widget.url, widget.post.id),
    );
    final details = detailsOf(widget.post);
    final values = {...details.attributes, ..._set};
    final text = Theme.of(context).textTheme;
    final fields = setup.value?.fields ?? const <PostAttributeField>[];
    final names = ref.watch(
      attributeUserNamesProvider(
        widget.url,
        [
          for (final f in fields)
            if (f.field.kind == AttributeKind.user) ...?values[f.field.id],
        ].join(','),
      ),
    );
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Text('Post attributes', style: text.titleMedium),
          ),
          if (setup.isLoading)
            const LinearProgressIndicator()
          else if (fields.isEmpty)
            const Padding(
              padding: EdgeInsets.all(Spacing.lg),
              child: Text('This channel has no post attributes.'),
            ),
          for (final f in fields)
            _row(f, values[f.field.id] ?? const [], setup.value!, names.value),
        ],
      ),
    );
  }

  Widget _row(
    PostAttributeField f,
    List<String> now,
    PostAttributeSetup setup,
    Map<String, String>? names,
  ) {
    final can = canSetPostAttribute(
      f,
      author: setup.me == widget.post.userId,
      systemAdmin: setup.systemAdmin,
    );
    final shown = attributeText(
      f.field,
      now,
      userName: (id) => names?[id] ?? id,
    );
    return ListTile(
      mouseCursor: can ? clickCursor : null,
      title: Text(f.field.name),
      subtitle: Text(shown.isEmpty ? 'Not set' : shown),
      trailing: can ? const Icon(Icons.edit_outlined) : null,
      onTap: can ? () => _edit(f, now) : null,
    );
  }
}

Future<Object?> _ask(
  BuildContext context,
  AttributeField field,
  List<String> now,
) => switch (field.kind) {
  AttributeKind.select => _pickOne(context, field, now),
  AttributeKind.multiselect => _pickMany(context, field, now),
  _ => _typeText(context, field, now.join(', ')),
};

Future<String?> _typeText(
  BuildContext context,
  AttributeField field,
  String now,
) => showDialog<String>(
  context: context,
  builder: (_) => _TextDialog(field: field, now: now),
);

class _TextDialog extends StatefulWidget {
  const _TextDialog({required this.field, required this.now});

  final AttributeField field;
  final String now;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  late final _controller = TextEditingController(text: widget.now);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.field.name),
    content: TextField(
      controller: _controller,
      autofocus: true,
      decoration: InputDecoration(
        hintText: widget.field.kind == AttributeKind.date ? 'YYYY-MM-DD' : null,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, _controller.text.trim()),
        child: const Text('Save'),
      ),
    ],
  );
}

/// The chosen option's id; an empty string clears it; null when cancelled.
Future<String?> _pickOne(
  BuildContext context,
  AttributeField field,
  List<String> now,
) => showDialog<String>(
  context: context,
  builder: (context) => SimpleDialog(
    title: Text(field.name),
    children: [
      for (final MapEntry(:key, :value) in field.options.entries)
        ListTile(
          mouseCursor: clickCursor,
          title: Text(value),
          selected: now.contains(key),
          onTap: () => Navigator.pop(context, key),
        ),
      ListTile(
        mouseCursor: clickCursor,
        title: const Text('Clear'),
        onTap: () => Navigator.pop(context, ''),
      ),
    ],
  ),
);

/// The chosen option ids; null when cancelled.
Future<List<String>?> _pickMany(
  BuildContext context,
  AttributeField field,
  List<String> now,
) => showDialog<List<String>>(
  context: context,
  builder: (_) => _ManyDialog(field: field, now: now),
);

class _ManyDialog extends StatefulWidget {
  const _ManyDialog({required this.field, required this.now});

  final AttributeField field;
  final List<String> now;

  @override
  State<_ManyDialog> createState() => _ManyDialogState();
}

class _ManyDialogState extends State<_ManyDialog> {
  late final _chosen = {...widget.now};

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.field.name),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final MapEntry(:key, :value) in widget.field.options.entries)
            CheckboxListTile(
              mouseCursor: clickCursor,
              title: Text(value),
              value: _chosen.contains(key),
              onChanged: (on) =>
                  setState(() => on! ? _chosen.add(key) : _chosen.remove(key)),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, _chosen.toList()),
        child: const Text('Save'),
      ),
    ],
  );
}
