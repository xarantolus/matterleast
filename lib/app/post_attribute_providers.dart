import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/views/permission_views.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/post_attributes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_attribute_providers.g.dart';

/// What the channel of a post can carry, and what the user may set.
typedef PostAttributeSetup = ({
  List<PostAttributeField> fields,
  String me,
  bool systemAdmin,
});

@Riverpod(keepAlive: true)
Future<PostAttributeSetup> postAttributeSetup(
  Ref ref,
  String url,
  String postId,
) async {
  final actions = await ref.watch(postActionsProvider(url).future);
  final session = await ref.watch(serverSessionProvider(url).future);
  final post = await (session.db.select(
    session.db.posts,
  )..where((p) => p.id.equals(postId))).getSingleOrNull();
  final roles = await PermissionViews(session.db).systemRoles();
  return (
    fields: post == null
        ? const <PostAttributeField>[]
        : await actions.attributeFields(post.channelId),
    me: await session.db.syncText(SyncKeys.currentUserId) ?? '',
    systemAdmin: roles.split(' ').contains('system_admin'),
  );
}

/// The attribute fields a new channel in a team takes, and what the user
/// may set.
@riverpod
Future<PostAttributeSetup> channelAttributeSetup(
  Ref ref,
  String url,
  String teamId,
) async {
  final session = await ref.watch(serverSessionProvider(url).future);
  final roles = await PermissionViews(session.db).systemRoles();
  return (
    fields: await session.channels.attributeFields(teamId),
    me: await session.db.syncText(SyncKeys.currentUserId) ?? '',
    systemAdmin: roles.split(' ').contains('system_admin'),
  );
}

/// The names of the people attributes point at, by id; [ids] is the ids
/// joined with commas.
@riverpod
Future<Map<String, String>> attributeUserNames(
  Ref ref,
  String url,
  String ids,
) async {
  final session = await ref.watch(serverSessionProvider(url).future);
  final wanted = ids.split(',');
  await session.users.ensure(wanted);
  final rows = await (session.db.select(
    session.db.users,
  )..where((u) => u.id.isIn(wanted))).get();
  final format = await session.db.nameFormat();
  return {
    for (final u in rows)
      u.id: personName((
        username: u.username,
        firstName: u.firstName,
        lastName: u.lastName,
        nickname: u.nickname,
        status: u.status,
      ), format),
  };
}
