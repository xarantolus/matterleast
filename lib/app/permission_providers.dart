import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/views/permission_views.dart';
import 'package:matterleast/domain/permissions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permission_providers.g.dart';

/// What the user may do in one channel, as their roles and the channel
/// change.
@riverpod
Stream<ChannelPermissions> channelRights(
  Ref ref,
  String url,
  String channelId,
) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* PermissionViews(session.db).watchChannel(channelId);
}
