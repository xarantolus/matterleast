// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'file_info.dart';

import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/json/lenient_models.dart';
part 'file_info_list.g.dart';

@JsonSerializable()
class FileInfoList {
  const FileInfoList({
    this.fileInfos,
    this.nextFileId,
    this.prevFileId,
    this.order = const [],
  });

  factory FileInfoList.fromJson(Map<String, Object?> json) =>
      _$FileInfoListFromJson(json);

  @LenientStringList()
  final List<String> order;
  @LenientMapOfFileInfo()
  @JsonKey(name: 'file_infos')
  final Map<String, FileInfo>? fileInfos;

  @LenientString()
  @JsonKey(name: 'next_file_id')
  final String? nextFileId;

  @LenientString()
  @JsonKey(name: 'prev_file_id')
  final String? prevFileId;

  Map<String, Object?> toJson() => _$FileInfoListToJson(this);
}
