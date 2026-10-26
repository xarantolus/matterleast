import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/db/json_columns.dart';

void main() {
  test('stored lists and objects read back typed', () {
    const ids = StringListColumn();
    expect(ids.fromSql(ids.toSql(['u1', 'u2'])), ['u1', 'u2']);

    const files = FileInfoListColumn();
    final read = files.fromSql(
      files.toSql([
        api.FileInfo.fromJson({'id': 'f1', 'name': 'tide.png'}),
      ]),
    );
    expect(read.single.name, 'tide.png');

    const props = ChannelNotifyPropsColumn();
    final stored = props.toSql(
      api.ChannelNotifyProps.fromJson({'mark_unread': 'mention'}),
    );
    expect(props.fromSql(stored)?.markUnread, 'mention');
  });

  test('text that is not what the column holds reads as empty', () {
    expect(const StringListColumn().fromSql('{"not": "a list"}'), isEmpty);
    expect(const StringListColumn().fromSql('[1, "u1", null]'), ['u1']);
    expect(const StringListColumn().fromSql('not json'), isEmpty);
    expect(const JsonMapColumn().fromSql('[]'), isEmpty);
    expect(
      const FileInfoListColumn().fromSql('[7, {"id": "f1"}]'),
      hasLength(1),
    );
    expect(const ChannelNotifyPropsColumn().fromSql('"text"'), isNull);
    expect(const PostPriorityColumn().fromSql(null), isNull);
  });
}
