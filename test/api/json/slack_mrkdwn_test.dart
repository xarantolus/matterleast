import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/json/slack_mrkdwn.dart';

void main() {
  const cases = {
    '*bold* and _italic_': '**bold** and _italic_',
    'a ~gone~ b': 'a ~~gone~~ b',
    '<https://example.test/a|the page>': '[the page](https://example.test/a)',
    '<https://example.test/a>': 'https://example.test/a',
    '<@U123|river> and <@U456>': '@river and @U456',
    '<#C1|general>': '~general',
    '<!here> <!channel> <!everyone>': '@here @channel @all',
    '<!subteam^S1|devs>': 'devs',
    'a &amp; b &lt;c&gt;': 'a & b <c>',
    '2 * 3 * 4': '2 * 3 * 4',
    'snake_case_name': 'snake_case_name',
    'use `*raw* &amp;` here': 'use `*raw* &` here',
    '```\n*raw*\n```\n*x*': '```\n*raw*\n```\n**x**',
    '<notalink>': '<notalink>',
  };
  cases.forEach((input, expected) {
    test('converts ${input.replaceAll('\n', r'\n')}', () {
      expect(slackMrkdwnToMarkdown(input), expected);
    });
  });
}
