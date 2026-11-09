import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/calls.dart';

const callsRoute = '/plugins/$callsPluginId';

/// The server runs the Calls plugin.
Future<void> installCallsPlugin(ServerSession session) =>
    session.store.applyPlugins([
      api.PluginManifestWebapp(id: callsPluginId, version: '1.0.0'),
    ]);

/// What the plugin answers for a running call: people by user id, each on
/// the session `s-<user>`.
Map<String, Object?> callJson({
  String id = 'call1',
  String postId = 'post1',
  List<String> people = const [],
  int startAt = 1700000000000,
}) => {
  'id': id,
  'start_at': startAt,
  'thread_id': postId,
  'post_id': postId,
  'owner_id': people.isEmpty ? '' : people.first,
  'host_id': people.isEmpty ? '' : people.first,
  'sessions': [
    for (final user in people)
      {'session_id': 's-$user', 'user_id': user, 'unmuted': false},
  ],
};

Map<String, Object?> callsChannelJson(
  String channelId, {
  bool? enabled,
  Map<String, Object?>? call,
}) => {'channel_id': channelId, 'enabled': ?enabled, 'call': ?call};

/// The settings of a server that lets everyone start calls.
Map<String, Object?> callsConfigJson({
  bool defaultEnabled = true,
  bool? groupCallsAllowed,
}) => {
  'DefaultEnabled': defaultEnabled,
  'GroupCallsAllowed': ?groupCallsAllowed,
  'AllowEnableCalls': true,
};
