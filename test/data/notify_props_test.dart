import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/channel_actions.dart';

void main() {
  test('a change keeps every other setting and fills the unknown ones', () {
    final props = completeNotifyProps(
      const api.ChannelNotifyProps(
        push: 'none',
        ignoreChannelMentions: 'on',
        markUnread: 'mention',
      ),
      markUnread: 'all',
    );
    final json = props.toJson();
    expect(json['push'], 'none');
    expect(json['ignore_channel_mentions'], 'on');
    expect(json['mark_unread'], 'all');
    expect(json.values, everyElement(isA<String>()));
  });

  test('nothing stored becomes the server defaults', () {
    final json = completeNotifyProps(const api.ChannelNotifyProps()).toJson();
    expect(json['desktop'], 'default');
    expect(json['mark_unread'], 'all');
    expect(json['push_threads'], 'all');
    expect(json.values, everyElement(isNotNull));
  });
}
