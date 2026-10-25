import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/markdown/parse_post.dart';
import 'package:matterleast/markdown/post_doc.dart';

// The expected trees come from Mattermost's own parser
// (tool/markdown-fixtures/generate.sh); each message must parse to the same
// node types and literals here.
void main() {
  final corpus = (jsonDecode(
    File('test/fixtures/markdown/corpus.json').readAsStringSync(),
  ) as List).cast<Map<String, Object?>>();
  final expected = jsonDecode(
    File('test/fixtures/markdown/expected.json').readAsStringSync(),
  ) as Map<String, Object?>;
  const options = ParseOptions(latexInline: true);

  for (final entry in corpus) {
    final name = entry['name']! as String;
    test(name, () {
      final doc = parsePost(entry['text']! as String, options);
      expect(
        jsonEncode(simplify(doc)),
        jsonEncode(expected[name]),
        reason: entry['text'] as String,
      );
    });
  }
}

List<Object?> simplify(PostDoc doc) => switch (doc) {
  ParsedPost(:final blocks) => [for (final b in blocks) _block(b)],
  _ => ['$doc'],
};

Object? _block(Block block) => switch (block) {
  Paragraph(:final inlines) => {'p': _inlines(inlines)},
  Heading(:final level, :final inlines) => {'h': level, 'c': _inlines(inlines)},
  CodeBlock(:final language, :final code) => {'code': language, 'text': code},
  MathBlock(:final tex) => {'code': 'latex', 'text': tex},
  Quote(:final blocks) => {
    'quote': [for (final b in blocks) _block(b)],
  },
  ListBlock(:final items, :final ordered, :final start) => {
    'list': ordered ? 'ol' : 'ul',
    'start': start,
    'items': [
      for (final item in items)
        {
          'checked': item.checked,
          'blocks': [for (final b in item.blocks) _block(b)],
        },
    ],
  },
  Rule() => {'hr': true},
  TableBlock(:final rows) => {
    'table': [
      for (final row in rows) [for (final cell in row) _inlines(cell)],
    ],
  },
};

List<Object?> _inlines(List<Inline> inlines) => [
  for (final i in inlines)
    switch (i) {
      TextPart(:final text, :final marks, :final link) => [
        't',
        text,
        marks,
        link,
      ],
      CodePart(:final text, :final marks, :final link) => [
        'code',
        text,
        marks,
        link,
      ],
      MentionPart(:final name) => ['mention', name],
      ChannelPart(:final name) => ['channel', name],
      EmojiPart(:final name) => ['emoji', name],
      HashtagPart(:final tag) => ['hashtag', tag],
      MathPart(:final tex) => ['math', tex],
      ImagePart(:final url, :final width, :final height) => [
        'img',
        url,
        width,
        height,
      ],
      BreakPart() => ['br'],
    },
];
