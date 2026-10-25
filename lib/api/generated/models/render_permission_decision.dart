// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'render_permission_decision.g.dart';

@JsonSerializable()
class RenderPermissionDecision {
  const RenderPermissionDecision({this.allowed, this.evaluated, this.reason});

  factory RenderPermissionDecision.fromJson(Map<String, Object?> json) =>
      _$RenderPermissionDecisionFromJson(json);

  @LenientBool()
  final bool? allowed;

  @LenientBool()
  final bool? evaluated;

  @LenientString()
  final String? reason;

  Map<String, Object?> toJson() => _$RenderPermissionDecisionToJson(this);
}
