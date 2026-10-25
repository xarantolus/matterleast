// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'action.dart';

import 'package:matterleast/api/json/lenient_models.dart';
part 'action_search_result.g.dart';

@JsonSerializable()
class ActionSearchResult {
  const ActionSearchResult({this.action});

  factory ActionSearchResult.fromJson(Map<String, Object?> json) =>
      _$ActionSearchResultFromJson(json);

  @LenientAction()
  final Action? action;

  Map<String, Object?> toJson() => _$ActionSearchResultToJson(this);
}
