// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_search_subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionSearchSubject _$ActionSearchSubjectFromJson(Map<String, dynamic> json) =>
    ActionSearchSubject(
      id: const LenientString().fromJson(json['id']),
      type: const LenientString().fromJson(json['type']),
    );

Map<String, dynamic> _$ActionSearchSubjectToJson(
  ActionSearchSubject instance,
) => <String, dynamic>{
  'id': const LenientString().toJson(instance.id),
  'type': const LenientString().toJson(instance.type),
};
