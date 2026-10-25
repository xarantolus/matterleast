import 'package:flutter/foundation.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/markdown/parse_post.dart';
import 'package:matterleast/markdown/post_doc.dart';

typedef _Key = (String postId, int editAt, ParseOptions options);

/// Parsed messages, most recently used last. A message is parsed once per
/// version and options; rebuilding a row reuses the result.
class MarkdownCache {
  MarkdownCache({
    this.capacity = 3000,
    PostDoc Function(String, ParseOptions)? parse,
  }) : _parse = parse ?? parsePost;

  final int capacity;
  final PostDoc Function(String, ParseOptions) _parse;
  final _entries = <_Key, PostDoc>{};

  int _parsed = 0;
  int _micros = 0;

  int get length => _entries.length;

  PostDoc get(
    String postId,
    DateTime? editAt,
    String text,
    ParseOptions options,
  ) {
    final key = (postId, editAt?.millisecondsSinceEpoch ?? 0, options);
    final hit = _entries.remove(key);
    if (hit != null) {
      _entries[key] = hit;
      return hit;
    }
    final watch = Stopwatch()..start();
    final doc = _parse(text, options);
    _record(watch.elapsedMicroseconds);
    _entries[key] = doc;
    if (_entries.length > capacity) _entries.remove(_entries.keys.first);
    return doc;
  }

  void _record(int micros) {
    if (!kDebugMode && !kProfileMode) return;
    _parsed++;
    _micros += micros;
    if (_parsed % 100 == 0) {
      Log.info(
        'markdown',
        'parsed $_parsed messages, ${(_micros / _parsed).toStringAsFixed(0)} µs '
            'on average',
      );
    }
  }
}
