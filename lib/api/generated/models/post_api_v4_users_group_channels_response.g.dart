// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v4_users_group_channels_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV4UsersGroupChannelsResponse
_$PostApiV4UsersGroupChannelsResponseFromJson(Map<String, dynamic> json) =>
    PostApiV4UsersGroupChannelsResponse(
      object1: json['<CHANNEL_ID>'] == null
          ? const []
          : const LenientListOfUser().fromJson(json['<CHANNEL_ID>']),
    );

Map<String, dynamic> _$PostApiV4UsersGroupChannelsResponseToJson(
  PostApiV4UsersGroupChannelsResponse instance,
) => <String, dynamic>{
  '<CHANNEL_ID>': const LenientListOfUser().toJson(instance.object1),
};
