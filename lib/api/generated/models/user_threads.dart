// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user_thread.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'user_threads.g.dart';

@JsonSerializable()
class UserThreads {
  const UserThreads({this.threads = const [], this.total});

  factory UserThreads.fromJson(Map<String, Object?> json) =>
      _$UserThreadsFromJson(json);

  @LenientInt()
  final int? total;

  @LenientListOfUserThread()
  final List<UserThread> threads;

  Map<String, Object?> toJson() => _$UserThreadsToJson(this);
}
