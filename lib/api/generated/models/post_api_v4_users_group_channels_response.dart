// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

import 'package:matterleast/api/json/lenient_models.dart';
part 'post_api_v4_users_group_channels_response.g.dart';

@JsonSerializable()
class PostApiV4UsersGroupChannelsResponse {
  const PostApiV4UsersGroupChannelsResponse({this.object1 = const []});

  factory PostApiV4UsersGroupChannelsResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV4UsersGroupChannelsResponseFromJson(json);

  @LenientListOfUser()
  @JsonKey(name: '<CHANNEL_ID>')
  final List<User> object1;

  Map<String, Object?> toJson() =>
      _$PostApiV4UsersGroupChannelsResponseToJson(this);
}
