import 'package:matterleast/api/json/agents.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/agent_actions.dart';
import 'package:matterleast/data/live/agent_live.dart';
import 'package:matterleast/domain/agent_stream.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agent_providers.g.dart';

/// Whether the server runs a supported Agents plugin; follows plugin
/// changes. False while unknown, so nothing shows that might vanish.
@riverpod
bool agentsAvailable(Ref ref, String url) =>
    ref
        .watch(featuresProvider(url))
        .value
        ?.hasPlugin(agentsPluginId, minVersion: agentsMinVersion) ??
    false;

@riverpod
Future<AgentActions> agentActions(Ref ref, String url) async =>
    AgentActions(await ref.watch(serverSessionProvider(url).future));

/// The agents the user may talk to; none when the plugin is gone.
@riverpod
Future<List<AgentBot>> agentBots(Ref ref, String url) async {
  if (!ref.watch(agentsAvailableProvider(url))) return const [];
  return (await ref.watch(agentActionsProvider(url).future)).bots();
}

/// The user's conversations with agents, newest first.
@riverpod
Future<List<AgentThread>> agentThreads(Ref ref, String url) async {
  if (!ref.watch(agentsAvailableProvider(url))) return const [];
  return (await ref.watch(agentActionsProvider(url).future)).threads();
}

/// What is streaming into agent post [postId].
@riverpod
Stream<AgentStream?> agentStream(Ref ref, String url, String postId) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* session.connection.agents.watchStream(postId);
}

/// The conversation of agent post [postId] (plugin 2.x).
@riverpod
Stream<AgentConversationState> agentConversation(
  Ref ref,
  String url,
  String conversationId,
  String postId,
) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* session.connection.agents.watchConversation(
    conversationId,
    postId: postId,
  );
}
