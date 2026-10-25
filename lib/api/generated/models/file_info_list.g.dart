// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_info_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileInfoList _$FileInfoListFromJson(Map<String, dynamic> json) => FileInfoList(
  fileInfos: const LenientMapOfFileInfo().fromJson(json['file_infos']),
  nextFileId: const LenientString().fromJson(json['next_file_id']),
  prevFileId: const LenientString().fromJson(json['prev_file_id']),
  order: json['order'] == null
      ? const []
      : const LenientStringList().fromJson(json['order']),
);

Map<String, dynamic> _$FileInfoListToJson(FileInfoList instance) =>
    <String, dynamic>{
      'order': const LenientStringList().toJson(instance.order),
      'file_infos': const LenientMapOfFileInfo().toJson(instance.fileInfos),
      'next_file_id': const LenientString().toJson(instance.nextFileId),
      'prev_file_id': const LenientString().toJson(instance.prevFileId),
    };
