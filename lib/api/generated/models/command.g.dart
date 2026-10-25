// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Command _$CommandFromJson(Map<String, dynamic> json) => Command(
  id: const LenientString().fromJson(json['id']),
  token: const LenientString().fromJson(json['token']),
  createAt: const MillisDateTime().fromJson(json['create_at']),
  updateAt: const MillisDateTime().fromJson(json['update_at']),
  deleteAt: const MillisDateTime().fromJson(json['delete_at']),
  creatorId: const LenientString().fromJson(json['creator_id']),
  teamId: const LenientString().fromJson(json['team_id']),
  trigger: const LenientString().fromJson(json['trigger']),
  method: const LenientString().fromJson(json['method']),
  username: const LenientString().fromJson(json['username']),
  iconUrl: const LenientString().fromJson(json['icon_url']),
  autoComplete: const LenientBool().fromJson(json['auto_complete']),
  autoCompleteDesc: const LenientString().fromJson(json['auto_complete_desc']),
  autoCompleteHint: const LenientString().fromJson(json['auto_complete_hint']),
  displayName: const LenientString().fromJson(json['display_name']),
  description: const LenientString().fromJson(json['description']),
  url: const LenientString().fromJson(json['url']),
);

Map<String, dynamic> _$CommandToJson(Command instance) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'token': const LenientString().toJson(instance.token),
  'create_at': const MillisDateTime().toJson(instance.createAt),
  'update_at': const MillisDateTime().toJson(instance.updateAt),
  'delete_at': const MillisDateTime().toJson(instance.deleteAt),
  'creator_id': const LenientString().toJson(instance.creatorId),
  'team_id': const LenientString().toJson(instance.teamId),
  'trigger': const LenientString().toJson(instance.trigger),
  'method': const LenientString().toJson(instance.method),
  'username': const LenientString().toJson(instance.username),
  'icon_url': const LenientString().toJson(instance.iconUrl),
  'auto_complete': const LenientBool().toJson(instance.autoComplete),
  'auto_complete_desc': const LenientString().toJson(instance.autoCompleteDesc),
  'auto_complete_hint': const LenientString().toJson(instance.autoCompleteHint),
  'display_name': const LenientString().toJson(instance.displayName),
  'description': const LenientString().toJson(instance.description),
  'url': const LenientString().toJson(instance.url),
};
