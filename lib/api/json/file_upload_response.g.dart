// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_upload_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileUploadResponse _$FileUploadResponseFromJson(Map<String, dynamic> json) =>
    FileUploadResponse(
      fileInfos:
          (json['file_infos'] as List<dynamic>?)
              ?.map((e) => FileInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
