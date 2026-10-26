import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/views/draft_views.dart';
import 'package:matterleast/domain/drafts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'drafts_providers.g.dart';

/// One team's drafts, newest first.
@riverpod
Stream<List<DraftItem>> teamDrafts(Ref ref, String url, String teamId) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* DraftViews(session.db).drafts(teamId);
}
