// Turns the patched upstream spec into the one we generate from:
// millisecond timestamps become date-time (the generator emits DateTime),
// arrays default to empty, free-form objects become maps, and `required` is
// dropped from everything the server sends, so every field is nullable.
// Documentation text (descriptions, summaries, examples) is removed: the
// upstream API docs are CC BY-NC-SA and must not end up in generated code.
//
//   dart run tool/api/prepare.dart <patched.yaml> <spec.json>
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

final _timestampKey = RegExp(r'(_at|_update|_time|_timestamp)$');

var _timestamps = 0;
var _arrays = 0;
var _freeForm = 0;
var _requiredStripped = 0;
var _allOfUnwrapped = 0;

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('usage: prepare.dart <patched.yaml> <spec.json>');
    exit(2);
  }
  final spec = _plain(
    loadYaml(File(args[0]).readAsStringSync()),
  ) as Map<String, Object?>;

  final components = spec['components'] as Map<String, Object?>;
  _walk(components['schemas'], stripRequired: true);

  final paths = spec['paths'] as Map<String, Object?>;
  for (final path in paths.values) {
    if (path is! Map<String, Object?>) continue;
    for (final operation in path.values) {
      if (operation is! Map<String, Object?>) continue;
      _walk(operation['requestBody'], stripRequired: false);
      _walk(operation['parameters'], stripRequired: false);
      _walk(operation['responses'], stripRequired: true);
    }
  }

  _stripDocs(spec);

  File(
    args[1],
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(spec)}\n');
  stderr.writeln(
    'timestamps $_timestamps, arrays $_arrays, free-form maps $_freeForm, '
    'required stripped $_requiredStripped, allOf unwrapped $_allOfUnwrapped',
  );
}

const _docKeys = {
  'description',
  'summary',
  'example',
  'examples',
  'externalDocs',
  'x-codeSamples',
};

// Maps whose keys are names chosen by the spec (a field called
// `description` is not documentation).
const _nameMaps = {'properties', 'patternProperties', 'schemas', 'paths'};

void _stripDocs(Object? node, {bool namesAsKeys = false}) {
  if (node is List) {
    for (final item in node) {
      _stripDocs(item);
    }
  } else if (node is Map<String, Object?>) {
    if (!namesAsKeys) node.removeWhere((key, _) => _docKeys.contains(key));
    for (final entry in node.entries) {
      _stripDocs(entry.value, namesAsKeys: _nameMaps.contains(entry.key));
    }
  }
}

bool _isTimestamp(String key) =>
    _timestampKey.hasMatch(key) || key == 'last_activity_at';

void _walk(Object? node, {required bool stripRequired}) {
  if (node is List) {
    for (final item in node) {
      _walk(item, stripRequired: stripRequired);
    }
    return;
  }
  if (node is! Map<String, Object?>) return;

  final properties = node['properties'];
  if (properties is Map<String, Object?>) {
    for (final entry in properties.entries.toList()) {
      final property = entry.value;
      if (property is! Map<String, Object?>) continue;
      final type = property['type'];
      final allOf = property['allOf'];
      if (allOf is List && allOf.length == 1 && allOf.single is Map) {
        // swagger_parser treats every property of a schema as required once
        // one of them uses allOf; a lone $ref wrapper doesn't need it.
        properties[entry.key] = Map<String, Object?>.from(
          allOf.single as Map<String, Object?>,
        );
        _allOfUnwrapped++;
      } else if ((type == 'integer' || type == 'number') &&
          _isTimestamp(entry.key) &&
          // Marked in the overlay: a time in seconds stays a number.
          property['x-unix-seconds'] != true) {
        properties[entry.key] = {
          'type': 'string',
          'format': 'date-time',
          if (property['description'] != null)
            'description': property['description'],
          'x-unix-ms': true,
        };
        _timestamps++;
      } else if (type == 'array' && !property.containsKey('default')) {
        property['default'] = <Object?>[];
        _arrays++;
      } else if (type == 'object' &&
          !property.containsKey('properties') &&
          !property.containsKey('additionalProperties')) {
        property['additionalProperties'] = <String, Object?>{};
        _freeForm++;
      }
    }
  }
  if (stripRequired && node['required'] is List) {
    node.remove('required');
    _requiredStripped++;
  }
  for (final value in node.values.toList()) {
    _walk(value, stripRequired: stripRequired);
  }
}

/// YAML nodes to plain, mutable Dart maps and lists with string keys.
Object? _plain(Object? node) {
  if (node is YamlMap) {
    return {
      for (final entry in node.entries)
        entry.key.toString(): _plain(entry.value),
    };
  }
  if (node is YamlList) return [for (final item in node) _plain(item)];
  return node;
}
