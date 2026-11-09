import 'dart:async';

import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:matterleast/api/calls/livekit_wire.dart';
import 'package:matterleast/data/calls/call_room.dart';
import 'package:matterleast/domain/call_livekit_rules.dart';
import 'package:matterleast/log.dart';

const _handKey = 'raised_hand';
const _botKey = 'bot';
const _reactionTopic = 'reaction';

/// [CallRoom] on LiveKit's own SDK.
class LiveKitCallRoom implements CallRoom {
  LiveKitCallRoom() : _room = _newRoom() {
    _stopListening = _room.events.listen(_onEvent);
  }

  static lk.Room _newRoom() => lk.Room(
    roomOptions: const lk.RoomOptions(
      adaptiveStream: false,
      dynacast: false,
      defaultAudioPublishOptions: lk.AudioPublishOptions(dtx: true, red: true),
    ),
  );

  final lk.Room _room;
  late final lk.CancelListenFunc _stopListening;
  final _notes = StreamController<RoomNote>.broadcast();
  lk.LocalAudioTrack? _microphone;
  var _wantMuted = true;
  var _closed = false;

  @override
  Stream<RoomNote> get notes => _notes.stream;

  bool _bot(lk.Participant p) => p.attributes[_botKey] == 'true';

  bool _muted(lk.Participant p) =>
      p.getTrackPublicationBySource(lk.TrackSource.microphone)?.muted ?? true;

  int _hand(lk.Participant p) =>
      int.tryParse(p.attributes[_handKey] ?? '') ?? 0;

  RoomMember _member(lk.Participant p) =>
      (identity: p.identity, muted: _muted(p), raisedAt: _hand(p));

  @override
  Future<void> connect(String url, String token) async {
    await _room.connect(url, token);
    if (_closed) return;
    _notes.add(
      RoomEntered([
        for (final p in <lk.Participant>[
          ?_room.localParticipant,
          ..._room.remoteParticipants.values,
        ])
          if (!_bot(p)) _member(p),
      ]),
    );
    _hostFrom(_room.metadata);
  }

  void _hostFrom(String? metadata) {
    final host = LiveKitRoomMetadata.parse(metadata)?.hostId;
    if (host != null && host.isNotEmpty) _notes.add(RoomHost(host));
  }

  void _onEvent(lk.RoomEvent event) {
    if (_closed) return;
    switch (event) {
      case lk.RoomReconnectingEvent() || lk.RoomResumingEvent():
        _notes.add(const RoomReconnecting());
      case lk.RoomReconnectedEvent():
        _notes.add(const RoomReconnected());
      case lk.RoomDisconnectedEvent(:final reason):
        _notes.add(
          RoomClosed(switch (reason) {
            lk.DisconnectReason.roomDeleted => RoomLeft.callEnded,
            lk.DisconnectReason.participantRemoved => RoomLeft.removed,
            _ => RoomLeft.other,
          }),
        );
      case lk.ParticipantConnectedEvent(:final participant):
        if (!_bot(participant)) _notes.add(MemberEntered(_member(participant)));
      case lk.ParticipantDisconnectedEvent(:final participant):
        if (!_bot(participant)) _notes.add(MemberLeft(participant.identity));
      case lk.TrackMutedEvent(:final participant, :final publication):
        _muteChanged(participant, publication, muted: true);
      case lk.TrackUnmutedEvent(:final participant, :final publication):
        _muteChanged(participant, publication, muted: false);
      case lk.LocalTrackPublishedEvent(:final participant, :final publication):
        _muteChanged(participant, publication, muted: publication.muted);
      case lk.ParticipantAttributesChanged(
        :final participant,
        :final attributes,
      ):
        if (attributes.containsKey(_handKey) && !_bot(participant)) {
          _notes.add(MemberHand(participant.identity, _hand(participant)));
        }
      case lk.ActiveSpeakersChangedEvent(:final speakers):
        _notes.add(
          RoomSpeakers({
            for (final p in speakers)
              if (!_bot(p)) p.identity,
          }),
        );
      case lk.DataReceivedEvent(:final participant, :final data, :final topic):
        if (topic != _reactionTopic || participant == null) {
          return;
        }
        final emoji = LiveKitReaction.parse(data)?.emoji;
        if (emoji != null) {
          _notes.add(MemberReacted(participant.identity, emoji));
        }
      case lk.RoomMetadataChangedEvent(:final metadata):
        _hostFrom(metadata);
      default:
    }
  }

  void _muteChanged(
    lk.Participant participant,
    lk.TrackPublication<lk.Track> publication, {
    required bool muted,
  }) {
    if (publication.source != lk.TrackSource.microphone || _bot(participant)) {
      return;
    }
    _notes.add(MemberMuted(participant.identity, muted: muted));
  }

  @override
  Future<bool> openMicrophone() async {
    try {
      final track = await lk.LocalAudioTrack.create(
        const lk.AudioCaptureOptions(),
      );
      if (_closed) {
        await track.stop();
        return false;
      }
      // Silent from the start; muting a track that is not yet published
      // would release its capture, and there would be nothing to publish.
      await track.disable();
      _microphone = track;
      await _room.localParticipant?.publishAudioTrack(track);
      if (_wantMuted) {
        await track.mute();
      } else {
        await track.unmute();
      }
      return true;
    } on Object catch (e) {
      Log.warn('calls', 'The microphone could not be published', e);
      return false;
    }
  }

  @override
  Future<void> setMuted({required bool muted}) async {
    _wantMuted = muted;
    final track = _microphone;
    if (track == null) return;
    if (muted) {
      await track.mute();
    } else {
      await track.unmute();
    }
  }

  @override
  Future<void> setHand(int raisedAt) async {
    await _room.localParticipant?.setAttributes({
      _handKey: raisedAt > 0 ? '$raisedAt' : '',
    });
  }

  @override
  Future<void> react(String name, String character, int timestamp) async {
    await _room.localParticipant?.publishData(
      liveKitReactionBytes(name, character, timestamp),
      reliable: true,
      topic: _reactionTopic,
    );
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _stopListening();
    await _notes.close();
    await _microphone?.stop();
    await _room.disconnect();
    await _room.dispose();
  }
}
