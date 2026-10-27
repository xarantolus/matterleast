import 'dart:convert';

import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/domain/conversation_restore.dart';
import 'package:matterleast/domain/desktop_window.dart';
import 'package:matterleast/domain/message_text_size.dart';
import 'package:matterleast/domain/rail.dart';

/// One typed setting: its key, default and text encoding. Settings are
/// declared once in [Settings] and read or written only through
/// [SettingsStore].
class Setting<T> {
  const Setting(this.key, this.defaultValue, this._decode, this._encode);

  final String key;
  final T defaultValue;
  final T Function(String raw) _decode;
  final String Function(T value) _encode;

  T read(Map<String, String> raw) {
    final stored = raw[key];
    if (stored == null) return defaultValue;
    try {
      return _decode(stored);
    } on FormatException {
      return defaultValue;
    }
  }

  String encode(T value) => _encode(value);
}

abstract final class Settings {
  static const mebibyte = 1024 * 1024;

  /// Automatic image loading on metered networks.
  static const imagesOnMobileData = Setting<bool>(
    'imagesOnMobileData',
    true,
    _decodeBool,
    _encodeBool,
  );

  static const mediaCacheBytes = Setting<int>(
    'mediaCacheBytes',
    250 * mebibyte,
    int.parse,
    _encodeInt,
  );

  static const filesCacheBytes = Setting<int>(
    'filesCacheBytes',
    500 * mebibyte,
    int.parse,
    _encodeInt,
  );

  /// Local post retention without a server policy, in days.
  static const keepDays = Setting<int>('keepDays', 30, int.parse, _encodeInt);

  /// Posts always kept per channel opened in the last [keepDays].
  static const keepPostsPerChannel = Setting<int>(
    'keepPostsPerChannel',
    200,
    int.parse,
    _encodeInt,
  );

  static const use24HourClock = Setting<bool?>(
    'use24HourClock',
    null,
    _decodeOptionalBool,
    _encodeOptionalBool,
  );

  static const messageTextSize = Setting<MessageTextSize>(
    'messageTextSize',
    MessageTextSize.normal,
    _decodeTextSize,
    _encodeName,
  );

  /// Code blocks start wrapped instead of scrolling sideways.
  static const wrapCode = Setting<bool>(
    'wrapCode',
    false,
    _decodeBool,
    _encodeBool,
  );

  /// The app explained notifications and asked for the permission once;
  /// after that only the settings ask.
  static const notificationsAsked = Setting<bool>(
    'notificationsAsked',
    false,
    _decodeBool,
    _encodeBool,
  );

  /// What the rail showed last, reopened at launch; null is Home.
  static const lastRailTarget = Setting<RailTarget?>(
    'lastRailTarget',
    null,
    _decodeRailTarget,
    _encodeRailTarget,
  );

  /// The conversation open on top when the app last ran, reopened at
  /// launch; null when the channel list showed.
  static const lastConversation = Setting<SavedConversation?>(
    'lastConversation',
    null,
    _decodeConversation,
    _encodeConversation,
  );

  /// Closing the desktop window keeps the app running in the tray.
  static const closeToTray = Setting<bool>(
    'closeToTray',
    true,
    _decodeBool,
    _encodeBool,
  );

  /// Where the desktop window was when last moved or resized.
  static const windowPlacement = Setting<WindowPlacement?>(
    'windowPlacement',
    null,
    _decodeWindowPlacement,
    _encodeWindowPlacement,
  );

  static const all = <Setting<Object?>>[
    imagesOnMobileData,
    mediaCacheBytes,
    filesCacheBytes,
    keepDays,
    keepPostsPerChannel,
    use24HourClock,
    messageTextSize,
    wrapCode,
    notificationsAsked,
    lastRailTarget,
    lastConversation,
    closeToTray,
    windowPlacement,
  ];

  static bool _decodeBool(String raw) => switch (raw) {
    'true' => true,
    'false' => false,
    _ => throw FormatException('bool', raw),
  };
  static String _encodeBool(bool value) => value.toString();
  static bool? _decodeOptionalBool(String raw) =>
      raw == 'system' ? null : _decodeBool(raw);
  static String _encodeOptionalBool(bool? value) =>
      value == null ? 'system' : value.toString();
  static String _encodeInt(int value) => value.toString();
  static MessageTextSize _decodeTextSize(String raw) =>
      MessageTextSize.values.where((s) => s.name == raw).firstOrNull ??
      (throw FormatException('text size', raw));
  static String _encodeName(Enum value) => value.name;
  static RailTarget? _decodeRailTarget(String raw) {
    if (raw.isEmpty) return null;
    try {
      if (jsonDecode(raw) case final Map<String, Object?> json) {
        return RailTarget.fromJson(json);
      }
    } on Object {
      // Falls through to the format error below.
    }
    throw FormatException('rail target', raw);
  }

  static SavedConversation? _decodeConversation(String raw) {
    if (raw.isEmpty) return null;
    try {
      if (jsonDecode(raw) case final Map<String, Object?> json) {
        return SavedConversation.fromJson(json);
      }
    } on Object {
      // Falls through to the format error below.
    }
    throw FormatException('conversation', raw);
  }

  static WindowPlacement? _decodeWindowPlacement(String raw) {
    if (raw.isEmpty) return null;
    try {
      if (jsonDecode(raw) case final Map<String, Object?> json) {
        return WindowPlacement.fromJson(json);
      }
    } on Object {
      // Falls through to the format error below.
    }
    throw FormatException('window placement', raw);
  }

  static String _encodeWindowPlacement(WindowPlacement? value) =>
      value == null ? '' : jsonEncode(value.toJson());

  static String _encodeConversation(SavedConversation? value) =>
      value == null ? '' : jsonEncode(value.toJson());

  static String _encodeRailTarget(RailTarget? value) =>
      value == null ? '' : jsonEncode(value.toJson());
}

/// The one place that touches the settings table.
class SettingsStore {
  SettingsStore(this._db);

  final AppDatabase _db;

  Future<T> read<T>(Setting<T> setting) async =>
      setting.read(await _db.allSettings());

  Stream<T> watch<T>(Setting<T> setting) =>
      _db.watchSettings().map(setting.read).distinct();

  Future<void> write<T>(Setting<T> setting, T value) =>
      _db.writeSetting(setting.key, setting.encode(value));
}
