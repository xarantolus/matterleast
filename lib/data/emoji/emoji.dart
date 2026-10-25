import 'emoji_table.g.dart';

/// Name suffixes for skin tones 1 (light, U+1F3FB) to 5 (dark, U+1F3FF).
const skinToneSuffixes = [
  '_light_skin_tone',
  '_medium_light_skin_tone',
  '_medium_skin_tone',
  '_medium_dark_skin_tone',
  '_dark_skin_tone',
];

/// The `emoji_skintone` preference value for [tone], as the official apps
/// write it.
String skinToneCode(int tone) => tone >= 1 && tone <= skinToneSuffixes.length
    ? (0x1F3FA + tone).toRadixString(16).toUpperCase()
    : 'default';

/// The tone a stored `emoji_skintone` [code] stands for, 0 for none.
int skinToneOf(String? code) {
  final value = int.tryParse(code ?? '', radix: 16);
  if (value == null) return 0;
  final tone = value - 0x1F3FA;
  return tone >= 1 && tone <= skinToneSuffixes.length ? tone : 0;
}

final _toneSuffix = RegExp(
  r'(_(light|medium_light|medium|medium_dark|dark)_skin_tone)$',
);

class _Emoji {
  const _Emoji(this.name, this.unicode, this.category);

  final String name;
  final String unicode;
  final String category;
}

class _Table {
  _Table(this.byName, this.baseNames);

  factory _Table.parse(String rows) {
    final byName = <String, _Emoji>{};
    final baseNames = <String>[];
    var parentNames = const <String>[];
    var parentCategory = '';
    for (final line in rows.split('\n')) {
      if (line.isEmpty) continue;
      final fields = line.split(' ');
      final List<String> names;
      final String category;
      if (line.startsWith('~')) {
        final suffix = fields[0]
            .substring(1)
            .split('')
            .map((tone) => skinToneSuffixes[int.parse(tone) - 1])
            .join();
        names = fields.length > 2
            ? fields[2].split(',')
            : [for (final name in parentNames) '$name$suffix'];
        category = parentCategory;
      } else {
        names = fields[2].split(',');
        category = emojiCategories[int.parse(fields[0])];
        parentNames = names;
        parentCategory = category;
        baseNames.add(names.first);
      }
      final emoji = _Emoji(names.first, _decode(fields[1]), category);
      for (final name in names) {
        byName[name] = emoji;
      }
    }
    return _Table(byName, baseNames);
  }

  final Map<String, _Emoji> byName;
  final List<String> baseNames;
}

String _decode(String codePoints) => String.fromCharCodes(
  codePoints.split('-').map((hex) => int.parse(hex, radix: 16)),
);

// Parsed on first use.
final _table = _Table.parse(emojiRows);

_Emoji? _lookup(String name) => _table.byName[name.toLowerCase()];

/// The emoji for a short name or alias, with or without a skin-tone suffix.
String? unicodeForName(String name) => _lookup(name)?.unicode;

bool isKnownEmoji(String name) => _lookup(name) != null;

/// `':Tada: '` becomes `tada`.
String normalizeShortcode(String raw) {
  var name = raw.trim();
  if (name.startsWith(':')) name = name.substring(1);
  if (name.endsWith(':')) name = name.substring(0, name.length - 1);
  return name.trim().toLowerCase();
}

/// Strips one or two skin-tone suffixes: `thumbsup_dark_skin_tone` becomes
/// `thumbsup`.
String baseName(String name) {
  var base = name.toLowerCase();
  for (var i = 0; i < 2; i++) {
    base = base.replaceFirst(_toneSuffix, '');
  }
  return base;
}

/// The name of [name] in skin tone [tone], 1 (light) to 5 (dark), or its base
/// name for tone 0. Emoji without skin-tone variants keep their name, and so do
/// emoji toned for two people, as in Mattermost's own picker.
String withSkinTone(String name, int tone) {
  RangeError.checkValueInInterval(tone, 0, skinToneSuffixes.length, 'tone');
  final lower = name.toLowerCase();
  final base = baseName(lower);
  if (base != lower.replaceFirst(_toneSuffix, '')) return name;
  if (tone == 0) return base;
  final suffix = skinToneSuffixes[tone - 1];
  for (final candidate in [base, canonicalName(base)]) {
    if (isKnownEmoji('$candidate$suffix')) return '$candidate$suffix';
  }
  return name;
}

String? categoryOf(String name) => _lookup(name)?.category;

/// Primary names without skin tones, in Mattermost's order.
List<String> namesInCategory(String category) => [
  for (final name in _table.baseNames)
    if (_table.byName[name]!.category == category) name,
];

/// The primary short name for an alias (`thumbsup` becomes `+1`); unknown
/// names are returned as they are.
String canonicalName(String nameOrAlias) =>
    _lookup(nameOrAlias)?.name ?? nameOrAlias;

/// The emoji name for a text emoticon such as `:)`, as Mattermost's emoji
/// data lists them.
String? nameForEmoticon(String text) => emoticonNames[text];

/// Every short name and alias of the system emoji, without skin tones.
Iterable<String> systemEmojiNames() =>
    _table.byName.keys.where((name) => !_toneSuffix.hasMatch(name));
