// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_restore.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavedConversation _$SavedConversationFromJson(Map<String, dynamic> json) =>
    _SavedConversation(
      url: json['url'] as String,
      channelId: json['channelId'] as String,
      title: json['title'] as String,
      teamId: json['teamId'] as String?,
      rootId: json['rootId'] as String?,
    );

Map<String, dynamic> _$SavedConversationToJson(_SavedConversation instance) =>
    <String, dynamic>{
      'url': instance.url,
      'channelId': instance.channelId,
      'title': instance.title,
      'teamId': instance.teamId,
      'rootId': instance.rootId,
    };

_OpenConversations _$OpenConversationsFromJson(
  Map<String, dynamic> json,
) => _OpenConversations(
  open:
      (json['open'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, SavedConversation.fromJson(e as Map<String, dynamic>)),
      ) ??
      const <String, SavedConversation>{},
  closed:
      (json['closed'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, SavedConversation.fromJson(e as Map<String, dynamic>)),
      ) ??
      const <String, SavedConversation>{},
);

Map<String, dynamic> _$OpenConversationsToJson(_OpenConversations instance) =>
    <String, dynamic>{'open': instance.open, 'closed': instance.closed};
