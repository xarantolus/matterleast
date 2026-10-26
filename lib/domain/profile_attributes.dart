/// The kinds of custom profile attribute; [unknown] for types this app
/// doesn't know, which are shown as text and never edited.
enum AttributeKind {
  text,
  email,
  url,
  phone,
  select,
  multiselect,
  date,
  user,
  unknown,
}

/// A custom profile attribute field the server defines for everyone.
class AttributeField {
  const AttributeField({
    required this.id,
    required this.name,
    required this.kind,
    this.options = const {},
    this.visibility = AttributeVisibility.whenSet,
    this.sortOrder,
    this.editable = true,
  });

  final String id;
  final String name;
  final AttributeKind kind;

  /// Select and multiselect choices: option id to its name.
  final Map<String, String> options;
  final AttributeVisibility visibility;
  final num? sortOrder;

  /// False when only an admin or a directory sync sets the value.
  final bool editable;

  @override
  bool operator ==(Object other) =>
      other is AttributeField &&
      other.id == id &&
      other.name == name &&
      other.kind == kind &&
      _sameMap(other.options, options) &&
      other.visibility == visibility &&
      other.sortOrder == sortOrder &&
      other.editable == editable;

  @override
  int get hashCode =>
      Object.hash(id, name, kind, visibility, sortOrder, editable);
}

enum AttributeVisibility { always, whenSet, hidden }

/// One attribute as a profile shows it.
typedef ShownAttribute = ({
  String fieldId,
  String name,
  AttributeKind kind,

  /// Empty when the field is always shown but has no value.
  String text,
});

/// Pure: a field from the server's `type` and `attrs`. Lenient: anything
/// unexpected falls back to plain text, shown only when set.
AttributeField attributeField({
  required String id,
  required String name,
  required String? type,
  required Map<String, Object?> attrs,
}) {
  final valueType = attrs['value_type'];
  final kind = switch (type) {
    'text' => switch (valueType) {
      'email' => AttributeKind.email,
      'url' => AttributeKind.url,
      'phone' => AttributeKind.phone,
      _ => AttributeKind.text,
    },
    'select' => AttributeKind.select,
    'multiselect' => AttributeKind.multiselect,
    'date' => AttributeKind.date,
    'user' || 'multiuser' => AttributeKind.user,
    _ => AttributeKind.unknown,
  };
  final rawOptions = attrs['options'];
  final options = <String, String>{
    if (rawOptions is List)
      for (final o in rawOptions)
        if (o is Map && o['id'] is String && o['name'] is String)
          o['id'] as String: o['name'] as String,
  };
  bool set(Object? v) => v is String && v.isNotEmpty || v == true;
  final linked = set(attrs['ldap']) || set(attrs['saml']);
  return AttributeField(
    id: id,
    name: name,
    kind: kind,
    options: options,
    visibility: switch (attrs['visibility']) {
      'always' => AttributeVisibility.always,
      'hidden' => AttributeVisibility.hidden,
      _ => AttributeVisibility.whenSet,
    },
    sortOrder: attrs['sort_order'] is num ? attrs['sort_order'] as num : null,
    editable:
        !linked &&
        attrs['managed'] != 'admin' &&
        attrs['protected'] != true &&
        const {
          AttributeKind.text,
          AttributeKind.email,
          AttributeKind.url,
          AttributeKind.phone,
          AttributeKind.select,
          AttributeKind.multiselect,
          AttributeKind.date,
        }.contains(kind),
  );
}

/// Pure: the values the server sent ([raw]: a string, or a list of strings
/// for multiselect and multiuser) as a list of strings.
List<String> attributeValues(Object? raw) => switch (raw) {
  final String s when s.isNotEmpty => [s],
  final List<Object?> l => [
    for (final v in l)
      if (v is String && v.isNotEmpty) v,
  ],
  _ => const [],
};

/// Pure: the fields to show on a profile, in the server's order (then by
/// name), with their values as text. [userName] names a user id for user
/// fields.
List<ShownAttribute> shownAttributes(
  List<AttributeField> fields,
  Map<String, List<String>> values, {
  String Function(String userId)? userName,
}) {
  final sorted = [...fields]..sort(compareFields);
  return [
    for (final f in sorted)
      if (f.visibility != AttributeVisibility.hidden)
        if (attributeText(f, values[f.id] ?? const [], userName: userName)
            case final text
            when text.isNotEmpty || f.visibility == AttributeVisibility.always)
          (fieldId: f.id, name: f.name, kind: f.kind, text: text),
  ];
}

/// Pure: fields in the server's order; fields without one go last, by name.
int compareFields(AttributeField a, AttributeField b) {
  final byOrder = (a.sortOrder ?? double.maxFinite).compareTo(
    b.sortOrder ?? double.maxFinite,
  );
  return byOrder != 0 ? byOrder : a.name.compareTo(b.name);
}

/// Pure: a value as text: option names for selects, the date as stored
/// (`YYYY-MM-DD`), user names for user fields.
String attributeText(
  AttributeField field,
  List<String> values, {
  String Function(String userId)? userName,
}) => switch (field.kind) {
  AttributeKind.select || AttributeKind.multiselect =>
    values.map((v) => field.options[v] ?? v).join(', '),
  AttributeKind.user => values.map((v) => userName?.call(v) ?? v).join(', '),
  _ => values.join(', '),
};

/// Pure: where tapping a value goes: a web page, a mail or a call; null
/// when the value isn't a link.
Uri? attributeLink(AttributeKind kind, String text) {
  final value = text.trim();
  if (value.isEmpty) return null;
  switch (kind) {
    case AttributeKind.url:
      final withScheme =
          RegExp(r'^https?://', caseSensitive: false).hasMatch(value)
          ? value
          : 'https://$value';
      final uri = Uri.tryParse(withScheme);
      return uri != null && uri.host.isNotEmpty ? uri : null;
    case AttributeKind.email:
      return value.contains('@') && !value.contains(' ')
          ? Uri(scheme: 'mailto', path: value)
          : null;
    case AttributeKind.phone:
      final digits = value.replaceAll(RegExp(r'[^\d+]'), '');
      return digits.length >= 3 ? Uri(scheme: 'tel', path: digits) : null;
    default:
      return null;
  }
}

/// Pure: what to send for [field] given what the user entered: a list for
/// multiselect, else one string (empty clears it).
Object attributeServerValue(AttributeField field, List<String> values) =>
    field.kind == AttributeKind.multiselect
    ? values
    : (values.firstOrNull ?? '');

/// Pure: a calendar date as date attributes store it, `YYYY-MM-DD`.
String attributeDate(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

bool _sameMap(Map<String, String> a, Map<String, String> b) {
  if (a.length != b.length) return false;
  for (final e in a.entries) {
    if (b[e.key] != e.value) return false;
  }
  return true;
}
