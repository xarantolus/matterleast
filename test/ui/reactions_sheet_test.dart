import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/reactions_bar.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';

void main() {
  testWidgets('who reacted names someone once their profile arrives', (
    tester,
  ) async {
    final h = await pumpWithServer(
      tester,
      handle: (r) => switch (r.path) {
        '/api/v4/users/newcomer' => ok({
          'id': 'newcomer',
          'username': 'quinn',
          'first_name': 'Quinn',
        }),
        _ => ok(<String, Object?>{}),
      },
      home: (url) => Scaffold(
        body: PostEnvironment(
          server: Uri.parse(url),
          options: const ParseOptions(),
          myUsername: 'river',
          onMention: (_) {},
          onChannel: (_) {},
          onLink: (_) {},
          child: const ReactionsBar(
            reactions: [
              ReactionGroup(
                emojiName: 'tada',
                people: [
                  (
                    id: 'newcomer',
                    name: 'Someone',
                    username: '',
                    pictureAt: null,
                  ),
                ],
                mine: false,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.longPress(find.byType(FilterChip));
    await h.settle(tester);
    expect(find.text('Someone'), findsNothing);
    expect(find.text('@quinn'), findsOneWidget);
    await h.close(tester);
  });
}
