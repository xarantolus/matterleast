import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/post_attributes.dart';
import 'package:matterleast/domain/profile_attributes.dart';
import 'package:matterleast/ui/tokens.dart';

/// The longest a text attribute may be.
const attributeTextLimit = 64;

/// Pure: the fields a new channel asks the user for: the required ones the
/// user may set.
List<PostAttributeField> askedAttributes(
  List<PostAttributeField> fields, {
  required bool systemAdmin,
}) => [
  for (final f in fields)
    if (f.required &&
        canSetPostAttribute(f, author: true, systemAdmin: systemAdmin))
      f,
];

/// Pure: whether every asked field has a value.
bool attributesFilled(
  List<PostAttributeField> asked,
  Map<String, List<String>> values,
) => asked.every(
  (f) => (values[f.field.id] ?? const []).any((v) => v.trim().isNotEmpty),
);

/// Pure: what the create request carries for [asked]: a string, or a list
/// of strings for several choices.
Map<String, Object> attributesToSend(
  List<PostAttributeField> asked,
  Map<String, List<String>> values,
) => {
  for (final f in asked)
    if (values[f.field.id] case final v? when v.isNotEmpty)
      f.field.id: f.field.kind == AttributeKind.multiselect
          ? v
          : v.first.trim(),
};

/// One input for each of [fields]; [onChanged] gets a field's id and the
/// values it now has.
class ChannelAttributeInputs extends StatelessWidget {
  const ChannelAttributeInputs({
    required this.fields,
    required this.values,
    required this.onChanged,
    required this.enabled,
    super.key,
  });

  final List<PostAttributeField> fields;
  final Map<String, List<String>> values;
  final void Function(String fieldId, List<String> value) onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final f in fields) ...[
        switch (f.field.kind) {
          AttributeKind.select => DropdownMenu<String>(
            width: double.infinity,
            enabled: enabled,
            label: Text(f.field.name),
            initialSelection: values[f.field.id]?.firstOrNull,
            dropdownMenuEntries: [
              for (final MapEntry(:key, :value) in f.field.options.entries)
                DropdownMenuEntry(value: key, label: value),
            ],
            onSelected: (v) => onChanged(f.field.id, [?v]),
          ),
          AttributeKind.multiselect => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f.field.name, style: Theme.of(context).textTheme.bodyMedium),
              Wrap(
                spacing: Spacing.sm,
                children: [
                  for (final MapEntry(:key, :value) in f.field.options.entries)
                    FilterChip(
                      label: Text(value),
                      selected: _chosen(f).contains(key),
                      onSelected: enabled
                          ? (on) {
                              final next = {..._chosen(f)};
                              on ? next.add(key) : next.remove(key);
                              onChanged(f.field.id, next.toList());
                            }
                          : null,
                    ),
                ],
              ),
            ],
          ),
          _ => TextField(
            enabled: enabled,
            maxLength: attributeTextLimit,
            onChanged: (v) => onChanged(f.field.id, [v]),
            decoration: InputDecoration(
              labelText: f.field.name,
              border: const OutlineInputBorder(),
            ),
          ),
        },
        const SizedBox(height: Spacing.md),
      ],
    ],
  );

  Set<String> _chosen(PostAttributeField f) => {...?values[f.field.id]};
}
