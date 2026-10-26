import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/json/client_config.dart';
import 'package:matterleast/data/actions/message_links.dart';
import 'package:matterleast/domain/post_details.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/server_features.dart';

void main() {
  group('details', () {
    test('an OpenGraph embed becomes a preview with its measured image', () {
      final details = PostDetails.decode(
        '{}',
        '{"embeds":[{"type":"opengraph","url":"https://x.test/a",'
            '"data":{"title":"Lamps","site_name":"X","description":"d",'
            '"images":[{"secure_url":"https://x.test/i.png"}]}}],'
            '"images":{"https://x.test/i.png":{"width":800,"height":400}}}',
      );
      final preview = details.preview!;
      expect((preview.title, preview.siteName), ('Lamps', 'X'));
      expect(preview.imageUrl, 'https://x.test/i.png');
      expect((preview.imageSize!.width, preview.imageSize!.height), (800, 400));
    });

    test('a plain link embed is no preview', () {
      final details = PostDetails.decode(
        null,
        '{"embeds":[{"type":"link","url":"https://x.test"}]}',
      );
      expect(details.preview, isNull);
    });

    test('webhook names, priority and unsafe links are read', () {
      final details = PostDetails.decode(
        '{"from_webhook":"true","override_username":"Deploys",'
            '"unsafe_links":"true"}',
        '{"priority":{"priority":"urgent"}}',
      );
      expect(details.fromWebhook, isTrue);
      expect(details.props.overrideUsername, 'Deploys');
      expect(details.unsafeLinks, isTrue);
      expect(details.priority, PostPriorityLabel.urgent);
    });

    test('attachments use the server spelling', () {
      final details = PostDetails.decode(
        '{"attachments":[{"title":"Build","author_name":"CI","fields":'
        '[{"title":"Took","value":42,"short":true}]}]}',
        null,
      );
      final a = details.props.attachments.single;
      expect((a.title, a.authorName), ('Build', 'CI'));
      expect(a.fields.single.value, '42');
    });

    test('malformed JSON gives empty details', () {
      final details = PostDetails.decode('{oops', '[]');
      expect(details.props.attachments, isEmpty);
      expect(details.preview, isNull);
    });
  });

  group('reactions', () {
    test('grouped by emoji in the order first used, mine marked', () {
      final groups = groupReactions(
        [
          (userId: 'b', emojiName: 'tada', at: DateTime(2026, 1, 1, 0, 2)),
          (userId: 'a', emojiName: '+1', at: DateTime(2026, 1, 1, 0, 1)),
          (userId: 'me', emojiName: '+1', at: DateTime(2026, 1, 1, 0, 3)),
        ],
        myUserId: 'me',
        personOf: (id) =>
            (id: id, name: id.toUpperCase(), username: id, pictureAt: null),
      );
      expect([for (final g in groups) g.emojiName], ['+1', 'tada']);
      expect(groups.first.count, 2);
      expect([for (final p in groups.first.people) p.name], ['A', 'ME']);
      expect([for (final g in groups) g.mine], [true, false]);
    });
  });

  test('server settings switch LaTeX and set the hashtag length', () {
    final options = parseOptionsFrom(
      serverFeatures(
        config: ClientConfig.fromJson({
          'EnableLatex': 'true',
          'EnableInlineLatex': 'false',
          'MinimumHashtagLength': '4',
          'MaxMarkdownNodes': '0',
        }),
        license: const ClientLicense(),
      ),
    );
    expect(options.latexBlocks, isTrue);
    expect(options.latexInline, isFalse);
    expect(options.minimumHashtagLength, 4);
  });
}
