// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'package:matterleast/api/json/lenient.dart';
part 'autocomplete_suggestion.g.dart';

@JsonSerializable()
class AutocompleteSuggestion {
  const AutocompleteSuggestion({
    this.complete,
    this.suggestion,
    this.hint,
    this.description,
    this.iconData,
  });

  factory AutocompleteSuggestion.fromJson(Map<String, Object?> json) =>
      _$AutocompleteSuggestionFromJson(json);

  @LenientString()
  @JsonKey(name: 'Complete')
  final String? complete;

  @LenientString()
  @JsonKey(name: 'Suggestion')
  final String? suggestion;

  @LenientString()
  @JsonKey(name: 'Hint')
  final String? hint;

  @LenientString()
  @JsonKey(name: 'Description')
  final String? description;

  @LenientString()
  @JsonKey(name: 'IconData')
  final String? iconData;

  Map<String, Object?> toJson() => _$AutocompleteSuggestionToJson(this);
}
