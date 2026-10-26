// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_channel_bookmark_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateChannelBookmarkResponse _$UpdateChannelBookmarkResponseFromJson(
  Map<String, dynamic> json,
) => UpdateChannelBookmarkResponse(
  updated: const LenientChannelBookmarkWithFileInfo().fromJson(json['updated']),
  deleted: const LenientChannelBookmarkWithFileInfo().fromJson(json['deleted']),
);

Map<String, dynamic> _$UpdateChannelBookmarkResponseToJson(
  UpdateChannelBookmarkResponse instance,
) => <String, dynamic>{
  'updated': const LenientChannelBookmarkWithFileInfo().toJson(
    instance.updated,
  ),
  'deleted': const LenientChannelBookmarkWithFileInfo().toJson(
    instance.deleted,
  ),
};
