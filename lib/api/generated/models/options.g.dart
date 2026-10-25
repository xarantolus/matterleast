// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Options _$OptionsFromJson(Map<String, dynamic> json) => Options(
  text: const LenientString().fromJson(json['text']),
  value: const LenientString().fromJson(json['value']),
);

Map<String, dynamic> _$OptionsToJson(Options instance) => <String, dynamic>{
  'text': const LenientString().toJson(instance.text),
  'value': const LenientString().toJson(instance.value),
};
