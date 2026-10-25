// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_v4_emoji_search_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiV4EmojiSearchRequestBody _$ApiV4EmojiSearchRequestBodyFromJson(
  Map<String, dynamic> json,
) => ApiV4EmojiSearchRequestBody(
  term: json['term'] as String,
  prefixOnly: const LenientString().fromJson(json['prefix_only']),
);

Map<String, dynamic> _$ApiV4EmojiSearchRequestBodyToJson(
  ApiV4EmojiSearchRequestBody instance,
) => <String, dynamic>{
  'term': instance.term,
  'prefix_only': const LenientString().toJson(instance.prefixOnly),
};
