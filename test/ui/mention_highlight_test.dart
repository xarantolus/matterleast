import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/markdown/mention_keys.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/tokens.dart';

import '../support/pump_app.dart';

Color? _background(WidgetTester tester, String word) {
  Color? found;
  for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
    rich.text.visitChildren((span) {
      if (span is TextSpan && span.text == word) {
        found = span.style?.backgroundColor;
      }
      return true;
    });
  }
  return found;
}

Future<void> _show(
  WidgetTester tester,
  String message, {
  bool broadcast = false,
}) => pumpApp(
  tester,
  Scaffold(
    body: PostEnvironment(
      server: Uri.parse('https://chat.example.test'),
      options: const ParseOptions(
        mentions: MentionKeys(
          mentions: [MentionKey('deploy'), MentionKey('@river')],
          highlights: ['fika'],
        ),
      ),
      myUsername: 'river',
      broadcastHighlight: broadcast,
      onMention: (_, _) {},
      onChannel: (_) {},
      onLink: (_) {},
      child: PostBody(postId: 'p1', message: message),
    ),
  ),
);

void main() {
  testWidgets('the reader\'s words stand out in a message, a highlight word '
      'more quietly, and other words not at all', (tester) async {
    await _show(tester, 'the deploy is done, fika at three');
    final tokens = AppTokens.light;
    expect(_background(tester, 'deploy'), tokens.accentWash);
    expect(_background(tester, 'fika'), tokens.keywordWash);
    expect(_background(tester, 'the '), isNull);
  });

  testWidgets('@channel is marked only where the reader asked for it', (
    tester,
  ) async {
    await _show(tester, 'hi @channel');
    expect(_background(tester, '@channel'), isNull);
    await _show(tester, 'hi @channel', broadcast: true);
    await tester.pump();
    expect(_background(tester, '@channel'), AppTokens.light.accentWash);
  });

  testWidgets('an @mention of the reader is marked, one of anyone else is '
      'not', (tester) async {
    await _show(tester, '@river and @sam');
    expect(_background(tester, '@river'), AppTokens.light.accentWash);
    expect(_background(tester, '@sam'), isNull);
  });
}
