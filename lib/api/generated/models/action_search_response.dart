// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'access_control_resource.dart';
import 'action_search_page.dart';
import 'action_search_result.dart';
import 'render_permission_decision.dart';

import 'package:matterleast/api/json/lenient_models.dart';
part 'action_search_response.g.dart';

@JsonSerializable()
class ActionSearchResponse {
  const ActionSearchResponse({
    this.results = const [],
    this.resource,
    this.decisions,
    this.page,
  });

  factory ActionSearchResponse.fromJson(Map<String, Object?> json) =>
      _$ActionSearchResponseFromJson(json);

  @LenientAccessControlResource()
  final AccessControlResource? resource;

  @LenientListOfActionSearchResult()
  final List<ActionSearchResult> results;

  @LenientMapOfRenderPermissionDecision()
  final Map<String, RenderPermissionDecision>? decisions;
  @LenientActionSearchPage()
  final ActionSearchPage? page;

  Map<String, Object?> toJson() => _$ActionSearchResponseToJson(this);
}
