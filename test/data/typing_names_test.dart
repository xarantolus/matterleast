import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/servers/server_session.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  late FakeServer server;
  late ServerSession session;

  setUp(() async {
    (server, session) = await startServerSession();
  });

  test('someone typing is named once their profile arrives', () async {
    final url = server.url.toString();
    final container = ProviderContainer(
      overrides: [
        serverSessionProvider(url).overrideWith((ref) async => session),
      ],
    );
    addTearDown(container.dispose);
    final names = <List<String>>[];
    container.listen(
      typingNamesProvider(url, channelId, ''),
      (_, next) => names.add(next.value ?? const []),
      fireImmediately: true,
    );
    session.connection.typing.typing(channelId, '', 'newcomer');
    await pumpEventQueue();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(names.last, ['Someone']);

    await session.store.applyUsers([
      api.User.fromJson({'id': 'newcomer', 'username': 'quinn'}),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(names.last, ['quinn']);
  });
}
