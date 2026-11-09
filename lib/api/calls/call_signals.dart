import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:matterleast/api/calls/msgpack.dart';
import 'package:matterleast/api/json/lenient.dart';

part 'call_signals.g.dart';

const callsActionPrefix = 'custom_com.mattermost.calls_';

/// One ICE candidate as it travels, both ways.
@JsonSerializable(includeIfNull: false)
class CandidateInit {
  const CandidateInit({
    this.candidate = '',
    this.sdpMid,
    this.sdpMLineIndex,
    this.usernameFragment,
  });

  factory CandidateInit.fromJson(Map<String, Object?> json) =>
      _$CandidateInitFromJson(json);

  @JsonKey(fromJson: stringOrEmpty)
  final String candidate;
  @LenientString()
  final String? sdpMid;
  @LenientInt()
  final int? sdpMLineIndex;
  @LenientString()
  final String? usernameFragment;

  Map<String, Object?> toJson() => _$CandidateInitToJson(this);
}

enum SignalKind { offer, answer, candidate, unknown }

/// What the server's `signal` events and data-channel SDP messages carry:
/// an offer, an answer or a candidate.
@JsonSerializable(createToJson: false)
class SignalMessage {
  const SignalMessage({this.type = '', this.sdp = '', this.candidate});

  factory SignalMessage.fromJson(Map<String, Object?> json) =>
      _$SignalMessageFromJson(json);

  /// Reads the JSON text of a signal; null when it isn't one.
  static SignalMessage? parse(Object? text) {
    if (text is! String) return null;
    try {
      final json = jsonDecode(text);
      return json is Map<String, Object?> ? SignalMessage.fromJson(json) : null;
    } on FormatException {
      return null;
    }
  }

  @JsonKey(fromJson: stringOrEmpty)
  final String type;
  @JsonKey(fromJson: stringOrEmpty)
  final String sdp;
  @JsonKey(fromJson: _candidate)
  final CandidateInit? candidate;

  SignalKind get kind => switch (type) {
    'offer' => SignalKind.offer,
    'answer' => SignalKind.answer,
    'candidate' => SignalKind.candidate,
    _ => SignalKind.unknown,
  };
}

CandidateInit? _candidate(Object? json) =>
    json is Map<String, Object?> ? CandidateInit.fromJson(json) : null;

/// The JSON text of our offer or answer.
String sessionDescriptionJson(String type, String sdp) =>
    jsonEncode({'type': type, 'sdp': sdp});

String candidateJson(CandidateInit candidate) => jsonEncode(candidate.toJson());

/// zlib, as the server expects for SDP text.
Uint8List compressSdp(String json) =>
    Uint8List.fromList(zlib.encode(utf8.encode(json)));

String inflateSdp(List<int> bytes) => utf8.decode(zlib.decode(bytes));

/// The binary frame that sends our SDP over the calls socket.
Uint8List sdpSocketFrame(int seq, String sdpJson) {
  final w = PackWriter()
    ..writeMapHeader(3)
    ..writeString('action')
    ..writeString('${callsActionPrefix}sdp')
    ..writeString('seq')
    ..writeUint(seq)
    ..writeString('data')
    ..writeMapHeader(1)
    ..writeString('data')
    ..writeBin(compressSdp(sdpJson));
  return w.takeBytes();
}

/// An action as a JSON text frame.
String actionFrame(String name, int seq, [Map<String, Object?>? data]) =>
    jsonEncode({'action': '$callsActionPrefix$name', 'seq': seq, 'data': ?data});

/// A message on the `calls-dc` data channel: a type, then its payload.
sealed class DcMessage {
  const DcMessage();
}

final class DcPing extends DcMessage {
  const DcPing();
}

final class DcPong extends DcMessage {
  const DcPong();
}

final class DcSdp extends DcMessage {
  const DcSdp(this.json);
  final String json;
}

/// Our request for the signalling lock; there is no payload.
final class DcLockRequest extends DcMessage {
  const DcLockRequest();
}

/// The server's answer to a lock request.
final class DcLockReply extends DcMessage {
  const DcLockReply({required this.granted});
  final bool granted;
}

final class DcUnlock extends DcMessage {
  const DcUnlock();
}

/// For each audio section's `mid`, what the server sends on it.
final class DcMediaMap extends DcMessage {
  const DcMediaMap(this.kinds);
  final Map<String, String> kinds;
}

/// A message of a type we don't use, or one that doesn't parse (type 0).
final class DcUnknown extends DcMessage {
  const DcUnknown(this.type);
  final int type;
}

const _typePing = 1;
const _typePong = 2;
const _typeSdp = 3;
const _typeLock = 7;
const _typeUnlock = 8;
const _typeMediaMap = 9;

/// The bytes of a message we send.
Uint8List encodeDc(DcMessage message) {
  final w = PackWriter();
  switch (message) {
    case DcPing():
      w.writeUint(_typePing);
    case DcSdp(:final json):
      w
        ..writeUint(_typeSdp)
        ..writeBin(compressSdp(json));
    case DcLockRequest():
      w.writeUint(_typeLock);
    case DcUnlock():
      w.writeUint(_typeUnlock);
    case DcPong() || DcLockReply() || DcMediaMap() || DcUnknown():
      throw ArgumentError.value(message, 'message', 'only the server sends it');
  }
  return w.takeBytes();
}

DcMessage decodeDc(Uint8List bytes) {
  try {
    final r = PackReader(bytes);
    final type = r.read();
    if (type is! int) return const DcUnknown(0);
    return switch (type) {
      _typePing => const DcPing(),
      _typePong => const DcPong(),
      _typeSdp => switch (r.read()) {
        final Uint8List bin => DcSdp(inflateSdp(bin)),
        _ => const DcUnknown(_typeSdp),
      },
      _typeLock => switch (r.atEnd ? null : r.read()) {
        final bool granted => DcLockReply(granted: granted),
        _ => const DcLockRequest(),
      },
      _typeUnlock => const DcUnlock(),
      _typeMediaMap => switch (r.read()) {
        final Map<String, Object?> map => DcMediaMap({
          for (final e in map.entries)
            if (e.value case {'type': final String kind}) e.key: kind,
        }),
        _ => const DcUnknown(_typeMediaMap),
      },
      _ => DcUnknown(type),
    };
  } on FormatException {
    return const DcUnknown(0);
  } on ArgumentError {
    return const DcUnknown(0);
  }
}
