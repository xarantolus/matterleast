import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/json/agents.dart';
import 'package:matterleast/data/servers/server_session.dart';

const _route = '/plugins/mattermost-ai';

/// Talks to the Agents plugin. Server errors are thrown as [ApiError]s.
class AgentActions {
  AgentActions(this.session);

  final ServerSession session;

  String _post(String postId) => '$_route/post/${Uri.encodeComponent(postId)}';

  /// The agents the user may talk to.
  Future<List<AgentBot>> bots() async {
    final json = await session.api.getJsonObject('$_route/ai_bots');
    return json == null ? const [] : AgentBotsAnswer.fromJson(json).bots;
  }

  /// The user's conversations with agents, newest first.
  Future<List<AgentThread>> threads() async {
    final response = await session.api.call(
      () => session.api.dio.get<Object?>('$_route/ai_threads'),
    );
    final threads = decodeAgentThreads(response.data)
      ..sort(
        (a, b) =>
            (b.updateAt ?? DateTime(0)).compareTo(a.updateAt ?? DateTime(0)),
      );
    return threads;
  }

  /// Starts a conversation with [bot]: the message goes to the direct
  /// message with the agent as the first post of a thread, which the agent
  /// answers in. Returns the channel and the new post.
  Future<({String channelId, String postId})> ask(
    AgentBot bot,
    String message,
  ) async {
    final channelId = await session.channels.directChannel(bot.id);
    final post = await session.api.call(
      () => session.api.client.posts.createPost(
        body: api.ApiV4PostsRequestBody(channelId: channelId, message: message),
      ),
    );
    await session.store.applyLivePost(post, fromSelf: true, mentionsMe: false);
    return (channelId: channelId, postId: post.id!);
  }

  /// Stops the answer being written into [postId]. Late text is ignored
  /// from the moment of the tap.
  Future<void> stop(String postId) async {
    session.connection.agents.stop(postId);
    await session.api.call(
      () => session.api.dio.post<Object?>('${_post(postId)}/stop'),
    );
  }

  /// Writes the answer in [postId] again.
  Future<void> regenerate(String postId) async {
    session.connection.agents.clear(postId);
    await session.api.call(
      () => session.api.dio.post<Object?>('${_post(postId)}/regenerate'),
    );
  }

  /// Runs the [accepted] pending tools of [postId] and skips the others;
  /// [answers] carries the user's picks for questions.
  Future<void> decideToolCalls(
    String postId,
    List<String> accepted, {
    Map<String, AgentToolAnswer>? answers,
  }) => session.api.call(
    () => session.api.dio.post<Object?>(
      '${_post(postId)}/tool_call',
      data: AgentToolDecision(
        acceptedToolIds: accepted,
        toolAnswers: answers == null || answers.isEmpty ? null : answers,
      ).toJson(),
    ),
  );

  /// Shares the [accepted] tool results of [postId] with the agent and
  /// keeps the others private.
  Future<void> decideToolResults(String postId, List<String> accepted) =>
      session.api.call(
        () => session.api.dio.post<Object?>(
          '${_post(postId)}/tool_result',
          data: AgentToolDecision(acceptedToolIds: accepted).toJson(),
        ),
      );

  /// Brings agent [botUsername] into the thread of [postId].
  Future<void> loopIn(String postId, String botUsername) => session.api.call(
    () => session.api.dio.post<Object?>(
      '${_post(postId)}/loop_in_agent',
      queryParameters: {'botUsername': botUsername},
    ),
  );

  /// Asks [bot] to summarise channel [channelId]; the summary is written
  /// in the agent's direct message. Returns where.
  Future<AgentAnalysisAnswer> summarize(
    String channelId,
    AgentBot bot, {
    int? days,
    bool unreadsOnly = false,
  }) async {
    final response = await session.api.call(
      () => session.api.dio.post<Object?>(
        '$_route/channel/${Uri.encodeComponent(channelId)}/analyze',
        queryParameters: {'botUsername': bot.username},
        data: AgentAnalysisRequest(
          days: days,
          unreadsOnly: unreadsOnly ? true : null,
        ).toJson(),
      ),
    );
    final json = response.data;
    return json is Map<String, Object?>
        ? AgentAnalysisAnswer.fromJson(json)
        : const AgentAnalysisAnswer();
  }
}
