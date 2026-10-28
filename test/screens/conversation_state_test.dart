import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/user_profile.dart';
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
      "Couldn't update: server error 500",
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

  test('a direct message shows the partner, a group its members', () {
    UserProfile partner(String status, [CustomStatus? custom]) => UserProfile(
      id: 'u1',
      name: 'Pat',
      username: 'pat',
      nickname: '',
      firstName: '',
      lastName: '',
      position: '',
      status: status,
      customStatus: custom,
      isBot: false,
      isMe: false,
    );
    const direct = ConversationState(
      window: ConversationWindow(
        posts: [],
        loaded: true,
        channelType: 'D',
        partnerId: 'u1',
        memberCount: 2,
      ),
    );
    expect(conversationSubtitle(direct), isNull);
    expect(
      conversationSubtitle(
        direct,
        partner: partner('away'),
        presenceKnown: true,
      ),
      'Away',
    );
    expect(
      conversationSubtitle(
        direct,
        partner: partner('dnd', const CustomStatus(text: 'In a meeting')),
        presenceKnown: true,
      ),
      'Do not disturb · In a meeting',
    );
    // While the server isn't live the stored presence isn't told, but the
    // line stays so the title doesn't move.
    expect(
      conversationSubtitle(
        direct,
        partner: partner('dnd', const CustomStatus(text: 'In a meeting')),
      ),
      'In a meeting',
    );
    expect(conversationSubtitle(direct, partner: partner('away')), '');
    expect(
      conversationSubtitle(
        const ConversationState(
          window: ConversationWindow(
            posts: [],
            loaded: true,
            channelType: 'G',
            channelName: 'pat, sam, kim',
            memberCount: 3,
          ),
        ),
      ),
      'pat, sam, kim',
    );
  });

  test('only an unreachable server reads as offline', () {
    final table = <ApiError, String>{
      const Unreachable(): 'Offline · showing saved data',
      const RequestTimeout():
          "Couldn't update: the server didn't answer in time",
      const ServerError(statusCode: 500): "Couldn't update: server error 500",
      const ServerError(statusCode: 403): "Couldn't update: server error 403",
      const UnexpectedFailure('TypeError'): "Couldn't read the server's reply",
      const UntrustedCertificate(): "Couldn't update: untrusted certificate",
    };
    for (final MapEntry(key: cause, value: text) in table.entries) {
      expect(
        conversationSubtitle(
          ConversationState(window: stored, refreshFailure: cause),
        ),
        text,
        reason: '$cause',
      );
    }
  });

  test("a direct message leads with the partner's status emoji", () {
    const custom = CustomStatus(emoji: 'partyblob', text: 'Launch day');
    const partner = UserProfile(
      id: 'u1',
      name: 'Pat',
      username: 'pat',
      nickname: '',
      firstName: '',
      lastName: '',
      position: '',
      status: 'online',
      customStatus: custom,
      isBot: false,
      isMe: false,
    );
    ConversationState direct({ApiError? failure}) => ConversationState(
      window: ConversationWindow(
        posts: stored.posts,
        loaded: true,
        channelType: 'D',
        partnerId: 'u1',
        memberCount: 2,
      ),
      refreshFailure: failure,
    );
    expect(
      conversationSubtitle(direct(), partner: partner, presenceKnown: true),
      'Online · Launch day',
    );
    expect(conversationSubtitleEmoji(direct(), partner: partner), 'partyblob');
    expect(
      conversationSubtitleEmoji(
        direct(failure: const Unreachable()),
        partner: partner,
      ),
      isNull,
      reason: 'the notice about saved data replaces the status',
    );
    expect(
      conversationSubtitleEmoji(
        direct(),
        partner: partner.copyWith(customStatus: null),
      ),
      isNull,
    );
  });

  test('a thread names its channel and says when replies may be stale', () {
    final thread = ConversationWindow(
      posts: const [],
      root: message,
      loaded: true,
      channelName: 'Town Square',
    );
    expect(
      threadSubtitle(
        ConversationState(window: thread),
        channelName: 'from the link',
      ),
      'Town Square',
    );
    expect(
      threadSubtitle(
        ConversationState(
          window: thread,
          refreshFailure: const ServerError(statusCode: 500),
        ),
        channelName: 'from the link',
      ),
      allOf(startsWith('Town Square · '), isNot(contains('Offline'))),
      reason: 'a server error is not the connection',
    );
    expect(
      threadSubtitle(
        const ConversationState(refreshFailure: Unreachable()),
        channelName: 'from the link',
      ),
      'from the link',
      reason: 'nothing shown yet, so nothing is stale',
    );
  });

  group('what a screen reader is told', () {
    PostItem post(String id, {String user = 'bob', String? sendState}) =>
        PostItem(
          id: id,
          key: id,
          userId: user,
          authorName: user,
          createAt: DateTime.utc(2026, 10, 20, 12),
          message: 'hello',
          sendState: sendState,
        );
    ConversationState state(
      List<PostItem> posts, {
      Iterable<String> arrived = const [],
    }) => ConversationState(
      myUserId: 'me',
      window: ConversationWindow(posts: posts, loaded: true),
      arrived: {for (final key in arrived) key: DateTime.utc(2026)},
    );

    test('a message from someone else that arrives live', () {
      final before = state([message]);
      final after = state([post('p2'), message], arrived: ['p2']);
      // Who wrote, not what: the reader moves to the message to hear it.
      expect(conversationNews(before, after), ['New message from bob']);
    });

    test("nothing for history or for the user's own messages", () {
      final before = state([message]);
      expect(
        conversationNews(before, state([post('p0'), message])),
        isEmpty,
        reason: 'loaded, not arrived',
      );
      expect(
        conversationNews(
          before,
          state([post('p2', user: 'me'), message], arrived: ['p2']),
        ),
        isEmpty,
      );
    });

    test("a message of the user's that failed, once", () {
      final pending = state([post('p2', user: 'me', sendState: 'pending')]);
      final failed = state([post('p2', user: 'me', sendState: 'failed')]);
      expect(conversationNews(pending, failed), ['Your message was not sent']);
      expect(conversationNews(failed, failed), isEmpty);
    });

    test('sending is told apart from other changes', () {
      final before = state([message]);
      expect(
        sentJustNow(
          before,
          state([post('p2', user: 'me', sendState: 'pending'), message]),
        ),
        isTrue,
      );
      expect(
        sentJustNow(before, state([post('p2'), message], arrived: ['p2'])),
        isFalse,
      );
    });
  });
}
