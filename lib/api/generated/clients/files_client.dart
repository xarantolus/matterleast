// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_v4_files_search_request_body.dart';
import '../models/file_info.dart';
import '../models/file_info_list.dart';
import '../models/get_api_v4_files_file_id_link_response.dart';

part 'files_client.g.dart';

@RestApi()
abstract class FilesClient {
  factory FilesClient(Dio dio, {String? baseUrl}) = _FilesClient;

  @GET('/api/v4/files/{file_id}/link')
  Future<GetApiV4FilesFileIdLinkResponse> getFileLink({
    @Path('file_id') required String fileId,
  });

  @GET('/api/v4/files/{file_id}/info')
  Future<FileInfo> getFileInfo({@Path('file_id') required String fileId});

  @POST('/api/v4/files/search')
  Future<FileInfoList> searchFilesAllTeams({
    @Body() required ApiV4FilesSearchRequestBody body,
  });
}
