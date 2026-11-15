import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/markdown/task_list.dart';

void main() {
  group('toggleTask', () {
    test('ticks and unticks one box and keeps every other byte', () {
      const text = 'Plan\n- [ ] one\n- [x] two\n\nend  ';
      expect(toggleTask(text, 0), 'Plan\n- [x] one\n- [x] two\n\nend  ');
      expect(toggleTask(text, 1), 'Plan\n- [ ] one\n- [ ] two\n\nend  ');
    });

    test('an upper case X is text, as in Mattermost', () {
      expect(toggleTask('- [X] a', 0), isNull);
      expect(toggleTask('- [X] a\n- [ ] b', 0), '- [X] a\n- [x] b');
    });

    test('every list marker works', () {
      expect(toggleTask('* [ ] a', 0), '* [x] a');
      expect(toggleTask('+ [ ] a', 0), '+ [x] a');
      expect(toggleTask('1. [ ] a\n2. [ ] b', 1), '1. [ ] a\n2. [x] b');
      expect(toggleTask('1) [ ] a', 0), '1) [x] a');
    });

    test('nested lists are numbered in reading order', () {
      const text = '- [ ] a\n  - [ ] b\n  - [x] c\n- [ ] d';
      expect(toggleTask(text, 1), '- [ ] a\n  - [x] b\n  - [x] c\n- [ ] d');
      expect(toggleTask(text, 3), '- [ ] a\n  - [ ] b\n  - [x] c\n- [x] d');
    });

    test('tasks in a quote count', () {
      expect(toggleTask('> - [ ] a\n> - [ ] b', 1), '> - [ ] a\n> - [x] b');
    });

    test('boxes in code and plain brackets are not tasks', () {
      const text =
          '```\n- [ ] code\n```\n\n    - [ ] indented\n\n'
          '`- [ ] inline`\n\n- [ ] real\n\n- not [ ] a task';
      expect(
        toggleTask(text, 0),
        text.replaceFirst('- [ ] real', '- [x] real'),
      );
      expect(toggleTask(text, 1), isNull);
    });

    test('an index that does not exist gives null', () {
      expect(toggleTask('- [ ] a', 1), isNull);
      expect(toggleTask('- [ ] a', -1), isNull);
      expect(toggleTask('no tasks', 0), isNull);
    });
  });

  test('mayHaveTasks tells list markers with a box', () {
    expect(mayHaveTasks('a\n- [ ] b'), isTrue);
    expect(mayHaveTasks('[ ] b'), isFalse);
  });
}
