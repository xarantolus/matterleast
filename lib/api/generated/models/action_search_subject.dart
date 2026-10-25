// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'action_search_subject.g.dart';

@JsonSerializable()
class ActionSearchSubject {
  const ActionSearchSubject({this.id, this.type});

  factory ActionSearchSubject.fromJson(Map<String, Object?> json) =>
      _$ActionSearchSubjectFromJson(json);

  @LenientString()
  final String? id;
  @LenientString()
  final String? type;

  Map<String, Object?> toJson() => _$ActionSearchSubjectToJson(this);
}
