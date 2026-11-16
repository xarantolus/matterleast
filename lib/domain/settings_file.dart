import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/server_theme.dart';
import 'package:matterleast/domain/server_url.dart';

part 'settings_file.g.dart';

/// A server in the settings file: where to find it and how it looks here,
/// never a credential.
@JsonSerializable(disallowUnrecognizedKeys: true)
class FileServer {
  const FileServer({
    required this.url,
    required this.displayName,
    required this.sortOrder,
    required this.themeMode,
    this.ssoScheme,
  });

  factory FileServer.fromJson(Map<String, Object?> json) =>
      _$FileServerFromJson(json);

  final String url;
  final String displayName;
  final int sortOrder;
  final String themeMode;
  final String? ssoScheme;

  Map<String, Object?> toJson() => _$FileServerToJson(this);
}

/// The settings document the Storage page exports and imports.
@JsonSerializable(disallowUnrecognizedKeys: true)
class SettingsFile {
  const SettingsFile({
    required this.version,
    required this.servers,
    required this.settings,
    this.stayConnected,
  });

  factory SettingsFile.fromJson(Map<String, Object?> json) =>
      _$SettingsFileFromJson(json);

  static const currentVersion = 1;

  final int version;
  final List<FileServer> servers;

  /// [Settings.exported] by key, in each setting's own text form.
  final Map<String, String> settings;

  /// Present on Android only.
  final bool? stayConnected;

  Map<String, Object?> toJson() => _$SettingsFileToJson(this);
}

class SettingsFileException implements Exception {
  const SettingsFileException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// The file's name for [day], in the local time zone.
String settingsFileName(DateTime day) {
  final d = day.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return 'matterleast-settings-${d.year}-${two(d.month)}-${two(d.day)}.json';
}

final _scheme = RegExp(r'^[a-z][a-z0-9+.-]*$');

/// Builds the file's content from what is stored.
SettingsFile buildSettingsFile({
  required List<FileServer> servers,
  required Map<String, String> stored,
  required bool? stayConnected,
}) => SettingsFile(
  version: SettingsFile.currentVersion,
  servers: servers,
  settings: {
    for (final s in Settings.exported)
      s.key: stored[s.key] ?? s.encode(s.defaultValue),
  },
  stayConnected: stayConnected,
);

String encodeSettingsFile(SettingsFile file) =>
    const JsonEncoder.withIndent('  ').convert(file.toJson());

/// Reads and checks a settings file; throws [SettingsFileException] for
/// anything that isn't exactly what [encodeSettingsFile] writes.
SettingsFile parseSettingsFile(String text) {
  const notOurs = SettingsFileException(
    'This is not a Matterleast settings file.',
  );
  final Object? json;
  try {
    json = jsonDecode(text);
  } on FormatException {
    throw notOurs;
  }
  if (json is! Map<String, Object?>) throw notOurs;
  final version = json['version'];
  if (version is! int) throw notOurs;
  if (version != SettingsFile.currentVersion) {
    throw SettingsFileException(
      'This settings file is version $version; this app reads version '
      '${SettingsFile.currentVersion}.',
    );
  }
  final SettingsFile file;
  try {
    file = SettingsFile.fromJson(json);
  } on Object {
    throw notOurs;
  }
  final known = {for (final s in Settings.exported) s.key: s};
  for (final MapEntry(:key, :value) in file.settings.entries) {
    if (!(known[key]?.accepts(value) ?? false)) {
      throw SettingsFileException('The setting "$key" has an invalid value.');
    }
  }
  final servers = <FileServer>[];
  for (final server in file.servers) {
    final url = normalizeServerUrl(server.url)?.toString();
    final scheme = server.ssoScheme;
    if (url == null ||
        ThemeSource.values.every((t) => t.name != server.themeMode) ||
        (scheme != null && !_scheme.hasMatch(scheme))) {
      throw SettingsFileException('The server "${server.url}" is invalid.');
    }
    if (servers.any((s) => s.url == url)) continue;
    servers.add(
      FileServer(
        url: url,
        displayName: server.displayName,
        sortOrder: server.sortOrder,
        themeMode: server.themeMode,
        ssoScheme: scheme,
      ),
    );
  }
  return SettingsFile(
    version: file.version,
    servers: servers,
    settings: file.settings,
    stayConnected: file.stayConnected,
  );
}

/// What importing [file] would change, given what is stored. A null
/// [stayConnected] means this device has no such switch.
class ImportPlan {
  const ImportPlan({
    required this.add,
    required this.update,
    required this.settings,
    required this.stayConnected,
  });

  final List<FileServer> add;

  /// Servers already here whose colour or SSO scheme differs.
  final List<FileServer> update;

  /// Only the settings whose value differs.
  final Map<String, String> settings;
  final bool? stayConnected;

  bool get isEmpty =>
      add.isEmpty &&
      update.isEmpty &&
      settings.isEmpty &&
      stayConnected == null;
}

ImportPlan planImport(
  SettingsFile file, {
  required List<FileServer> servers,
  required Map<String, String> stored,
  required bool? stayConnected,
}) {
  final here = {for (final s in servers) s.url: s};
  final current = {
    for (final s in Settings.exported)
      s.key: stored[s.key] ?? s.encode(s.defaultValue),
  };
  return ImportPlan(
    add: [
      for (final s in file.servers)
        if (!here.containsKey(s.url)) s,
    ],
    update: [
      for (final s in file.servers)
        if (here[s.url] case final h?
            when h.themeMode != s.themeMode || h.ssoScheme != s.ssoScheme)
          s,
    ],
    settings: {
      for (final MapEntry(:key, :value) in file.settings.entries)
        if (current[key] != value) key: value,
    },
    stayConnected:
        stayConnected != null &&
            file.stayConnected != null &&
            file.stayConnected != stayConnected
        ? file.stayConnected
        : null,
  );
}

/// The changes of [plan] as a short list, one per line.
String importSummary(ImportPlan plan) {
  String hosts(List<FileServer> servers) => servers
      .map((s) => s.url.replaceFirst(RegExp('^https?://'), ''))
      .join(', ');
  return [
    if (plan.add.isNotEmpty)
      'Add ${plan.add.length == 1 ? 'server' : 'servers'} ${hosts(plan.add)}; '
          '${plan.add.length == 1 ? 'it needs' : 'they need'} signing in',
    if (plan.update.isNotEmpty) 'Change the colours of ${hosts(plan.update)}',
    if (plan.settings.isNotEmpty)
      'Change ${plan.settings.length} '
          '${plan.settings.length == 1 ? 'setting' : 'settings'}',
    if (plan.stayConnected case final on?)
      'Turn Stay connected ${on ? 'on' : 'off'}',
  ].join('\n');
}
