// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'access_control_resource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccessControlResource _$AccessControlResourceFromJson(
  Map<String, dynamic> json,
) => AccessControlResource(
  type: const LenientString().fromJson(json['type']),
  id: const LenientString().fromJson(json['id']),
);

Map<String, dynamic> _$AccessControlResourceToJson(
  AccessControlResource instance,
) => <String, dynamic>{
  'type': const LenientString().toJson(instance.type),
  'id': const LenientString().toJson(instance.id),
};
