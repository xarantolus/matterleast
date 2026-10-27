// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

import 'package:matterleast/api/json/lenient_models.dart';
part 'user_autocomplete.g.dart';

@JsonSerializable()
class UserAutocomplete {
  const UserAutocomplete({this.users = const [], this.outOfChannel = const []});

  factory UserAutocomplete.fromJson(Map<String, Object?> json) =>
      _$UserAutocompleteFromJson(json);

  @LenientListOfUser()
  final List<User> users;
  @LenientListOfUser()
  @JsonKey(name: 'out_of_channel')
  final List<User> outOfChannel;

  Map<String, Object?> toJson() => _$UserAutocompleteToJson(this);
}
