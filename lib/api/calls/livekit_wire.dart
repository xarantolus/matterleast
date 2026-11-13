import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:matterleast/api/json/calls.dart';
import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/domain/call_livekit_rules.dart';

part 'livekit_wire.g.dart';

/// The answer to asking for a place in a LiveKit call.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class LiveKitSession {
  const LiveKitSession({
    this.sessionId = '',
    this.token = '',
    this.url = '',
    this.botUserId = '',
  });

  factory LiveKitSession.fromJson(Map<String, Object?> json) =>
      _$LiveKitSessionFromJson(json);

  @JsonKey(fromJson: stringOrEmpty)
  final String sessionId;
  @JsonKey(fromJson: stringOrEmpty)
  final String token;

  /// The LiveKit server's signalling address.
  @JsonKey(fromJson: stringOrEmpty)
  final String url;

  /// The recording bot's user; it is in the room but not a person.
  @JsonKey(fromJson: stringOrEmpty)
  final String botUserId;

  bool get usable => sessionId.isNotEmpty && token.isNotEmpty && url.isNotEmpty;
}

/// What the plugin keeps in the LiveKit room's metadata.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class LiveKitRoomMetadata {
  const LiveKitRoomMetadata({this.hostId});

  factory LiveKitRoomMetadata.fromJson(Map<String, Object?> json) =>
      _$LiveKitRoomMetadataFromJson(json);

  /// Reads the room's metadata text; null when it isn't the plugin's.
  static LiveKitRoomMetadata? parse(String? text) {
    if (text == null || text.isEmpty) return null;
    try {
      final json = jsonDecode(text);
      return json is Map<String, Object?>
          ? LiveKitRoomMetadata.fromJson(json)
          : null;
    } on FormatException {
      return null;
    }
  }

  @LenientString()
  final String? hostId;
}

/// A reaction as it travels between clients on the `reaction` topic.
@JsonSerializable(createToJson: false)
class LiveKitReaction {
  const LiveKitReaction({this.emojiData});

  factory LiveKitReaction.fromJson(Map<String, Object?> json) =>
      _$LiveKitReactionFromJson(json);

  /// Reads a reaction's bytes; null when they aren't one.
  static LiveKitReaction? parse(List<int> bytes) {
    try {
      final json = jsonDecode(utf8.decode(bytes));
      return json is Map<String, Object?>
          ? LiveKitReaction.fromJson(json)
          : null;
    } on FormatException {
      return null;
    }
  }

  /// The text of a reaction: its short name, else the character.
  String? get emoji =>
      acceptedReaction(name: emojiData?.name, literal: emojiData?.literal);

  @JsonKey(fromJson: _emojiIn)
  final CallEmojiData? emojiData;
}

CallEmojiData? _emojiIn(Object? json) =>
    json is Map<String, Object?> ? CallEmojiData.fromJson(json) : null;

/// The bytes of our own reaction: [name] and the code points of
/// [character], at [timestamp] milliseconds.
List<int> liveKitReactionBytes(String name, String character, int timestamp) =>
    utf8.encode(
      jsonEncode({
        'emojiData': {
          'name': name,
          'unified': [for (final r in character.runes) r.toRadixString(16)]
              .join('-'),
        },
        'timestamp': timestamp,
      }),
    );
