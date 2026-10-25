// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'get_api_v4_files_file_id_link_response.g.dart';

@JsonSerializable()
class GetApiV4FilesFileIdLinkResponse {
  const GetApiV4FilesFileIdLinkResponse({this.link});

  factory GetApiV4FilesFileIdLinkResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV4FilesFileIdLinkResponseFromJson(json);

  @LenientString()
  final String? link;

  Map<String, Object?> toJson() =>
      _$GetApiV4FilesFileIdLinkResponseToJson(this);
}
