import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/json/client_config.dart';
import 'package:matterleast/api/json/lenient_models.dart';
import 'package:matterleast/domain/server_features.dart';

part 'server_config.g.dart';

/// Rows of the `config` table.
abstract final class ConfigKeys {
  static const clientConfig = 'client_config';
  static const license = 'license';

  /// `GET /plugins/webapp` as served, under [StoredPlugins].
  static const plugins = 'plugins';

  /// Features the server answered as unavailable this session.
  static const turnedOff = 'turned_off';
}

@JsonSerializable(createToJson: false)
class StoredPlugins {
  const StoredPlugins({this.manifests = const []});

  factory StoredPlugins.fromJson(Map<String, Object?> json) =>
      _$StoredPluginsFromJson(json);

  static Map<String, Object?> encode(List<api.PluginManifestWebapp> list) => {
    'manifests': [for (final m in list) m.toJson()],
  };

  @LenientListOfPluginManifestWebapp()
  final List<api.PluginManifestWebapp> manifests;
}

@JsonSerializable(checked: true)
class TurnedOff {
  const TurnedOff({this.features = const {}});

  factory TurnedOff.fromJson(Map<String, Object?> json) =>
      _$TurnedOffFromJson(json);

  /// The features in a stored row; none without one.
  static Set<OptionalFeature> of(String? json) => json == null
      ? const {}
      : TurnedOff.fromJson(FeaturesDecoder._object(json)).features;

  final Set<OptionalFeature> features;

  Map<String, Object?> toJson() => _$TurnedOffToJson(this);
}

/// Decodes the stored snapshots into [ServerFeatures], reusing the last
/// result while the rows are unchanged, since most views ask on every
/// emission.
class FeaturesDecoder {
  List<(String, String)>? _lastRows;
  ServerFeatures? _last;

  ServerFeatures call(Iterable<({String key, String json})> rows) {
    final key = [for (final r in rows) (r.key, r.json)];
    if (_last case final last? when _sameRows(key, _lastRows)) return last;
    final byKey = {for (final (k, json) in key) k: json};
    final features = serverFeatures(
      config: ClientConfig.fromJson(_object(byKey[ConfigKeys.clientConfig])),
      license: ClientLicense.fromJson(_object(byKey[ConfigKeys.license])),
      plugins: [
        for (final m in StoredPlugins.fromJson(
          _object(byKey[ConfigKeys.plugins]),
        ).manifests)
          if (m.id case final id? when id.isNotEmpty)
            (id: id, version: m.version ?? ''),
      ],
      turnedOff: TurnedOff.of(byKey[ConfigKeys.turnedOff]),
    );
    _lastRows = key;
    _last = features;
    return features;
  }

  static bool _sameRows(List<(String, String)> a, List<(String, String)>? b) {
    if (b == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static Map<String, Object?> _object(String? json) {
    final decoded = json == null ? null : jsonDecode(json);
    return decoded is Map<String, Object?> ? decoded : const {};
  }
}
