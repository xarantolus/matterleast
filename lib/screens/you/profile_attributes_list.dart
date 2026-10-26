import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/extras_providers.dart';
import 'package:matterleast/domain/profile_attributes.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:url_launcher/url_launcher.dart';

/// The custom profile attributes the server defines, with [userId]'s
/// values; nothing when the server has none. Web addresses, mail and phone
/// numbers open on tap.
class ProfileAttributesList extends ConsumerWidget {
  const ProfileAttributesList({
    required this.url,
    required this.userId,
    super.key,
  });

  final String url;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(attributesRefreshProvider(url, userId), (_, _) {});
    final shown =
        ref.watch(profileAttributesProvider(url, userId)).value ?? const [];
    final tokens = context.tokens;
    final body = Theme.of(context).textTheme.bodyLarge;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final a in shown)
          if (attributeLink(a.kind, a.text) case final link)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(a.name.toUpperCase(), style: tokens.smallCaps),
              subtitle: Text(
                a.text.isEmpty ? 'Not set' : a.text,
                style: link != null
                    ? body?.copyWith(
                        color: tokens.accent,
                        decoration: TextDecoration.underline,
                        decorationColor: tokens.accent,
                      )
                    : a.text.isEmpty
                    ? body?.copyWith(color: tokens.muted)
                    : body,
              ),
              onTap: link == null
                  ? null
                  : () => unawaited(
                      launchUrl(link, mode: LaunchMode.externalApplication),
                    ),
            ),
      ],
    );
  }
}

/// Inputs for the user's own custom profile attributes. [values] are the
/// stored ones, [edits] what the user changed; [onChanged] reports a
/// field's new values.
class AttributeEditors extends StatelessWidget {
  const AttributeEditors({
    required this.fields,
    required this.values,
    required this.edits,
    required this.onChanged,
    required this.enabled,
    super.key,
  });

  final List<AttributeField> fields;
  final Map<String, List<String>> values;
  final Map<String, List<String>> edits;
  final void Function(AttributeField field, List<String> values) onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final f in fields)
        if (f.visibility != AttributeVisibility.hidden)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.md),
            child: _editor(context, f, edits[f.id] ?? values[f.id] ?? const []),
          ),
    ],
  );

  Widget _editor(BuildContext context, AttributeField f, List<String> current) {
    final on = enabled && f.editable;
    final decoration = InputDecoration(
      labelText: f.name,
      border: const OutlineInputBorder(),
      helperText: f.editable ? null : 'Set by your organisation',
      suffixIcon: f.editable ? null : const Icon(Icons.lock_outline),
    );
    switch (f.kind) {
      case AttributeKind.select:
        return DropdownButtonFormField<String>(
          key: ValueKey((f.id, values[f.id]?.join(','))),
          initialValue: f.options.containsKey(current.firstOrNull)
              ? current.first
              : '',
          decoration: decoration,
          isExpanded: true,
          items: [
            const DropdownMenuItem(value: '', child: Text('None')),
            for (final o in f.options.entries)
              DropdownMenuItem(value: o.key, child: Text(o.value)),
          ],
          onChanged: on
              ? (v) => onChanged(f, [if (v != null && v.isNotEmpty) v])
              : null,
        );
      case AttributeKind.multiselect:
        return InputDecorator(
          decoration: decoration,
          child: Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.xs,
            children: [
              for (final o in f.options.entries)
                FilterChip(
                  label: Text(o.value),
                  selected: current.contains(o.key),
                  onSelected: on
                      ? (selected) => onChanged(f, [
                          for (final id in f.options.keys)
                            if (id == o.key ? selected : current.contains(id))
                              id,
                        ])
                      : null,
                ),
            ],
          ),
        );
      case AttributeKind.date:
        final text = current.firstOrNull ?? '';
        return InputDecorator(
          decoration: decoration.copyWith(
            suffixIcon: f.editable
                ? IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.clear),
                    onPressed: on && text.isNotEmpty
                        ? () => onChanged(f, const [])
                        : null,
                  )
                : decoration.suffixIcon,
          ),
          child: InkWell(
            onTap: on
                ? () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(text) ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2200),
                    );
                    if (picked != null) {
                      onChanged(f, [attributeDate(picked)]);
                    }
                  }
                : null,
            child: Text(text.isEmpty ? 'Not set' : text),
          ),
        );
      default:
        return _TextEditor(
          // Stored values that arrive or change start the field afresh;
          // typing only changes the edits, so it never resets itself.
          key: ValueKey((f.id, values[f.id]?.join(','))),
          initial: current.firstOrNull ?? '',
          decoration: decoration,
          kind: f.kind,
          enabled: on,
          onChanged: (text) =>
              onChanged(f, [if (text.trim().isNotEmpty) text.trim()]),
        );
    }
  }
}

class _TextEditor extends StatefulWidget {
  const _TextEditor({
    required this.initial,
    required this.decoration,
    required this.kind,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final String initial;
  final InputDecoration decoration;
  final AttributeKind kind;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  State<_TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<_TextEditor> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    enabled: widget.enabled,
    decoration: widget.decoration,
    keyboardType: switch (widget.kind) {
      AttributeKind.email => TextInputType.emailAddress,
      AttributeKind.url => TextInputType.url,
      AttributeKind.phone => TextInputType.phone,
      _ => TextInputType.text,
    },
    onChanged: widget.onChanged,
  );
}
