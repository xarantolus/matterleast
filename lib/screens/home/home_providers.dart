import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/views/inbox_views.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

/// The chip picked on Home; kept while the app runs so Saved can be opened
/// from the You page.
@Riverpod(keepAlive: true)
class HomeFilterSelection extends _$HomeFilterSelection {
  @override
  InboxFilter build() => InboxFilter.unread;

  void select(InboxFilter filter) => state = filter;
}

/// One server's inbox rows for every chip.
@riverpod
Stream<ServerInbox> serverInbox(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* InboxViews(session.db, serverUrl: url).inbox();
}

/// The followed threads of one team.
@riverpod
Stream<List<InboxItem>> teamThreads(Ref ref, String url, String teamId) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* InboxViews(session.db, serverUrl: url).teamThreads(teamId);
}
