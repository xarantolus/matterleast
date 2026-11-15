import 'package:matterleast/markdown/parse_post.dart';
import 'package:matterleast/markdown/post_doc.dart';

final _marker = RegExp(
  r'^[ \t>]*(?:[-*+]|\d{1,9}[.)])[ \t]+(\[[ x]\])(?=[ \t])',
  multiLine: true,
);

/// Whether [message] may hold a task list; cheap, to skip the rest.
bool mayHaveTasks(String message) => _marker.hasMatch(message);

/// Whether each task of [doc] is done, in reading order.
List<bool> taskStates(PostDoc doc) {
  final states = <bool>[];
  void walk(List<Block> blocks) {
    for (final block in blocks) {
      switch (block) {
        case Quote(:final blocks):
          walk(blocks);
        case ListBlock(:final items):
          for (final item in items) {
            if (item.checked case final done?) states.add(done);
            walk(item.blocks);
          }
        default:
      }
    }
  }

  if (doc case ParsedPost(:final blocks)) walk(blocks);
  return states;
}

List<bool> _statesOf(String message) =>
    taskStates(parsePost(message, const ParseOptions()));

/// [message] with the [index]th task flipped and every other byte kept, or
/// null when there is no such task. The parser decides which marker that is:
/// the one whose flip changes that task and no other.
String? toggleTask(String message, int index) {
  final before = _statesOf(message);
  if (index < 0 || index >= before.length) return null;
  for (final match in _marker.allMatches(message)) {
    final flipped = message.replaceRange(
      match.end - 3,
      match.end,
      match[1] == '[ ]' ? '[x]' : '[ ]',
    );
    final after = _statesOf(flipped);
    if (after.length != before.length) continue;
    final changed = [
      for (var i = 0; i < after.length; i++)
        if (after[i] != before[i]) i,
    ];
    if (changed.length == 1 && changed.first == index) return flipped;
  }
  return null;
}
