import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/json/agents.dart';
import 'package:matterleast/data/actions/agent_actions.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  Future<Map<String, Object?>> bodyOf(
    Future<void> Function(AgentActions actions) summarize,
  ) async {
    final (server, session) = await startServerSession();
    server.handle = (request) => request.path.endsWith('/analyze')
        ? ok({'postid': 'p1', 'channelid': 'c1'})
        : null;
    await summarize(AgentActions(session));
    return server.seen.singleWhere((r) => r.path.endsWith('/analyze')).body;
  }

  const bot = AgentBot(id: 'b1', username: 'echo');

  test(
    'summarising unreads asks for the messages since the last read',
    () async {
      final body = await bodyOf(
        (actions) => actions.summarize(
          'ch1',
          bot,
          unreadsSince: DateTime.utc(2026, 10, 26, 9, 30),
        ),
      );
      expect(body, {
        'analysis_type': 'summarize_unreads',
        'since': '2026-10-26T09:30:00.000Z',
      });
    },
  );

  test('summarising days asks for that many days and no start time', () async {
    final body = await bodyOf(
      (actions) => actions.summarize('ch1', bot, days: 7),
    );
    expect(body, {'analysis_type': 'summarize_channel', 'days': 7});
  });
}
