// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommandResponse _$CommandResponseFromJson(Map<String, dynamic> json) =>
    CommandResponse(
      attachments: json['Attachments'] == null
          ? const []
          : const LenientListOfMessageAttachment().fromJson(
              json['Attachments'],
            ),
      responseType: const LenientString().fromJson(json['ResponseType']),
      text: const LenientString().fromJson(json['Text']),
      username: const LenientString().fromJson(json['Username']),
      iconUrl: const LenientString().fromJson(json['IconURL']),
      gotoLocation: const LenientString().fromJson(json['GotoLocation']),
    );

Map<String, dynamic> _$CommandResponseToJson(CommandResponse instance) =>
    <String, dynamic>{
      'ResponseType': const LenientString().toJson(instance.responseType),
      'Text': const LenientString().toJson(instance.text),
      'Username': const LenientString().toJson(instance.username),
      'IconURL': const LenientString().toJson(instance.iconUrl),
      'GotoLocation': const LenientString().toJson(instance.gotoLocation),
      'Attachments': const LenientListOfMessageAttachment().toJson(
        instance.attachments,
      ),
    };
