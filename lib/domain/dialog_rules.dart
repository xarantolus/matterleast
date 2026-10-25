import 'package:matterleast/api/websocket/dialog.dart';

/// Pure: what is wrong with [values] (by element name) for [form], as the
/// official client checks before submitting. Empty when it can be sent.
Map<String, String> dialogErrors(DialogForm form, Map<String, Object?> values) {
  final errors = <String, String>{};
  for (final element in form.elements) {
    final error = _elementError(element, values[element.name]);
    if (error != null) errors[element.name] = error;
  }
  return errors;
}

String? _elementError(DialogElement element, Object? value) {
  final empty =
      value == null || value == false || (value is String && value.isEmpty);
  if (empty) {
    return element.optional ?? false ? null : 'This field is required.';
  }
  if (value is! String) return null;
  switch (element.type) {
    case DialogElementType.text || DialogElementType.textarea:
      if (element.minLength case final min? when value.length < min) {
        return 'Must be at least $min characters.';
      }
      if (element.maxLength case final max?
          when max > 0 && value.length > max) {
        return 'Must be at most $max characters.';
      }
      return switch (element.subtype) {
        'email' when !value.contains('@') => 'Must be a valid email address.',
        'number' when num.tryParse(value) == null => 'Must be a number.',
        'url' when !_isWebUrl(value) => 'Must be a valid URL.',
        _ => null,
      };
    case DialogElementType.select || DialogElementType.radio:
      final listed = element.options.any((o) => o.value == value);
      final fromServer = element.dataSource?.isNotEmpty ?? false;
      return listed || fromServer ? null : 'Pick one of the options.';
    case DialogElementType.bool || DialogElementType.unknown:
      return null;
  }
}

bool _isWebUrl(String value) {
  final uri = Uri.tryParse(value);
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
}

/// Pure: [values] as the integration expects them: numbers for number
/// fields, the rest as entered.
Map<String, Object?> dialogSubmission(
  DialogForm form,
  Map<String, Object?> values,
) => {
  for (final element in form.elements)
    if (values.containsKey(element.name))
      element.name: switch ((element.subtype, values[element.name])) {
        ('number', final String text) => num.tryParse(text) ?? text,
        (_, final value) => value,
      },
};
