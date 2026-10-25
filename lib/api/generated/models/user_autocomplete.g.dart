// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_autocomplete.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAutocomplete _$UserAutocompleteFromJson(Map<String, dynamic> json) =>
    UserAutocomplete(
      users: json['users'] == null
          ? const []
          : const LenientListOfUser().fromJson(json['users']),
      outOfChannel: json['out_of_channel'] == null
          ? const []
          : const LenientListOfUser().fromJson(json['out_of_channel']),
    );

Map<String, dynamic> _$UserAutocompleteToJson(UserAutocomplete instance) =>
    <String, dynamic>{
      'users': const LenientListOfUser().toJson(instance.users),
      'out_of_channel': const LenientListOfUser().toJson(instance.outOfChannel),
    };
