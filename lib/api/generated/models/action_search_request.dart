// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'access_control_resource.dart';
import 'action_search_page.dart';
import 'action_search_subject.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'action_search_request.g.dart';

@JsonSerializable()
class ActionSearchRequest {
  const ActionSearchRequest({
    this.actions = const [],
    this.resource,
    this.subject,
    this.page,
  });

  factory ActionSearchRequest.fromJson(Map<String, Object?> json) =>
      _$ActionSearchRequestFromJson(json);

  @LenientAccessControlResource()
  final AccessControlResource? resource;
  @LenientStringList()
  final List<String> actions;
  @LenientActionSearchSubject()
  final ActionSearchSubject? subject;
  @LenientActionSearchPage()
  final ActionSearchPage? page;

  Map<String, Object?> toJson() => _$ActionSearchRequestToJson(this);
}
