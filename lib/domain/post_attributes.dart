import 'package:matterleast/domain/profile_attributes.dart';

/// The property group the server keeps post attributes in.
const postAttributeGroup = 'post_attributes';

/// The group channel attributes live in.
const channelAttributeGroup = 'access_control';

/// Who may set a field's values, as the field says.
enum AttributeWriter { member, creator, admin, sysadmin, none }

/// An attribute field of posts or channels, who may set its values, and
/// whether a channel needs one when it is created.
typedef PostAttributeField = ({
  AttributeField field,
  AttributeWriter writer,
  bool required,
});

/// Pure: a field from the server's `type`, `attrs` and `permission_values`;
/// null for kinds a post shows no chip for.
PostAttributeField? postAttributeField({
  required String id,
  required String name,
  required String? type,
  required Map<String, Object?> attrs,
  required String? permissionValues,
}) {
  final shownName = switch (attrs['display_name']) {
    final String n when n.isNotEmpty => n,
    _ => name,
  };
  final field = attributeField(
    id: id,
    name: shownName,
    type: type,
    attrs: attrs,
  );
  if (field.kind == AttributeKind.unknown) return null;
  return (
    field: field,
    required: attrs['required'] == true,
    writer: switch (permissionValues) {
      'creator' => AttributeWriter.creator,
      'admin' => AttributeWriter.admin,
      'sysadmin' => AttributeWriter.sysadmin,
      'none' => AttributeWriter.none,
      _ => AttributeWriter.member,
    },
  );
}

/// Pure: whether the user may set [field]'s value on a post, by what the
/// field asks. The server decides in the end.
bool canSetPostAttribute(
  PostAttributeField field, {
  required bool author,
  required bool systemAdmin,
}) {
  if (!_editable.contains(field.field.kind)) return false;
  return switch (field.writer) {
    AttributeWriter.member => true,
    AttributeWriter.creator => author || systemAdmin,
    AttributeWriter.admin || AttributeWriter.sysadmin => systemAdmin,
    AttributeWriter.none => false,
  };
}

const _editable = {
  AttributeKind.text,
  AttributeKind.email,
  AttributeKind.url,
  AttributeKind.phone,
  AttributeKind.select,
  AttributeKind.multiselect,
  AttributeKind.date,
};

/// Pure: the attributes a post shows, in the server's order: only fields
/// with a value.
List<ShownAttribute> shownPostAttributes(
  List<PostAttributeField> fields,
  Map<String, List<String>> values, {
  String Function(String userId)? userName,
}) => [
  for (final shown in shownAttributes(
    [for (final f in fields) f.field],
    values,
    userName: userName,
  ))
    if (shown.text.isNotEmpty) shown,
];

/// Chips shown before the rest collapse into a "+N" badge.
const visiblePostAttributes = 2;
