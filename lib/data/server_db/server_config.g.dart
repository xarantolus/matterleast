// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoredPlugins _$StoredPluginsFromJson(Map<String, dynamic> json) =>
    StoredPlugins(
      manifests: json['manifests'] == null
          ? const []
          : const LenientListOfPluginManifestWebapp().fromJson(
              json['manifests'],
            ),
    );

TurnedOff _$TurnedOffFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TurnedOff', json, ($checkedConvert) {
      final val = TurnedOff(
        features: $checkedConvert(
          'features',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => $enumDecode(_$OptionalFeatureEnumMap, e))
                  .toSet() ??
              const {},
        ),
      );
      return val;
    });

Map<String, dynamic> _$TurnedOffToJson(TurnedOff instance) => <String, dynamic>{
  'features': instance.features
      .map((e) => _$OptionalFeatureEnumMap[e]!)
      .toList(),
};

const _$OptionalFeatureEnumMap = {
  OptionalFeature.customEmoji: 'customEmoji',
  OptionalFeature.customStatus: 'customStatus',
  OptionalFeature.acknowledgements: 'acknowledgements',
  OptionalFeature.fileSearch: 'fileSearch',
  OptionalFeature.commandSuggestions: 'commandSuggestions',
  OptionalFeature.fileUploads: 'fileUploads',
  OptionalFeature.postReminders: 'postReminders',
  OptionalFeature.groupMentions: 'groupMentions',
};
