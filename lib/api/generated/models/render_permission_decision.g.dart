// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'render_permission_decision.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RenderPermissionDecision _$RenderPermissionDecisionFromJson(
  Map<String, dynamic> json,
) => RenderPermissionDecision(
  allowed: const LenientBool().fromJson(json['allowed']),
  evaluated: const LenientBool().fromJson(json['evaluated']),
  reason: const LenientString().fromJson(json['reason']),
);

Map<String, dynamic> _$RenderPermissionDecisionToJson(
  RenderPermissionDecision instance,
) => <String, dynamic>{
  'allowed': const LenientBool().toJson(instance.allowed),
  'evaluated': const LenientBool().toJson(instance.evaluated),
  'reason': const LenientString().toJson(instance.reason),
};
