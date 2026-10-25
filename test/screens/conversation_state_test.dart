import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/screens/channel/conversation_state.dart';

void main() {
  final message = PostItem(
    id: 'p1',
    key: 'p1',
    userId: 'bob',
    authorName: 'bob',
    createAt: DateTime.utc(2026, 10, 20),
    message: 'hello',
  );
  const neverLoaded = ConversationWindow(posts: [], loaded: false);
  const emptyChannel = ConversationWindow(
    posts: [],
    loaded: true,
    reachesStart: true,
    memberCount: 4,
  );
  final stored = ConversationWindow(
    posts: [message],
    loaded: true,
    memberCount: 4,
  );

  ConversationBody body(ConversationState s) =>
      conversationBody(s, host: 'chat.example.test');

  test('first open shows a spinner until the first page is stored', () {
    expect(body(const ConversationState()), isA<BodyLoading>());
    expect(
      body(const ConversationState(window: neverLoaded, refreshing: true)),
      isA<BodyLoading>(),
    );
  });

  test('a failed first open says why, with nothing stored', () {
    final state = body(
      const ConversationState(
        window: neverLoaded,
        refreshFailure: Unreachable(),
      ),
    );
    expect(state, isA<BodyFailed>());
    expect((state as BodyFailed).text, contains('chat.example.test'));
  });

  test('a channel without messages is empty, not loading', () {
    expect(
      body(const ConversationState(window: emptyChannel)),
      isA<BodyEmpty>(),
    );
  });

  test('stored messages show whatever the refresh does', () {
    expect(
      body(
        ConversationState(window: stored, refreshFailure: const Unreachable()),
      ),
      isA<BodyReady>(),
    );
  });

  test('the subtitle says when saved data is shown after a failure', () {
    expect(
      conversationSubtitle(
        ConversationState(window: stored, refreshFailure: const Unreachable()),
      ),
      'Offline · showing saved data',
    );
    expect(
      conversationSubtitle(
        ConversationState(
          window: stored,
          refreshFailure: const ServerError(statusCode: 500),
        ),
      ),
      "Couldn't refresh · showing saved data",
    );
    expect(
      conversationSubtitle(ConversationState(window: stored)),
      '4 members',
    );
    expect(
      conversationSubtitle(ConversationState(window: stored, refreshing: true)),
      '4 members',
    );
  });
}
