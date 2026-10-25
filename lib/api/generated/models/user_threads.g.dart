// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_threads.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserThreads _$UserThreadsFromJson(Map<String, dynamic> json) => UserThreads(
  threads: json['threads'] == null
      ? const []
      : const LenientListOfUserThread().fromJson(json['threads']),
  total: const LenientInt().fromJson(json['total']),
);

Map<String, dynamic> _$UserThreadsToJson(UserThreads instance) =>
    <String, dynamic>{
      'total': const LenientInt().toJson(instance.total),
      'threads': const LenientListOfUserThread().toJson(instance.threads),
    };
