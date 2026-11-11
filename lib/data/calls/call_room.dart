import 'package:matterleast/domain/call_livekit_rules.dart';

/// A person in the room, by LiveKit identity, as the room reports them.
typedef RoomMember = ({String identity, bool muted, int raisedAt});

/// What the media room tells the call.
sealed class RoomNote {
  const RoomNote();
}

/// We are in the room; [members] are everyone in it, us included.
final class RoomEntered extends RoomNote {
  const RoomEntered(this.members);
  final List<RoomMember> members;
}

final class RoomReconnecting extends RoomNote {
  const RoomReconnecting();
}

final class RoomReconnected extends RoomNote {
  const RoomReconnected();
}

/// The room let us go and will not take us back.
final class RoomClosed extends RoomNote {
  const RoomClosed(this.why);
  final RoomLeft why;
}

final class MemberEntered extends RoomNote {
  const MemberEntered(this.member);
  final RoomMember member;
}

final class MemberLeft extends RoomNote {
  const MemberLeft(this.identity);
  final String identity;
}

final class MemberMuted extends RoomNote {
  const MemberMuted(this.identity, {required this.muted});
  final String identity;
  final bool muted;
}

/// [raisedAt] is 0 once the hand is down.
final class MemberHand extends RoomNote {
  const MemberHand(this.identity, this.raisedAt);
  final String identity;
  final int raisedAt;
}

/// Everyone speaking now.
final class RoomSpeakers extends RoomNote {
  const RoomSpeakers(this.identities);
  final Set<String> identities;
}

final class MemberReacted extends RoomNote {
  const MemberReacted(this.identity, this.emoji);
  final String identity;
  final String emoji;
}

final class RoomHost extends RoomNote {
  const RoomHost(this.hostId);
  final String hostId;
}

/// The media room of a LiveKit call. Behind an interface so the call logic
/// runs without LiveKit.
abstract interface class CallRoom {
  Stream<RoomNote> get notes;

  /// Joins the room; completes once we are in, and throws when we can't.
  Future<void> connect(String url, String token);

  /// Opens the microphone, muted, and puts it in the room. False when it
  /// can't be opened.
  Future<bool> openMicrophone();

  Future<void> setMuted({required bool muted});

  /// [raisedAt] in milliseconds; 0 lowers the hand.
  Future<void> setHand(int raisedAt);

  Future<void> react(String name, String character, int timestamp);

  Future<void> close();
}
