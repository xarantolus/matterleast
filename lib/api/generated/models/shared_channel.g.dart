// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedChannel _$SharedChannelFromJson(Map<String, dynamic> json) =>
    SharedChannel(
      id: const LenientString().fromJson(json['id']),
      teamId: const LenientString().fromJson(json['team_id']),
      home: const LenientBool().fromJson(json['home']),
      readonly: const LenientBool().fromJson(json['readonly']),
      name: const LenientString().fromJson(json['name']),
      displayName: const LenientString().fromJson(json['display_name']),
      purpose: const LenientString().fromJson(json['purpose']),
      header: const LenientString().fromJson(json['header']),
      creatorId: const LenientString().fromJson(json['creator_id']),
      createAt: const MillisDateTime().fromJson(json['create_at']),
      updateAt: const MillisDateTime().fromJson(json['update_at']),
      remoteId: const LenientString().fromJson(json['remote_id']),
    );

Map<String, dynamic> _$SharedChannelToJson(SharedChannel instance) =>
    <String, dynamic>{
      'id': const LenientString().toJson(instance.id),
      'team_id': const LenientString().toJson(instance.teamId),
      'home': const LenientBool().toJson(instance.home),
      'readonly': const LenientBool().toJson(instance.readonly),
      'name': const LenientString().toJson(instance.name),
      'display_name': const LenientString().toJson(instance.displayName),
      'purpose': const LenientString().toJson(instance.purpose),
      'header': const LenientString().toJson(instance.header),
      'creator_id': const LenientString().toJson(instance.creatorId),
      'create_at': const MillisDateTime().toJson(instance.createAt),
      'update_at': const MillisDateTime().toJson(instance.updateAt),
      'remote_id': const LenientString().toJson(instance.remoteId),
    };
