// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_v4_emoji_search_request_body.dart';
import '../models/emoji.dart';

part 'emoji_client.g.dart';

@RestApi()
abstract class EmojiClient {
  factory EmojiClient(Dio dio, {String? baseUrl}) = _EmojiClient;

  @MultiPart()
  @POST('/api/v4/emoji')
  Future<Emoji> createEmoji({
    @Part(name: 'image') required File image,
    @Part(name: 'emoji') required String emoji,
  });

  @GET('/api/v4/emoji')
  Future<Emoji> getEmojiList({
    @Query('page') int? page = 0,
    @Query('per_page') int? perPage = 60,
    @Query('sort') String? sort = '',
  });

  @GET('/api/v4/emoji/{emoji_id}')
  Future<Emoji> getEmoji({@Path('emoji_id') required String emojiId});

  @DELETE('/api/v4/emoji/{emoji_id}')
  Future<Emoji> deleteEmoji({@Path('emoji_id') required String emojiId});

  @GET('/api/v4/emoji/name/{emoji_name}')
  Future<Emoji> getEmojiByName({@Path('emoji_name') required String emojiName});

  @POST('/api/v4/emoji/search')
  Future<List<Emoji>> searchEmoji({
    @Body() required ApiV4EmojiSearchRequestBody body,
  });

  @GET('/api/v4/emoji/autocomplete')
  Future<List<Emoji>> autocompleteEmoji({@Query('name') required String name});
}
