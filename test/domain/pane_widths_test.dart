import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/pane_widths.dart';

void main() {
  test('a wide thread pane is kept while the room allows it', () {
    final fitted = fitPanes(room: 2400, list: 400, thread: 1200);
    expect(fitted.thread, 1200);
    expect(fitted.list, 400);
  });

  test('widths below the minimums are raised', () {
    final fitted = fitPanes(room: 2400, list: 100, thread: 100);
    expect(fitted.list, minListWidth);
    expect(fitted.thread, minThreadWidth);
  });

  test('the thread pane gives first, then the list, to leave the '
      'conversation its minimum', () {
    final fitted = fitPanes(room: 1300, list: 400, thread: 800);
    expect(fitted.thread, 1300 - 400 - minConversationWidth);
    expect(fitted.list, 400);
    final tight = fitPanes(room: 800, list: 400, thread: 800);
    expect(tight.thread, minThreadWidth);
    expect(tight.list, minListWidth);
  });

  test('dragging has no maximum beyond the conversation minimum', () {
    expect(
      resizedPane(5000, room: 2000, others: 300, isThread: true),
      2000 - 300 - minConversationWidth,
    );
    expect(
      resizedPane(10, room: 2000, others: 300, isThread: false),
      minListWidth,
    );
    expect(resizedPane(1300, room: 2000, others: 0, isThread: true), 1300);
  });
}
