// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agents.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentBot _$AgentBotFromJson(Map<String, dynamic> json) => AgentBot(
  id: json['id'] == null ? '' : _string(json['id']),
  displayName: json['displayName'] == null ? '' : _string(json['displayName']),
  username: json['username'] == null ? '' : _string(json['username']),
  lastIconUpdate: const LenientInt().fromJson(json['lastIconUpdate']),
  isDefault: const LenientBool().fromJson(json['isDefault']),
  isDefaultSnake: const LenientBool().fromJson(json['is_default']),
);

AgentBotsAnswer _$AgentBotsAnswerFromJson(Map<String, dynamic> json) =>
    AgentBotsAnswer(
      bots: json['bots'] == null ? const [] : _bots(json['bots']),
    );

AgentThread _$AgentThreadFromJson(Map<String, dynamic> json) => AgentThread(
  id: json['id'] == null ? '' : _string(json['id']),
  title: const LenientString().fromJson(json['title']),
  message: const LenientString().fromJson(json['message']),
  channelId: const LenientString().fromJson(json['channel_id']),
  rootPostId: const LenientString().fromJson(json['root_post_id']),
  botId: const LenientString().fromJson(json['bot_id']),
  replyCount: const LenientInt().fromJson(json['reply_count']),
  updateAt: const MillisDateTime().fromJson(json['update_at']),
);

AgentAnalysisAnswer _$AgentAnalysisAnswerFromJson(Map<String, dynamic> json) =>
    AgentAnalysisAnswer(
      postId: const LenientString().fromJson(json['postid']),
      channelId: const LenientString().fromJson(json['channelid']),
    );

AgentQuestionOption _$AgentQuestionOptionFromJson(Map<String, dynamic> json) =>
    AgentQuestionOption(
      label: json['label'] == null ? '' : _string(json['label']),
      description: const LenientString().fromJson(json['description']),
    );

AgentQuestion _$AgentQuestionFromJson(Map<String, dynamic> json) =>
    AgentQuestion(
      question: json['question'] == null ? '' : _string(json['question']),
      options: json['options'] == null ? const [] : _options(json['options']),
      multiSelect: const LenientBool().fromJson(json['multi_select']),
      allowFreeForm: const LenientBool().fromJson(json['allow_free_form']),
    );

AgentToolCall _$AgentToolCallFromJson(Map<String, dynamic> json) =>
    AgentToolCall(
      id: json['id'] == null ? '' : _string(json['id']),
      name: json['name'] == null ? '' : _string(json['name']),
      description: const LenientString().fromJson(json['description']),
      arguments: readableJson(json['arguments']),
      question: questionOf(_argumentsOf(json, 'question')),
      result: readableJson(json['result']),
      status: json['status'] == null
          ? AgentToolStatus.pending
          : _statusCode(json['status']),
      userInteraction: const LenientString().fromJson(json['user_interaction']),
      wouldAutoExecute: const LenientBool().fromJson(
        json['would_auto_execute'],
      ),
    );

AgentCitation _$AgentCitationFromJson(Map<String, dynamic> json) =>
    AgentCitation(
      url: json['url'] == null ? '' : _string(json['url']),
      title: json['title'] == null ? '' : _string(json['title']),
    );

AgentPostUpdate _$AgentPostUpdateFromJson(Map<String, dynamic> json) =>
    AgentPostUpdate(
      postId: json['post_id'] == null ? '' : _string(json['post_id']),
      next: const LenientString().fromJson(json['next']),
      control: const LenientString().fromJson(json['control']),
      toolCalls: _encodedToolCalls(json['tool_call']),
      reasoning: const LenientString().fromJson(json['reasoning']),
      annotations: _encodedCitations(json['annotations']),
    );

AgentConversation _$AgentConversationFromJson(Map<String, dynamic> json) =>
    AgentConversation(
      id: json['id'] == null ? '' : _string(json['id']),
      userId: json['user_id'] == null ? '' : _string(json['user_id']),
      botId: const LenientString().fromJson(json['bot_id']),
      channelId: const LenientString().fromJson(json['channel_id']),
      rootPostId: const LenientString().fromJson(json['root_post_id']),
      title: const LenientString().fromJson(json['title']),
      turns: json['turns'] == null ? const [] : _turns(json['turns']),
    );

AgentTurn _$AgentTurnFromJson(Map<String, dynamic> json) => AgentTurn(
  id: json['id'] == null ? '' : _string(json['id']),
  postId: const LenientString().fromJson(json['post_id']),
  role: json['role'] == null ? '' : _string(json['role']),
  content: json['content'] == null ? const [] : _blocks(json['content']),
  sequence: json['sequence'] == null ? 0 : _int(json['sequence']),
  approvalState: const LenientString().fromJson(json['approval_state']),
);

AgentBlock _$AgentBlockFromJson(Map<String, dynamic> json) => AgentBlock(
  type: json['type'] == null ? '' : _string(json['type']),
  text: const LenientString().fromJson(json['text']),
  citations: json['citations'] == null
      ? const []
      : _citations(json['citations']),
  id: const LenientString().fromJson(json['id']),
  name: const LenientString().fromJson(json['name']),
  input: readableJson(json['input']),
  question: questionOf(_inputOf(json, 'question')),
  status: const LenientString().fromJson(json['status']),
  userInteraction: const LenientString().fromJson(json['user_interaction']),
  wouldAutoExecute: const LenientBool().fromJson(json['would_auto_execute']),
  toolUseId: const LenientString().fromJson(json['tool_use_id']),
  content: readableJson(json['content']),
  decidedAt: const LenientInt().fromJson(json['decided_at']),
);

AgentPostProps _$AgentPostPropsFromJson(Map<String, dynamic> json) =>
    AgentPostProps(
      llmRequesterUserId: const LenientString().fromJson(
        json['llm_requester_user_id'],
      ),
      conversationId: const LenientString().fromJson(json['conversation_id']),
      noRegen: _flag(json['no_regen']),
      pendingToolCall: _encodedToolCalls(json['pending_tool_call']),
      pendingToolResult: _flag(json['pending_tool_result']),
      reasoningSummary: const LenientString().fromJson(
        json['reasoning_summary'],
      ),
      annotations: _encodedCitations(json['annotations']),
      botUsername: const LenientString().fromJson(json['bot_username']),
      botDisplayName: const LenientString().fromJson(json['bot_display_name']),
      targetPostId: const LenientString().fromJson(json['target_post_id']),
    );

Map<String, dynamic> _$AgentToolDecisionToJson(AgentToolDecision instance) =>
    <String, dynamic>{
      'accepted_tool_ids': instance.acceptedToolIds,
      'tool_answers': ?instance.toolAnswers,
    };

Map<String, dynamic> _$AgentToolAnswerToJson(AgentToolAnswer instance) =>
    <String, dynamic>{
      'selected': instance.selected,
      'custom': ?instance.custom,
    };

Map<String, dynamic> _$AgentAnalysisRequestToJson(
  AgentAnalysisRequest instance,
) => <String, dynamic>{
  'analysis_type': instance.analysisType,
  'days': ?instance.days,
  'unreads_only': ?instance.unreadsOnly,
};
