import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/post_files.dart';

void main() {
  testWidgets('a text file on a server that keeps files in the app does not '
      'open', (tester) async {
    final server = Uri.parse('https://chat.test');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          featuresProvider(server.toString()).overrideWith(
            (ref) => Stream.value(const ServerFeatures(fileDownloads: false)),
          ),
        ],
        child: MaterialApp(
          theme: themeForPlatform(MatterleastApp.lightTheme),
          home: Scaffold(
            body: PostEnvironment(
              server: server,
              options: const ParseOptions(),
              myUsername: 'me',
              onMention: (_, _) {},
              onChannel: (_) {},
              onLink: (_) {},
              child: Align(
                alignment: Alignment.topLeft,
                child: PostFiles(
                  files: const [
                    PostFile(id: 't1', name: 'tides.txt', extension: 'txt'),
                  ],
                  heroPrefix: 'p1',
                  author: 'bob',
                  sentAt: DateTime(2026),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('tides.txt'));
    await tester.pump();
    await tester.pump();
    expect(
      find.textContaining('Only PDF files can be previewed'),
      findsOneWidget,
    );
  });
}
