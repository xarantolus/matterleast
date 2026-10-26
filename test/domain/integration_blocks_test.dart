import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/json/integration_props.dart';
import 'package:matterleast/domain/integration_blocks.dart';
import 'package:matterleast/domain/post_details.dart';

/// A readable outline of a block tree, one block per line.
String outline(List<IntegrationBlock> blocks, [String indent = '']) {
  final out = StringBuffer();
  for (final b in blocks) {
    out.writeln('$indent${_line(b)}');
    final children = switch (b) {
      ContainerBlock(:final content) => content,
      ColumnSetBlock(:final columns) => columns,
      ColumnBlock(:final items) => items,
      CollapsibleBlock(:final header, :final content) => [
        ...header,
        ...content,
      ],
      _ => const <IntegrationBlock>[],
    };
    if (children.isNotEmpty) out.write(outline(children, '$indent  '));
  }
  return out.toString();
}

String _line(IntegrationBlock b) => switch (b) {
  TextBlock(:final text, :final subtle, :final small) =>
    'text "$text"${subtle ? ' subtle' : ''}${small ? ' small' : ''}',
  ImageBlock(:final url, :final size) => 'image $url ${size.name}',
  DividerBlock() => 'divider',
  ContainerBlock(:final border, :final accent, :final horizontal) =>
    'container${border ? ' border' : ''}${accent == null ? '' : ' $accent'}'
        '${horizontal ? ' row' : ''}',
  ColumnSetBlock() => 'columns',
  ColumnBlock(:final stretch) => 'column${stretch ? ' stretch' : ''}',
  CollapsibleBlock(:final collapsed) =>
    'collapsible${collapsed ? ' closed' : ' open'}',
  ButtonBlock(:final text, :final actionId, :final style, :final cookie) =>
    'button "$text" $actionId${style == null ? '' : ' $style'}'
        '${cookie == null ? '' : ' cookie=$cookie'}',
  SelectBlock(
    :final placeholder,
    :final actionId,
    :final options,
    :final source,
  ) =>
    'select "$placeholder" $actionId ${source.name}'
        '${options.isEmpty ? '' : ' ${options.map((o) => o.value).join('/')}'}',
};

InteractiveContent? content(
  Map<String, Object?> props, {
  bool mmBlocks = true,
}) => interactiveContent(IntegrationProps.fromJson(props), mmBlocks: mmBlocks);

void main() {
  group('message attachments', () {
    test('keep pretext, author, title, text, fields, footer and actions', () {
      final c = content({
        'attachments': [
          {
            'pretext': 'Nightly build',
            'color': '#3a7',
            'author_name': 'Kiln',
            'title': 'Build 88',
            'title_link': 'https://ci.example.test/88',
            'text': 'All green.',
            'fields': [
              {'title': 'Branch', 'value': 'main', 'short': true},
              {'title': 'Took', 'value': 12, 'short': true},
              {'title': 'Empty', 'value': ''},
            ],
            'footer': 'Kiln CI',
            'actions': [
              {
                'id': 'rerun',
                'name': 'Rerun',
                'style': 'primary',
                'cookie': 'c1',
              },
              {
                'id': 'who',
                'name': 'Assign',
                'type': 'select',
                'data_source': 'users',
              },
              {'id': 'size', 'name': 'Size', 'type': 'select'},
              {'name': 'No id'},
            ],
          },
        ],
      })!;
      expect(c.format, IntegrationFormat.attachment);
      expect(outline(c.blocks), '''
text "Nightly build"
container border #3a7
  text "Kiln"
  text "**[Build 88](https://ci.example.test/88)**"
  text "All green."
  container
    columns
      column stretch
        text "**Branch**"
        text "main"
      column stretch
        text "**Took**"
        text "12"
  text "Kiln CI" subtle small
  container row
    button "Rerun" rerun primary cookie=c1
    select "Assign" who users
''');
      final rerun =
          ((c.blocks[1] as ContainerBlock).content.last as ContainerBlock)
              .content
              .first;
      expect(c.cookieFor(rerun), 'c1', reason: 'its own cookie');
    });

    test('a title link that is not a web address stays plain text', () {
      final c = content({
        'attachments': [
          {'title': 'Click', 'title_link': 'javascript:alert(1)'},
        ],
      })!;
      expect(outline(c.blocks), 'container border\n  text "**Click**"\n');
    });

    test('a thumbnail sits beside the body', () {
      final c = content({
        'attachments': [
          {'text': 'Look', 'thumb_url': 'https://img.example.test/t.png'},
        ],
      })!;
      expect(outline(c.blocks), '''
container border
  columns
    column stretch
      text "Look"
    column
      image https://img.example.test/t.png small
''');
    });
  });

  group('Block Kit', () {
    test('sections, headers, dividers, images and actions translate', () {
      final c = content({
        'blocks': [
          {
            'type': 'header',
            'text': {'type': 'plain_text', 'text': 'Standup'},
          },
          {
            'type': 'section',
            'text': {'type': 'mrkdwn', 'text': 'Hello'},
            'accessory': {
              'type': 'button',
              'text': {'type': 'plain_text', 'text': 'Go'},
              'action_id': 'go',
            },
          },
          {
            'type': 'section',
            'fields': [
              {'type': 'mrkdwn', 'text': 'A'},
              {'type': 'mrkdwn', 'text': 'B'},
              {'type': 'mrkdwn', 'text': 'C'},
            ],
          },
          {'type': 'divider'},
          {
            'type': 'image',
            'image_url': 'https://img.example.test/a.png',
            'alt_text': 'a map',
          },
          {'type': 'context', 'elements': <Object?>[]},
          {
            'type': 'actions',
            'elements': [
              {
                'type': 'button',
                'text': {'type': 'plain_text', 'text': 'No'},
                'action_id': 'no',
                'style': 'danger',
              },
              {
                'type': 'static_select',
                'action_id': 'pick',
                'placeholder': {'type': 'plain_text', 'text': 'Pick'},
                'options': [
                  {
                    'text': {'type': 'plain_text', 'text': 'One'},
                    'value': '1',
                  },
                ],
              },
            ],
          },
        ],
        'mm_blocks_actions': 'sealed-post-cookie',
      })!;
      expect(c.format, IntegrationFormat.block);
      expect(outline(c.blocks), '''
text "# Standup"
container
  columns
    column stretch
      text "Hello"
    column
      button "Go" go
container
  columns
    column stretch
      text "A"
    column stretch
      text "B"
  text "C"
divider
image https://img.example.test/a.png large
container row
  button "No" no danger
  select "Pick" pick options 1
''');
      expect(
        c.cookieFor(const ButtonBlock(text: 'x', actionId: 'go')),
        'sealed-post-cookie',
        reason: 'formats other than attachments use the post cookie',
      );
    });
  });

  group('Adaptive Cards', () {
    test('text, columns, containers and submit actions translate', () {
      final c = content({
        'cards': [
          {
            'type': 'AdaptiveCard',
            'body': [
              {'type': 'TextBlock', 'text': 'Hi', 'isSubtle': true},
              {'type': 'TextBlock', 'text': 'fine', 'size': 'Small'},
              {
                'type': 'ColumnSet',
                'columns': [
                  {
                    'type': 'Column',
                    'width': 'stretch',
                    'items': [
                      {'type': 'TextBlock', 'text': 'L'},
                    ],
                  },
                  {
                    'type': 'Column',
                    'width': 'auto',
                    'items': [
                      {
                        'type': 'Image',
                        'url': 'https://img.example.test/p.png',
                        'size': 'Small',
                        'style': 'person',
                      },
                    ],
                  },
                ],
              },
              {
                'type': 'Container',
                'items': [
                  {'type': 'TextBlock', 'text': 'Inside'},
                ],
              },
              {'type': 'FactSet', 'facts': <Object?>[]},
            ],
            'actions': [
              {
                'type': 'Action.Submit',
                'id': 'yes',
                'title': 'Yes',
                'style': 'positive',
              },
              {
                'type': 'Action.Submit',
                'id': 'no',
                'title': 'No',
                'style': 'destructive',
              },
              {'type': 'Action.OpenUrl', 'title': 'Site'},
            ],
          },
          {'type': 'NotACard'},
        ],
      })!;
      expect(c.format, IntegrationFormat.card);
      expect(outline(c.blocks), '''
text "Hi" subtle
text "fine" small
columns
  column stretch
    text "L"
  column
    image https://img.example.test/p.png small
container
  text "Inside"
container row
  button "Yes" yes primary
  button "No" no danger
''');
    });
  });

  group('MM Blocks', () {
    final props = {
      'mm_blocks': [
        {
          'type': 'container',
          'border': true,
          'accent_color': 'good',
          'content': [
            {'type': 'text', 'text': 'Status', 'size': 'small'},
            {
              'type': 'collapsible',
              'header': [
                {'type': 'text', 'text': 'More'},
              ],
              'content': [
                {'type': 'divider'},
              ],
              'collapsed': false,
            },
            {
              'type': 'static_select',
              'action_id': 'room',
              'placeholder': 'Room',
              'data_source': 'channels',
            },
            {'type': 'button', 'text': 'Ok', 'action_id': 'ok', 'style': 'odd'},
            {'type': 'text', 'text': 'bad size', 'size': 'huge'},
            {'type': 'button', 'text': ' ', 'action_id': 'blank'},
            {'type': 'mystery'},
          ],
        },
        {
          'type': 'column_set',
          'columns': [
            {'type': 'text', 'text': 'not a column'},
          ],
        },
      ],
      'attachments': [
        {'text': 'Fallback for older servers'},
      ],
    };

    test('valid blocks show; ones breaking the schema are left out', () {
      final c = content(props)!;
      expect(c.format, IntegrationFormat.mmBlock);
      expect(outline(c.blocks), '''
container border good
  text "Status" small
  collapsible open
    text "More"
    divider
  select "Room" room channels
  button "Ok" ok
''');
    });

    test('without the server flag the next format shows instead', () {
      final c = content(props, mmBlocks: false)!;
      expect(c.format, IntegrationFormat.attachment);
      expect(
        outline(c.blocks),
        'container border\n  text "Fallback for '
        'older servers"\n',
      );
    });
  });

  test('the first format present wins: blocks before cards', () {
    final c = content({
      'blocks': [
        {'type': 'divider'},
      ],
      'cards': [
        {
          'type': 'AdaptiveCard',
          'body': [
            {'type': 'TextBlock', 'text': 'card'},
          ],
        },
      ],
    })!;
    expect(c.format, IntegrationFormat.block);
    expect(outline(c.blocks), 'divider\n');
  });

  test('a post without integration content has none', () {
    expect(content({'from_bot': 'true'}), isNull);
  });

  group('limits', () {
    test('at most 100 blocks are kept', () {
      final c = content({
        'mm_blocks': [
          for (var i = 0; i < 150; i++) {'type': 'divider'},
        ],
      })!;
      expect(c.blocks, hasLength(maxBlocks));
    });

    test('text stops at 16000 characters in total', () {
      final c = content({
        'mm_blocks': [
          {'type': 'text', 'text': 'a' * 10000},
          {'type': 'text', 'text': 'b' * 10000},
          {'type': 'text', 'text': 'c'},
        ],
      })!;
      final texts = [for (final b in c.blocks) (b as TextBlock).text];
      expect(texts.map((t) => t.length), [10000, 6000]);
    });

    test('nesting deeper than 32 levels is cut, empty containers go', () {
      Map<String, Object?> nest(int depth) => depth == 0
          ? {'type': 'text', 'text': 'deep'}
          : {
              'type': 'container',
              'content': [nest(depth - 1)],
            };
      expect(
        content({
          'mm_blocks': [nest(40)],
        })!.blocks,
        isEmpty,
      );
      expect(
        content({
          'mm_blocks': [nest(31)],
        })!.blocks,
        hasLength(1),
      );
    });
  });

  test('content that could not be read shows the error card', () {
    const details = PostDetails(integrationError: 'StackOverflowError');
    final c = interactiveContentOf(details, mmBlocks: true)!;
    expect(outline(c.blocks), '''
container border danger
  text "**$translationErrorTitle**"
  text "StackOverflowError" subtle
''');
  });

  group('inline actions', () {
    test('an mmaction link names the action and its query', () {
      final a = parseInlineAction('mmaction://approve?row=2&who=a%20b')!;
      expect(a.actionId, 'approve');
      expect(a.query, {'row': '2', 'who': 'a b'});
    });

    test('ids outside the server rules and huge queries are refused', () {
      expect(parseInlineAction('mmaction://bad-id'), isNull);
      expect(parseInlineAction('https://example.test'), isNull);
      expect(parseInlineAction('mmaction://ok?x=${'y' * 2100}'), isNull);
      expect(parseInlineAction('mmaction://ok')!.query, isEmpty);
    });
  });
}
