import 'package:json_annotation/json_annotation.dart';
import 'package:matterleast/api/generated/models/file_info.dart';

part 'file_upload_response.g.dart';

/// The answer to `POST /files`, which the generated client leaves out
/// because the request is multipart (`FileUploadResponse` in the spec).
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class FileUploadResponse {
  const FileUploadResponse({this.fileInfos = const []});

  factory FileUploadResponse.fromJson(Map<String, Object?> json) =>
      _$FileUploadResponseFromJson(json);

  final List<FileInfo> fileInfos;
}
