// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_signals.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandidateInit _$CandidateInitFromJson(
  Map<String, dynamic> json,
) => CandidateInit(
  candidate: json['candidate'] == null ? '' : stringOrEmpty(json['candidate']),
  sdpMid: const LenientString().fromJson(json['sdpMid']),
  sdpMLineIndex: const LenientInt().fromJson(json['sdpMLineIndex']),
  usernameFragment: const LenientString().fromJson(json['usernameFragment']),
);

Map<String, dynamic> _$CandidateInitToJson(
  CandidateInit instance,
) => <String, dynamic>{
  'candidate': instance.candidate,
  'sdpMid': ?const LenientString().toJson(instance.sdpMid),
  'sdpMLineIndex': ?const LenientInt().toJson(instance.sdpMLineIndex),
  'usernameFragment': ?const LenientString().toJson(instance.usernameFragment),
};

SignalMessage _$SignalMessageFromJson(Map<String, dynamic> json) =>
    SignalMessage(
      type: json['type'] == null ? '' : stringOrEmpty(json['type']),
      sdp: json['sdp'] == null ? '' : stringOrEmpty(json['sdp']),
      candidate: _candidate(json['candidate']),
    );
