import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/data/actions/drafts.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/views/root_views.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  late FakeServer server;
  late ServerSession session;
  late ComposerActions actions;

  setUp(() async {
    server = await FakeServer.start();
    session = await testSession(server);
    actions = ComposerActions(session);
  });

  tearDown(() async {
    await actions.dispose();
    await closeTestSession(session);
    await server.close();
  });

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 600));

  final photo = api.FileInfo.fromJson({
    'id': 'file1',
    'name': 'harbour.jpg',
    'extension': 'jpg',
    'mime_type': 'image/jpeg',
    'size': 2048,
    'width': 800,
    'height': 600,
    'has_preview_image': true,
  });

  test('a draft is saved a moment after typing stops and restored with its '
      'cursor, files and priority', () async {
    actions.saveDraft(
      Draft(
        channelId: channelId,
        message: 'half a thought',
        selectionBase: 4,
        selectionExtent: 4,
        files: [photo],
        priority: const api.PostPriority(
          priority: api.PostPriorityPriority.important,
          requestedAck: true,
        ),
      ),
    );
    expect(await session.db.select(session.db.drafts).get(), isEmpty);
    await settle();

    final fresh = ComposerActions(session);
    final draft = (await fresh.loadDraft(channelId))!;
    expect(draft.message, 'half a thought');
    expect(draft.selectionBase, 4);
    expect(draft.files.single.name, 'harbour.jpg');
    expect(draft.files.single.width, 800);
    expect(draft.priority?.priority, api.PostPriorityPriority.important);
    expect(draft.priority?.requestedAck, isTrue);
  });

  test('only the last of quick changes is written', () async {
    actions
      ..saveDraft(const Draft(channelId: channelId, message: 'h'))
      ..saveDraft(const Draft(channelId: channelId, message: 'he'))
      ..saveDraft(const Draft(channelId: channelId, message: 'hey'));
    await settle();
    final rows = await session.db.select(session.db.drafts).get();
    expect(rows.single.message, 'hey');
  });

  test('flushing writes a waiting draft at once', () async {
    actions.saveDraft(const Draft(channelId: channelId, message: 'bye'));
    await actions.flushDrafts();
    expect(
      (await session.db.select(session.db.drafts).get()).single.message,
      'bye',
    );
  });

  test('thread drafts are kept apart from the channel draft', () async {
    actions
      ..saveDraft(const Draft(channelId: channelId, message: 'channel'))
      ..saveDraft(
        const Draft(channelId: channelId, rootId: 'root1', message: 'reply'),
      );
    await actions.flushDrafts();
    expect((await actions.loadDraft(channelId))!.message, 'channel');
    expect(
      (await actions.loadDraft(channelId, rootId: 'root1'))!.message,
      'reply',
    );
  });

  test('emptying the text deletes the draft', () async {
    actions.saveDraft(const Draft(channelId: channelId, message: 'x'));
    await actions.flushDrafts();
    actions.saveDraft(const Draft(channelId: channelId));
    await actions.flushDrafts();
    expect(await actions.loadDraft(channelId), isNull);
  });

  test(
    'a send right after typing is not brought back by the waiting save',
    () async {
      actions.saveDraft(const Draft(channelId: channelId, message: 'go'));
      await actions.send(channelId, message: 'go');
      await settle();
      expect(await actions.loadDraft(channelId), isNull);
    },
  );

  test('the channel list marks channels with a draft', () async {
    actions.saveDraft(const Draft(channelId: channelId, message: 'later'));
    await actions.flushDrafts();
    final list = await RootViews(session.db).channelList(teamId).first;
    expect(list.drafts, 1);
  });
}
