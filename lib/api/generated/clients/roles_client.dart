// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/role.dart';

part 'roles_client.g.dart';

@RestApi()
abstract class RolesClient {
  factory RolesClient(Dio dio, {String? baseUrl}) = _RolesClient;

  @POST('/api/v4/roles/names')
  Future<List<Role>> getRolesByNames({@Body() required List<String> body});
}
