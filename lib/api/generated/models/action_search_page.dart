// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'action_search_page.g.dart';

@JsonSerializable()
class ActionSearchPage {
  const ActionSearchPage({this.nextToken});

  factory ActionSearchPage.fromJson(Map<String, Object?> json) =>
      _$ActionSearchPageFromJson(json);

  @LenientString()
  @JsonKey(name: 'next_token')
  final String? nextToken;

  Map<String, Object?> toJson() => _$ActionSearchPageToJson(this);
}
