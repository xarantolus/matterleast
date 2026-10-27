// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'api_v4_emoji_search_request_body.g.dart';

@JsonSerializable()
class ApiV4EmojiSearchRequestBody {
  const ApiV4EmojiSearchRequestBody({required this.term, this.prefixOnly});

  factory ApiV4EmojiSearchRequestBody.fromJson(Map<String, Object?> json) =>
      _$ApiV4EmojiSearchRequestBodyFromJson(json);

  final String term;
  @LenientString()
  @JsonKey(name: 'prefix_only')
  final String? prefixOnly;

  Map<String, Object?> toJson() => _$ApiV4EmojiSearchRequestBodyToJson(this);
}
