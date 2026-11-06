import 'dart:typed_data';

import 'package:matterleast/notifications/notice_format.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notice_banner.g.dart';

/// What the banner shows: the text of the system notification, its sender's
/// picture, and where a tap leads. [id] tells a newer notice from the one
/// it replaced.
class BannerNotice {
  const BannerNotice({
    required this.id,
    required this.title,
    required this.body,
    required this.target,
    this.avatar,
  });

  factory BannerNotice.of(int id, ConversationNotice notice) {
    final newest = notice.messages.last;
    final text = toastText(
      title: notice.title,
      group: notice.group,
      sender: newest.senderName,
      text: newest.text,
      subText: noticeSubText(
        serverName: notice.serverName,
        teamName: notice.teamName,
      ),
    );
    return BannerNotice(
      id: id,
      title: text.title,
      body: text.body,
      target: notice.target,
      avatar: newest.avatar ?? notice.largeIcon,
    );
  }

  final int id;
  final String title;
  final String body;
  final NoticeTarget target;
  final Uint8List? avatar;
}

/// How long a banner shows.
@Riverpod(keepAlive: true)
Duration noticeBannerDuration(Ref ref) => const Duration(seconds: 5);

/// The one banner on screen, if any; a newer notice replaces it.
@Riverpod(keepAlive: true)
class NoticeBanners extends _$NoticeBanners {
  var _next = 0;

  @override
  BannerNotice? build() => null;

  void show(ConversationNotice notice) =>
      state = BannerNotice.of(_next++, notice);

  /// Hides the banner [id], unless a newer one took its place.
  void hide(int id) {
    if (state?.id == id) state = null;
  }
}
