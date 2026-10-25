// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommandResponse _$CommandResponseFromJson(
  Map<String, dynamic> json,
) => CommandResponse(
  attachments: json['attachments'] == null
      ? const []
      : const LenientListOfMessageAttachment().fromJson(json['attachments']),
  responseType: const LenientString().fromJson(json['response_type']),
  text: const LenientString().fromJson(json['text']),
  username: const LenientString().fromJson(json['username']),
  channelId: const LenientString().fromJson(json['channel_id']),
  iconUrl: const LenientString().fromJson(json['icon_url']),
  type: const LenientString().fromJson(json['type']),
  props: const JsonMap().fromJson(json['props']),
  gotoLocation: const LenientString().fromJson(json['goto_location']),
  triggerId: const LenientString().fromJson(json['trigger_id']),
  skipSlackParsing: const LenientBool().fromJson(json['skip_slack_parsing']),
);

Map<String, dynamic> _$CommandResponseToJson(
  CommandResponse instance,
) => <String, dynamic>{
  'response_type': const LenientString().toJson(instance.responseType),
  'text': const LenientString().toJson(instance.text),
  'username': const LenientString().toJson(instance.username),
  'channel_id': const LenientString().toJson(instance.channelId),
  'icon_url': const LenientString().toJson(instance.iconUrl),
  'type': const LenientString().toJson(instance.type),
  'props': const JsonMap().toJson(instance.props),
  'goto_location': const LenientString().toJson(instance.gotoLocation),
  'trigger_id': const LenientString().toJson(instance.triggerId),
  'skip_slack_parsing': const LenientBool().toJson(instance.skipSlackParsing),
  'attachments': const LenientListOfMessageAttachment().toJson(
    instance.attachments,
  ),
};
