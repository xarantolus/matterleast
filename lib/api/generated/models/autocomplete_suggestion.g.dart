// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autocomplete_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AutocompleteSuggestion _$AutocompleteSuggestionFromJson(
  Map<String, dynamic> json,
) => AutocompleteSuggestion(
  complete: const LenientString().fromJson(json['Complete']),
  suggestion: const LenientString().fromJson(json['Suggestion']),
  hint: const LenientString().fromJson(json['Hint']),
  description: const LenientString().fromJson(json['Description']),
  iconData: const LenientString().fromJson(json['IconData']),
);

Map<String, dynamic> _$AutocompleteSuggestionToJson(
  AutocompleteSuggestion instance,
) => <String, dynamic>{
  'Complete': const LenientString().toJson(instance.complete),
  'Suggestion': const LenientString().toJson(instance.suggestion),
  'Hint': const LenientString().toJson(instance.hint),
  'Description': const LenientString().toJson(instance.description),
  'IconData': const LenientString().toJson(instance.iconData),
};
