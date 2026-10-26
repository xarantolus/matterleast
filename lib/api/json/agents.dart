import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/websocket/encoded.dart';

part 'agents.g.dart';

/// The Agents plugin (`mattermost-ai`): its routes, WebSocket payloads and
/// post props. All of it is another party's JSON, read leniently.

/// An agent the user may talk to, from `GET /plugins/mattermost-ai/ai_bots`.
@JsonSerializable(createToJson: false)
class AgentBot {
  const AgentBot({
    this.id = '',
    this.displayName = '',
    this.username = '',
    this.lastIconUpdate,
    this.isDefault,
    this.isDefaultSnake,
  });

  factory AgentBot.fromJson(Map<String, Object?> json) =>
      _$AgentBotFromJson(json);

  @JsonKey(fromJson: _string)
  final String id;
  @JsonKey(fromJson: _string)
  final String displayName;
  @JsonKey(fromJson: _string)
  final String username;
  @LenientInt()
  final int? lastIconUpdate;
  @LenientBool()
  final bool? isDefault;
  @LenientBool()
  @JsonKey(name: 'is_default')
  final bool? isDefaultSnake;

  /// The server's default agent (older plugins don't say).
  bool get defaultAgent => isDefault == true || isDefaultSnake == true;

  String get name => displayName.isNotEmpty ? displayName : username;
}

@JsonSerializable(createToJson: false)
class AgentBotsAnswer {
  const AgentBotsAnswer({this.bots = const []});

  factory AgentBotsAnswer.fromJson(Map<String, Object?> json) =>
      _$AgentBotsAnswerFromJson(json);

  @JsonKey(fromJson: _bots)
  final List<AgentBot> bots;
}

/// A past conversation with an agent, from `GET /ai_threads`. Plugin 2.x
/// sends `root_post_id` and `bot_id`; older ones use `id` as the root post.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class AgentThread {
  const AgentThread({
    this.id = '',
    this.title,
    this.message,
    this.channelId,
    this.rootPostId,
    this.botId,
    this.replyCount,
    this.updateAt,
  });

  factory AgentThread.fromJson(Map<String, Object?> json) =>
      _$AgentThreadFromJson(json);

  @JsonKey(fromJson: _string)
  final String id;
  @LenientString()
  final String? title;
  @LenientString()
  final String? message;
  @LenientString()
  final String? channelId;
  @LenientString()
  final String? rootPostId;
  @LenientString()
  final String? botId;
  @LenientInt()
  final int? replyCount;
  @MillisDateTime()
  final DateTime? updateAt;

  /// The post the conversation hangs under.
  String get root => rootPostId?.isNotEmpty ?? false ? rootPostId! : id;
}

/// What the plugin answers to a channel analysis: the summary post it
/// started in the agent's direct message.
@JsonSerializable(createToJson: false)
class AgentAnalysisAnswer {
  const AgentAnalysisAnswer({this.postId, this.channelId});

  factory AgentAnalysisAnswer.fromJson(Map<String, Object?> json) =>
      _$AgentAnalysisAnswerFromJson(json);

  @LenientString()
  @JsonKey(name: 'postid')
  final String? postId;
  @LenientString()
  @JsonKey(name: 'channelid')
  final String? channelId;
}

/// One option of a question an agent asks (the `AskUserQuestion` tool).
@JsonSerializable(createToJson: false)
class AgentQuestionOption {
  const AgentQuestionOption({this.label = '', this.description});

  factory AgentQuestionOption.fromJson(Map<String, Object?> json) =>
      _$AgentQuestionOptionFromJson(json);

  @JsonKey(fromJson: _string)
  final String label;
  @LenientString()
  final String? description;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class AgentQuestion {
  const AgentQuestion({
    this.question = '',
    this.options = const [],
    this.multiSelect,
    this.allowFreeForm,
  });

  factory AgentQuestion.fromJson(Map<String, Object?> json) =>
      _$AgentQuestionFromJson(json);

  @JsonKey(fromJson: _string)
  final String question;
  @JsonKey(fromJson: _options)
  final List<AgentQuestionOption> options;
  @LenientBool()
  final bool? multiSelect;
  @LenientBool()
  final bool? allowFreeForm;

  bool get usable =>
      question.isNotEmpty &&
      options.every((o) => o.label.isNotEmpty) &&
      options.isNotEmpty;
}

/// Tool call status as the plugin numbers it.
enum AgentToolStatus {
  pending,
  accepted,
  rejected,
  error,
  success,
  autoApproved;

  static AgentToolStatus fromCode(int? code) =>
      code != null && code >= 0 && code < values.length
      ? values[code]
      : pending;

  static AgentToolStatus fromName(String? name) => switch (name) {
    'accepted' => accepted,
    'rejected' => rejected,
    'error' => error,
    'success' => success,
    'auto_approved' => autoApproved,
    _ => pending,
  };

  /// The tool has run, failed or was turned down.
  bool get finished =>
      this == success ||
      this == error ||
      this == autoApproved ||
      this == rejected;
}

/// A tool an agent wants to run or ran, as the WebSocket and the legacy
/// `pending_tool_call` prop send it.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class AgentToolCall {
  const AgentToolCall({
    this.id = '',
    this.name = '',
    this.description,
    this.arguments,
    this.question,
    this.result,
    this.status = AgentToolStatus.pending,
    this.userInteraction,
    this.wouldAutoExecute,
    this.decided = false,
  });

  factory AgentToolCall.fromJson(Map<String, Object?> json) =>
      _$AgentToolCallFromJson(json);

  @JsonKey(fromJson: _string)
  final String id;
  @JsonKey(fromJson: _string)
  final String name;
  @LenientString()
  final String? description;

  /// The arguments as readable JSON; null when withheld from this reader.
  @JsonKey(fromJson: readableJson)
  final String? arguments;

  /// The arguments of a question the agent asks the user.
  @JsonKey(readValue: _argumentsOf, fromJson: questionOf)
  final AgentQuestion? question;
  @JsonKey(fromJson: readableJson)
  final String? result;
  @JsonKey(fromJson: _statusCode)
  final AgentToolStatus status;
  @LenientString()
  final String? userInteraction;
  @LenientBool()
  final bool? wouldAutoExecute;

  /// The share decision on the result was made (conversation API only).
  @JsonKey(includeFromJson: false)
  final bool decided;

  bool get asksUser => userInteraction?.isNotEmpty ?? false;
}

/// A source an agent cited.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class AgentCitation {
  const AgentCitation({this.url = '', this.title = ''});

  factory AgentCitation.fromJson(Map<String, Object?> json) =>
      _$AgentCitationFromJson(json);

  @JsonKey(fromJson: _string)
  final String url;
  @JsonKey(fromJson: _string)
  final String title;
}

/// `custom_mattermost-ai_postupdate` and `…_tool_call_status_updated`.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class AgentPostUpdate {
  const AgentPostUpdate({
    this.postId = '',
    this.next,
    this.control,
    this.toolCalls,
    this.reasoning,
    this.annotations,
  });

  factory AgentPostUpdate.fromJson(Map<String, Object?> json) =>
      _$AgentPostUpdateFromJson(json);

  @JsonKey(fromJson: _string)
  final String postId;

  /// The whole text so far, not a delta.
  @LenientString()
  final String? next;
  @LenientString()
  final String? control;

  /// Null when the event carries none or they can't be read.
  @JsonKey(name: 'tool_call', fromJson: _encodedToolCalls)
  final List<AgentToolCall>? toolCalls;
  @LenientString()
  final String? reasoning;
  @JsonKey(fromJson: _encodedCitations)
  final List<AgentCitation>? annotations;
}

/// A conversation of plugin 2.x, from `GET /conversations/{id}`.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class AgentConversation {
  const AgentConversation({
    this.id = '',
    this.userId = '',
    this.botId,
    this.channelId,
    this.rootPostId,
    this.title,
    this.turns = const [],
  });

  factory AgentConversation.fromJson(Map<String, Object?> json) =>
      _$AgentConversationFromJson(json);

  @JsonKey(fromJson: _string)
  final String id;

  /// Who asked: the one who may stop, regenerate and approve.
  @JsonKey(fromJson: _string)
  final String userId;
  @LenientString()
  final String? botId;
  @LenientString()
  final String? channelId;
  @LenientString()
  final String? rootPostId;
  @LenientString()
  final String? title;
  @JsonKey(fromJson: _turns)
  final List<AgentTurn> turns;
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class AgentTurn {
  const AgentTurn({
    this.id = '',
    this.postId,
    this.role = '',
    this.content = const [],
    this.sequence = 0,
    this.approvalState,
  });

  factory AgentTurn.fromJson(Map<String, Object?> json) =>
      _$AgentTurnFromJson(json);

  @JsonKey(fromJson: _string)
  final String id;
  @LenientString()
  final String? postId;

  /// `user`, `assistant` or `tool_result`.
  @JsonKey(fromJson: _string)
  final String role;
  @JsonKey(fromJson: _blocks)
  final List<AgentBlock> content;
  @JsonKey(fromJson: _int)
  final int sequence;

  /// `call`, `result` or `done`; only on a post's anchor turn.
  @LenientString()
  final String? approvalState;
}

/// One content block of a turn; [type] says which fields are set.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class AgentBlock {
  const AgentBlock({
    this.type = '',
    this.text,
    this.citations = const [],
    this.id,
    this.name,
    this.input,
    this.question,
    this.status,
    this.userInteraction,
    this.wouldAutoExecute,
    this.toolUseId,
    this.content,
    this.decidedAt,
  });

  factory AgentBlock.fromJson(Map<String, Object?> json) =>
      _$AgentBlockFromJson(json);

  @JsonKey(fromJson: _string)
  final String type;
  @LenientString()
  final String? text;
  @JsonKey(fromJson: _citations)
  final List<AgentCitation> citations;
  @LenientString()
  final String? id;
  @LenientString()
  final String? name;
  @JsonKey(fromJson: readableJson)
  final String? input;
  @JsonKey(readValue: _inputOf, fromJson: questionOf)
  final AgentQuestion? question;
  @LenientString()
  final String? status;
  @LenientString()
  final String? userInteraction;
  @LenientBool()
  final bool? wouldAutoExecute;
  @LenientString()
  final String? toolUseId;
  @JsonKey(fromJson: readableJson)
  final String? content;
  @LenientInt()
  final int? decidedAt;
}

/// The plugin's props on its posts.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class AgentPostProps {
  const AgentPostProps({
    this.llmRequesterUserId,
    this.conversationId,
    this.noRegen,
    this.pendingToolCall,
    this.pendingToolResult,
    this.reasoningSummary,
    this.annotations,
    this.botUsername,
    this.botDisplayName,
    this.targetPostId,
  });

  factory AgentPostProps.fromJson(Map<String, Object?> json) =>
      _$AgentPostPropsFromJson(json);

  @LenientString()
  final String? llmRequesterUserId;

  /// Set by plugin 2.x; the post then renders its conversation.
  @LenientString()
  final String? conversationId;
  @JsonKey(fromJson: _flag)
  final bool? noRegen;

  /// Legacy plugins keep tool calls in the post.
  @JsonKey(fromJson: _encodedToolCalls)
  final List<AgentToolCall>? pendingToolCall;
  @JsonKey(fromJson: _flag)
  final bool? pendingToolResult;
  @LenientString()
  final String? reasoningSummary;
  @JsonKey(fromJson: _encodedCitations)
  final List<AgentCitation>? annotations;

  /// Mention reminders: the agent to loop in, and where.
  @LenientString()
  final String? botUsername;
  @LenientString()
  final String? botDisplayName;
  @LenientString()
  final String? targetPostId;
}

/// Body of `POST /post/{id}/tool_call` and `/tool_result`.
@JsonSerializable(
  createFactory: false,
  fieldRename: FieldRename.snake,
  includeIfNull: false,
)
class AgentToolDecision {
  const AgentToolDecision({required this.acceptedToolIds, this.toolAnswers});

  final List<String> acceptedToolIds;
  final Map<String, AgentToolAnswer>? toolAnswers;

  Map<String, Object?> toJson() => _$AgentToolDecisionToJson(this);
}

@JsonSerializable(createFactory: false, includeIfNull: false)
class AgentToolAnswer {
  const AgentToolAnswer({required this.selected, this.custom});

  final List<String> selected;
  final String? custom;

  Map<String, Object?> toJson() => _$AgentToolAnswerToJson(this);
}

/// Body of `POST /channel/{id}/analyze`.
@JsonSerializable(
  createFactory: false,
  fieldRename: FieldRename.snake,
  includeIfNull: false,
)
class AgentAnalysisRequest {
  const AgentAnalysisRequest({
    this.analysisType = 'summarize_channel',
    this.days,
    this.unreadsOnly,
  });

  final String analysisType;
  final int? days;
  final bool? unreadsOnly;

  Map<String, Object?> toJson() => _$AgentAnalysisRequestToJson(this);
}

String _string(Object? json) => json is String ? json : '';

int _int(Object? json) => const LenientInt().fromJson(json) ?? 0;

bool? _flag(Object? json) => switch (json) {
  final bool v => v,
  'true' => true,
  'false' => false,
  _ => null,
};

AgentToolStatus _statusCode(Object? json) => json is String
    ? AgentToolStatus.fromName(json)
    : AgentToolStatus.fromCode(const LenientInt().fromJson(json));

/// Pure: [json] as indented JSON for reading; a string stays as sent.
String? readableJson(Object? json) {
  if (json == null) return null;
  if (json is String) return json;
  try {
    return const JsonEncoder.withIndent('  ').convert(json);
  } on Object {
    return null;
  }
}

Object? _argumentsOf(Map<dynamic, dynamic> json, String _) => json['arguments'];
Object? _inputOf(Map<dynamic, dynamic> json, String _) => json['input'];

/// Pure: a question from tool arguments (an object, or JSON in a string);
/// null when they are not one.
AgentQuestion? questionOf(Object? json) {
  final value = decodeJsonString(json);
  if (value is! Map<String, Object?>) return null;
  final question = decodeOrSkip(value, AgentQuestion.fromJson);
  return question != null && question.usable ? question : null;
}

List<T> _list<T extends Object>(
  Object? json,
  T Function(Map<String, Object?>) decode,
) => [
  if (json is List)
    for (final e in json)
      if (e is Map<String, Object?>) ?decodeOrSkip(e, decode),
];

List<AgentBot> _bots(Object? json) => _list(json, AgentBot.fromJson);
List<AgentQuestionOption> _options(Object? json) =>
    _list(json, AgentQuestionOption.fromJson);
List<AgentTurn> _turns(Object? json) => _list(json, AgentTurn.fromJson);
List<AgentBlock> _blocks(Object? json) => _list(json, AgentBlock.fromJson);
List<AgentCitation> _citations(Object? json) =>
    _list(json, AgentCitation.fromJson);

List<AgentToolCall>? _encodedToolCalls(Object? json) {
  final value = decodeJsonString(json);
  return value is List ? _list(value, AgentToolCall.fromJson) : null;
}

List<AgentCitation>? _encodedCitations(Object? json) {
  final value = decodeJsonString(json);
  return value is List ? _list(value, AgentCitation.fromJson) : null;
}

/// Pure: the threads of `GET /ai_threads`, unreadable ones skipped.
List<AgentThread> decodeAgentThreads(Object? json) =>
    _list(json, AgentThread.fromJson);
