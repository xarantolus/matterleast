import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// How a conversation's notification is headed, the way the official app
/// does it: a direct message by its sender alone; a group message or a
/// channel by its name, with each message under its sender; a reply in a
/// collapsed thread by the conversation it is in.
({String title, bool group}) noticeHeading({
  required String channelType,
  required String name,
  required bool thread,
}) => switch ((channelType, thread)) {
  ('D', true) => (title: 'Reply in Direct Message', group: true),
  (_, true) => (title: 'Reply in $name', group: true),
  ('D', false) => (title: name, group: false),
  _ => (title: name, group: true),
};

/// The line next to the app name: the server when there are several, and
/// the team of a channel when the user is in several.
String? noticeSubText({String? serverName, String? teamName}) {
  final parts = [
    if (serverName case final s? when s.isNotEmpty) s,
    if (teamName case final t? when t.isNotEmpty) t,
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

/// The time a notification is dated and ranked by: its newest message, but
/// never later than [now]. Android ranks a notification dated in the future
/// (a server clock ahead of the phone's) by when it was first posted, so an
/// updated conversation would keep its old place.
DateTime noticeWhen(DateTime newestAt, DateTime now) =>
    newestAt.isAfter(now) ? now : newestAt;

/// A profile picture as a round PNG of [size] pixels, as notifications
/// show people; null when [bytes] is not an image.
Uint8List? roundAvatar(Uint8List bytes, {int size = 144}) {
  final img.Image? decoded;
  try {
    decoded = img.decodeImage(bytes);
  } on Object {
    return null;
  }
  if (decoded == null) return null;
  final side = decoded.width < decoded.height ? decoded.width : decoded.height;
  final square = img.copyCrop(
    decoded,
    x: (decoded.width - side) ~/ 2,
    y: (decoded.height - side) ~/ 2,
    width: side,
    height: side,
  );
  final scaled = img.copyResize(
    square.numChannels == 4 ? square : square.convert(numChannels: 4),
    width: size,
    height: size,
    interpolation: img.Interpolation.average,
  );
  return img.encodePng(img.copyCropCircle(scaled), singleFrame: true);
}
