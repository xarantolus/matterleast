import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/notifications/notice_format.dart';
import 'package:matterleast/notifications/notify_rules.dart';

part 'notifier.g.dart';

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
    this.teamName,
    this.largeIcon,
    this.sound = true,
  });

  final String serverUrl;
  final ConversationKey key;
  final NotifyKind kind;
  final String title;

  /// Each message shows under its sender, below [title] (a channel, group
  /// message or thread); otherwise [title] is the sender.
  final bool group;

  /// Oldest first.
  final List<NoticeMessage> messages;
  final String newestPostId;
  final DateTime newestAt;
  final String? teamId;

  /// Shown next to the app name when the user has more than one server.
  final String? serverName;

  /// Shown next to the app name when the user is in more than one team.
  final String? teamName;

  /// The other person's picture, for a direct message.
  final Uint8List? largeIcon;

  /// Whether a desktop notification plays the system's message sound.
  final bool sound;
}

/// Where a notification leads, carried in its payload.
@JsonSerializable(checked: true, includeIfNull: false)
class NoticeTarget {
  const NoticeTarget({
    required this.serverUrl,
    required this.channelId,
    required this.postId,
    required this.newestAt,
    this.rootId = '',
    this.teamId = '',
    this.action,
  });

  factory NoticeTarget.fromJson(Map<String, Object?> json) =>
      _$NoticeTargetFromJson(json);

  @JsonKey(name: 's')
  final String serverUrl;
  @JsonKey(name: 'c')
  final String channelId;
  @JsonKey(name: 'r')
  final String rootId;
  @JsonKey(name: 'p')
  final String postId;
  @JsonKey(name: 't')
  final String teamId;
  @JsonKey(name: 'n', fromJson: _fromMillis, toJson: _toMillis)
  final DateTime newestAt;

  /// Set on a Windows toast button, which hands back only its own payload.
  @JsonKey(name: 'a')
  final String? action;

  ConversationKey get key => ConversationKey(channelId, rootId);

  NoticeTarget withAction(String action) => NoticeTarget(
    serverUrl: serverUrl,
    channelId: channelId,
    rootId: rootId,
    postId: postId,
    teamId: teamId,
    newestAt: newestAt,
    action: action,
  );

  Map<String, Object?> toJson() => _$NoticeTargetToJson(this);

  String encode() => jsonEncode(toJson());

  /// Our own payload; anything else reads as null.
  static NoticeTarget? decode(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final json = jsonDecode(payload);
      return json is Map<String, Object?> ? NoticeTarget.fromJson(json) : null;
    } on FormatException {
      return null;
    } on CheckedFromJsonException {
      return null;
    }
  }
}

DateTime _fromMillis(int millis) =>
    DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);

int _toMillis(DateTime time) => time.millisecondsSinceEpoch;

/// The fixed Android channels; the user tunes each in the system settings.
/// The message channels start at one importance: Android orders by
/// importance before time, which would put a new channel message below
/// older direct messages.
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
    'other_messages',
    'Other messages',
    description: 'Messages in channels set to notify about everything',
    importance: Importance.high,
  );

  /// Created at default importance before; Android keeps a channel's
  /// importance, so it went for [other].
  static const _replaced = ['other'];

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

enum NoticeActionKind { reply, read }

typedef NoticeAction = ({
  NoticeActionKind kind,
  NoticeTarget target,
  String text,
});

/// Null for a tap on the notification itself or a payload that isn't ours.
NoticeAction? noticeActionOf(NotificationResponse response) {
  final target = NoticeTarget.decode(response.payload);
  if (target == null) return null;
  // A Windows button's payload names the action and its text box is in
  // `data`; Android and Linux name the action beside the payload.
  final windows = target.action != null;
  final kind = switch (target.action ?? response.actionId) {
    NoticeActions.reply => NoticeActionKind.reply,
    NoticeActions.read => NoticeActionKind.read,
    _ => null,
  };
  if (kind == null) return null;
  final text = switch (windows
      ? response.data[NoticeActions.reply]
      : response.input) {
    final String text => text.trim(),
    _ => '',
  };
  return (kind: kind, target: target, text: text);
}

/// Shows and removes message notifications. One instance per isolate;
/// [init] once before use.
class Notifier {
  Notifier([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /// Desktop: the toasts shown by this process, by tag.
  final _shownHere = <String, ShownConversation>{};

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  Future<void> init({
    DidReceiveNotificationResponseCallback? onTap,
    required DidReceiveBackgroundNotificationResponseCallback onAction,
  }) async {
    await _plugin.initialize(
      settings: initializationSettings,
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
    for (final id in NoticeChannels._replaced) {
      await android.deleteNotificationChannel(channelId: id);
    }
  }

  /// Every platform the app runs on; the plugin refuses to start on one
  /// without its settings.
  static final initializationSettings = InitializationSettings(
    android: const AndroidInitializationSettings('ic_notification'),
    linux: LinuxInitializationSettings(
      defaultActionName: 'Open',
      defaultIcon: AssetsLinuxIcon(appIconAsset),
    ),
    windows: const WindowsInitializationSettings(
      appName: 'Matterleast',
      appUserModelId: 'io.github.xarantolus.matterleast',
      guid: 'd220ee6f-3493-4113-9ba0-46177298cccf',
    ),
  );

  Future<NotificationResponse?> launchResponse() async {
    final NotificationAppLaunchDetails? details;
    try {
      details = await _plugin.getNotificationAppLaunchDetails();
    } on UnimplementedError {
      // Linux: a notification never launches the app there.
      return null;
    }
    if (!(details?.didNotificationLaunchApp ?? false)) return null;
    return details?.notificationResponse;
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
    final target = NoticeTarget(
      serverUrl: notice.serverUrl,
      channelId: notice.key.channelId,
      rootId: notice.key.rootId,
      postId: notice.newestPostId,
      teamId: notice.teamId ?? '',
      newestAt: notice.newestAt,
    );
    final tag = tagOf(notice.serverUrl, notice.key);
    if (isDesktop) {
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
      _shownHere[tag] = ShownConversation(
        serverUrl: notice.serverUrl,
        key: notice.key,
        newestAt: notice.newestAt,
      );
      await _plugin.show(
        id: idOf(tag),
        title: text.title,
        // Linux notification servers read the body as markup.
        body: defaultTargetPlatform == TargetPlatform.linux
            ? const HtmlEscape(HtmlEscapeMode.element).convert(text.body)
            : text.body,
        payload: target.encode(),
        notificationDetails: desktopDetailsOf(target, sound: notice.sound),
      );
      return;
    }
    await _plugin.show(
      id: idOf(tag),
      title: notice.title,
      body: notice.messages.last.text,
      payload: target.encode(),
      notificationDetails: NotificationDetails(
        android: detailsOf(notice, now: DateTime.now().toUtc()),
      ),
    );
  }

  /// Most Linux notification servers have no text field: no Reply there.
  static NotificationDetails desktopDetailsOf(
    NoticeTarget target, {
    bool sound = true,
  }) => NotificationDetails(
    linux: LinuxNotificationDetails(
      category: LinuxNotificationCategory.imReceived,
      sound: sound ? ThemeLinuxSound('message-new-instant') : null,
      suppressSound: !sound,
      actions: const [
        LinuxNotificationAction(key: NoticeActions.read, label: 'Mark as read'),
      ],
    ),
    windows: WindowsNotificationDetails(
      audio: sound
          ? WindowsNotificationAudio.preset(sound: WindowsNotificationSound.im)
          : WindowsNotificationAudio.silent(),
      inputs: const [
        WindowsTextInput(id: NoticeActions.reply, placeHolderContent: 'Reply'),
      ],
      actions: [
        WindowsAction(
          content: 'Reply',
          arguments: target.withAction(NoticeActions.reply).encode(),
          inputId: NoticeActions.reply,
        ),
        WindowsAction(
          content: 'Mark as read',
          arguments: target.withAction(NoticeActions.read).encode(),
        ),
      ],
    ),
  );

  /// How Android shows [notice]: a conversation in the messaging style,
  /// dated by its newest message.
  static AndroidNotificationDetails detailsOf(
    ConversationNotice notice, {
    required DateTime now,
  }) {
    final channel = NoticeChannels.of(notice.kind);
    final largeIcon = notice.largeIcon;
    return AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: Priority.high,
      icon: 'ic_notification',
      largeIcon: notice.group || largeIcon == null
          ? null
          : ByteArrayAndroidBitmap(largeIcon),
      tag: tagOf(notice.serverUrl, notice.key),
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.private,
      styleInformation: MessagingStyleInformation(
        const Person(name: 'You', key: 'me'),
        conversationTitle: notice.group ? notice.title : null,
        groupConversation: notice.group,
        messages: [
          for (final m in notice.messages)
            Message(
              m.text,
              m.at,
              Person(
                key: m.senderId,
                name: m.senderName,
                icon: switch (m.avatar) {
                  final avatar? => ByteArrayAndroidIcon(avatar),
                  null => null,
                },
              ),
            ),
        ],
      ),
      subText: noticeSubText(
        serverName: notice.serverName,
        teamName: notice.teamName,
      ),
      when: noticeWhen(notice.newestAt, now).millisecondsSinceEpoch,
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
    );
  }

  /// Message notifications of [serverUrl] on screen now. Desktops can't
  /// list them (Linux has no call for it, Windows only for packaged apps),
  /// so there it is what this process showed and didn't clear.
  Future<List<ShownConversation>> shown(String serverUrl) async {
    if (isDesktop) {
      return [
        for (final s in _shownHere.values)
          if (s.serverUrl == serverUrl) s,
      ];
    }
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

  /// Withdraws the notification of [key]. An unpackaged Windows app can't:
  /// its toasts stay in the Action Center until the user dismisses them.
  Future<void> clear(String serverUrl, ConversationKey key) {
    final tag = tagOf(serverUrl, key);
    _shownHere.remove(tag);
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
