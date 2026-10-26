import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/notifications/notify_rules.dart';

/// One message line in a notification.
class NoticeMessage {
  const NoticeMessage({
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.at,
    this.avatar,
  });

  final String senderId;
  final String senderName;
  final String text;
  final DateTime at;

  /// The sender's picture as encoded image bytes, when it could be loaded.
  final Uint8List? avatar;
}

/// A conversation's notification: what it shows and where a tap leads.
class ConversationNotice {
  const ConversationNotice({
    required this.serverUrl,
    required this.key,
    required this.kind,
    required this.title,
    required this.group,
    required this.messages,
    required this.newestPostId,
    required this.newestAt,
    this.teamId,
    this.serverName,
  });

  final String serverUrl;
  final ConversationKey key;
  final NotifyKind kind;
  final String title;

  /// More than two people talk here (a channel or group message).
  final bool group;
  final List<NoticeMessage> messages;
  final String newestPostId;
  final DateTime newestAt;
  final String? teamId;

  /// Shown under the title when the user has more than one server.
  final String? serverName;
}

/// Where a notification leads, carried in its payload.
class NoticeTarget {
  const NoticeTarget({
    required this.serverUrl,
    required this.channelId,
    required this.postId,
    required this.newestAt,
    this.rootId = '',
    this.teamId = '',
  });

  final String serverUrl;
  final String channelId;
  final String rootId;
  final String postId;
  final String teamId;
  final DateTime newestAt;

  ConversationKey get key => ConversationKey(channelId, rootId);

  String encode() => jsonEncode({
    's': serverUrl,
    'c': channelId,
    'r': rootId,
    'p': postId,
    't': teamId,
    'n': newestAt.millisecondsSinceEpoch,
  });

  /// Our own payload; anything else is not ours and reads as null.
  static NoticeTarget? decode(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final json = jsonDecode(payload);
      if (json is! Map<String, Object?>) return null;
      final (s, c, r, p, t, n) = (
        json['s'],
        json['c'],
        json['r'],
        json['p'],
        json['t'],
        json['n'],
      );
      if (s is! String || c is! String || p is! String || n is! int) {
        return null;
      }
      return NoticeTarget(
        serverUrl: s,
        channelId: c,
        rootId: r is String ? r : '',
        postId: p,
        teamId: t is String ? t : '',
        newestAt: DateTime.fromMillisecondsSinceEpoch(n, isUtc: true),
      );
    } on FormatException {
      return null;
    }
  }
}

/// The fixed Android channels; the user tunes each in the system settings.
abstract final class NoticeChannels {
  static const direct = AndroidNotificationChannel(
    'direct',
    'Direct messages and mentions',
    description: 'Messages to you and messages that mention you',
    importance: Importance.high,
  );
  static const thread = AndroidNotificationChannel(
    'threads',
    'Thread replies',
    description: 'Replies in threads you follow',
    importance: Importance.high,
  );
  static const other = AndroidNotificationChannel(
    'other',
    'Other messages',
    description: 'Messages in channels set to notify about everything',
    importance: Importance.defaultImportance,
  );

  /// The same id the Kotlin service creates for its persistent notification.
  static const sync = AndroidNotificationChannel(
    'sync',
    'Sync',
    description: 'Shown while Matterleast stays connected in the background',
    importance: Importance.min,
    showBadge: false,
  );

  static AndroidNotificationChannel of(NotifyKind kind) => switch (kind) {
    NotifyKind.direct => direct,
    NotifyKind.thread => thread,
    NotifyKind.other => other,
  };
}

abstract final class NoticeActions {
  static const reply = 'reply';
  static const read = 'read';
}

/// Shows and removes message notifications. One instance per isolate;
/// [init] once before use.
class Notifier {
  Notifier([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  Future<void> init({
    DidReceiveNotificationResponseCallback? onTap,
    required DidReceiveBackgroundNotificationResponseCallback onAction,
  }) async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
      ),
      onDidReceiveNotificationResponse: onTap,
      onDidReceiveBackgroundNotificationResponse: onAction,
    );
    final android = _android;
    if (android == null) return;
    for (final channel in [
      NoticeChannels.direct,
      NoticeChannels.thread,
      NoticeChannels.other,
      NoticeChannels.sync,
    ]) {
      await android.createNotificationChannel(channel);
    }
  }

  /// The notification the app was opened from, if any.
  Future<NoticeTarget?> launchTarget() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (!(details?.didNotificationLaunchApp ?? false)) return null;
    return NoticeTarget.decode(details?.notificationResponse?.payload);
  }

  Future<bool> permitted() async =>
      await _android?.areNotificationsEnabled() ?? false;

  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? false;

  /// The system's notification settings for this app, where a refused
  /// permission and each channel can be changed.
  Future<void> openSettings() async => _android?.openAppNotificationSettings();

  static String tagOf(String serverUrl, ConversationKey key) =>
      '$serverUrl#$key';

  /// A stable id for [tag]; Android tells notifications apart by both.
  static int idOf(String tag) {
    var hash = 0x811c9dc5;
    for (final unit in tag.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }

  Future<void> show(ConversationNotice notice) async {
    final channel = NoticeChannels.of(notice.kind);
    final tag = tagOf(notice.serverUrl, notice.key);
    final target = NoticeTarget(
      serverUrl: notice.serverUrl,
      channelId: notice.key.channelId,
      rootId: notice.key.rootId,
      postId: notice.newestPostId,
      teamId: notice.teamId ?? '',
      newestAt: notice.newestAt,
    );
    final style = MessagingStyleInformation(
      const Person(name: 'You', key: 'me'),
      conversationTitle: notice.group ? notice.title : null,
      groupConversation: notice.group,
      messages: [
        for (final m in notice.messages)
          Message(
            m.text,
            m.at.toLocal(),
            Person(
              key: m.senderId,
              name: m.senderName,
              icon: m.avatar == null ? null : ByteArrayAndroidIcon(m.avatar!),
            ),
          ),
      ],
    );
    await _plugin.show(
      id: idOf(tag),
      title: notice.title,
      body: notice.messages.last.text,
      payload: target.encode(),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: notice.kind == NotifyKind.other
              ? Priority.defaultPriority
              : Priority.high,
          icon: 'ic_notification',
          tag: tag,
          category: AndroidNotificationCategory.message,
          visibility: NotificationVisibility.private,
          styleInformation: style,
          subText: notice.serverName,
          when: notice.newestAt.millisecondsSinceEpoch,
          showWhen: true,
          autoCancel: true,
          onlyAlertOnce: false,
          actions: const [
            AndroidNotificationAction(
              NoticeActions.reply,
              'Reply',
              inputs: [AndroidNotificationActionInput(label: 'Reply')],
              semanticAction: SemanticAction.reply,
              allowGeneratedReplies: true,
            ),
            AndroidNotificationAction(
              NoticeActions.read,
              'Mark as read',
              semanticAction: SemanticAction.markAsRead,
            ),
          ],
        ),
      ),
    );
  }

  /// Message notifications of [serverUrl] on screen now.
  Future<List<ShownConversation>> shown(String serverUrl) async {
    final List<ActiveNotification> active;
    try {
      active = await _plugin.getActiveNotifications();
    } on Object catch (e) {
      Log.warn('notify', 'Active notifications not readable', e);
      return const [];
    }
    return [
      for (final n in active)
        if (NoticeTarget.decode(n.payload) case final t?
            when t.serverUrl == serverUrl)
          ShownConversation(
            serverUrl: serverUrl,
            key: t.key,
            newestAt: t.newestAt,
          ),
    ];
  }

  Future<void> clear(String serverUrl, ConversationKey key) {
    final tag = tagOf(serverUrl, key);
    return _plugin.cancel(id: idOf(tag), tag: tag);
  }

  /// Removes the notification of the thread of [rootId], wherever it is.
  Future<void> clearThread(String serverUrl, String rootId) async {
    for (final s in await shown(serverUrl)) {
      if (s.key.rootId == rootId) await clear(serverUrl, s.key);
    }
  }

  Future<void> clearServer(String serverUrl) async {
    for (final s in await shown(serverUrl)) {
      await clear(serverUrl, s.key);
    }
  }
}
