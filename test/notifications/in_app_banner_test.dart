import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Notifier;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/desktop/desktop_shell.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/notifications/in_app_notifications.dart';
import 'package:matterleast/notifications/notice_banner.dart';
import 'package:matterleast/notifications/notification_check.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:matterleast/notifications/notify_rules.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/ui/notice_banner_layer.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

class _Rail extends RailSelection {
  @override
  RailTarget? build() => null;

  @override
  void select(RailTarget? target) => state = target;
}

/// Records what reaches the system instead of showing it.
class _Toasts extends Notifier {
  final shownNotices = <ConversationNotice>[];

  @override
  Future<void> show(ConversationNotice notice) async =>
      shownNotices.add(notice);

  @override
  Future<List<ShownConversation>> shown(String serverUrl) async => const [];
}

const _directId = 'dm000000000000000000000d01';
const _patId = 'pt000000000000000000000p01';
final _earlier = DateTime.utc(2026, 10, 25, 10);
final _later = _earlier.add(const Duration(minutes: 5));

void main() {
  late ServerHarness harness;
  late ProviderContainer container;
  late _Toasts toasts;

  Future<void> start(WidgetTester tester, {TargetPlatform? platform}) async {
    toasts = _Toasts();
    harness = await pumpWithServer(
      tester,
      platform: platform,
      trackRoutes: true,
      handle: (r) => r.path.contains('/users/')
          ? ok(<Object?>[])
          : ok(<String, Object?>{}),
      home: (_) =>
          const NoticeBannerOverlay(child: Scaffold(body: SizedBox.expand())),
      overrides: (url) => [
        railSelectionProvider.overrideWith(_Rail.new),
        serversProvider.overrideWith((ref) {
          ref.keepAlive();
          return Stream.value([
            ServerEntry(
              url: url,
              displayName: 'Test',
              siteName: null,
              serverVersion: null,
              diagnosticId: null,
              lastActiveAt: DateTime(2026),
              ssoScheme: null,
            ),
          ]);
        }),
        switchItemsProvider(url).overrideWith((ref) {
          ref.keepAlive();
          return Stream.value([
            SwitchItem(
              serverUrl: url,
              kind: SwitchKind.channel,
              id: channelId,
              title: 'Boats',
              teamId: teamId,
            ),
            SwitchItem(
              serverUrl: url,
              kind: SwitchKind.direct,
              id: _directId,
              title: 'Pat',
              teamId: '',
            ),
          ]);
        }),
      ],
    );
    container = ProviderScope.containerOf(
      tester.element(find.byType(NoticeBannerOverlay)),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    DesktopShell.windowFocused = true;
    await tester.runAsync(() async {
      final db = harness.session.db;
      await db.setSyncText(SyncKeys.currentUserId, meId);
      await db.setSyncInt(
        NotifyKeys.cursorKey,
        _earlier.millisecondsSinceEpoch,
      );
      await harness.session.store.applyUsers([
        api.User.fromJson({
          'id': _patId,
          'username': 'pat',
          'roles': 'system_user',
        }),
      ]);
      await harness.session.store.applyChannels(
        channels: [
          api.Channel.fromJson({
            'id': _directId,
            'type': 'D',
            'name': '${_patId}__$meId',
            'display_name': '',
          }),
        ],
        members: [
          api.ChannelMember.fromJson({
            'channel_id': _directId,
            'user_id': meId,
          }),
        ],
      );
    });
  }

  Future<void> open(WidgetTester tester, String channel, String title) async {
    unawaited(
      openConversation(
        tester.state<NavigatorState>(find.byType(Navigator).first),
        url: harness.url,
        channelId: channel,
        title: title,
        teamId: channel == channelId ? teamId : null,
      ),
    );
    await harness.settle(tester);
  }

  /// A message from Pat arrives in [channel], which the check looks at.
  Future<void> arrives(WidgetTester tester, String channel, String text) async {
    await tester.runAsync(
      () => harness.session.store.applyLivePost(
        api.Post.fromJson({
          'id': 'new${text.hashCode}',
          'channel_id': channel,
          'user_id': _patId,
          'create_at': _later.millisecondsSinceEpoch,
          'message': text,
        }),
        fromSelf: false,
        mentionsMe: false,
      ),
    );
    // On the test's clock, as the app's own lookups of people are.
    final checked = inAppCheck(
      harness.session,
      toasts,
      route: container.read(noticeRouterProvider),
      banner: container.read(noticeBannersProvider.notifier).show,
    ).run(refresh: false, fetch: false);
    await harness.settle(tester);
    await checked;
  }

  Finder banner(String text) => find.descendant(
    of: find.byType(NoticeBanner),
    matching: find.textContaining(text),
  );

  testWidgets('a direct message while another conversation is open shows a '
      'banner, which hides after its time', (tester) async {
    await start(tester);
    await open(tester, channelId, 'Boats');
    await arrives(tester, _directId, 'see you at the dock');
    await tester.pump(const Duration(milliseconds: 200));
    expect(banner('see you at the dock'), findsOneWidget);
    expect(toasts.shownNotices, isEmpty);
    await tester.pump(const Duration(seconds: 4));
    expect(banner('see you at the dock'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 200));
    expect(banner('see you at the dock'), findsNothing);
    await harness.close(tester);
  });

  testWidgets('tapping the banner opens the conversation, and Back returns '
      'to the one that was open', (tester) async {
    await start(tester);
    await open(tester, channelId, 'Boats');
    await arrives(tester, _directId, 'see you at the dock');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(banner('see you at the dock'));
    await harness.settle(tester);
    expect(banner('see you at the dock'), findsNothing);
    ChannelScreen top() =>
        tester.widget<ChannelScreen>(find.byType(ChannelScreen).last);
    expect(top().channelId, _directId);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await harness.settle(tester);
    expect(find.byType(ChannelScreen), findsOneWidget);
    expect(top().channelId, channelId);
    await harness.close(tester);
  });

  testWidgets('with recents or the shade over the app a phone notifies '
      'instead of showing a banner', (tester) async {
    await start(tester);
    await open(tester, channelId, 'Boats');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await arrives(tester, _directId, 'see you at the dock');
    await tester.pump(const Duration(milliseconds: 200));
    expect(banner('see you at the dock'), findsNothing);
    expect(toasts.shownNotices, hasLength(1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await harness.close(tester);
  });

  testWidgets('a message in the conversation on screen shows no banner', (
    tester,
  ) async {
    await start(tester);
    await open(tester, _directId, 'Pat');
    await arrives(tester, _directId, 'see you at the dock');
    await tester.pump(const Duration(milliseconds: 200));
    expect(banner('see you at the dock'), findsNothing);
    expect(toasts.shownNotices, isEmpty);
    await harness.close(tester);
  });

  testWidgets('hovering the banner on a desktop holds it, leaving lets it '
      'run on', (tester) async {
    await start(tester, platform: TargetPlatform.linux);
    await open(tester, channelId, 'Boats');
    await arrives(tester, _directId, 'see you at the dock');
    await tester.pump(const Duration(milliseconds: 200));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(banner('see you at the dock')));
    await tester.pump(const Duration(seconds: 20));
    expect(banner('see you at the dock'), findsOneWidget);
    await mouse.moveTo(Offset.zero);
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 200));
    expect(banner('see you at the dock'), findsNothing);
    await mouse.removePointer();
    await harness.close(tester);
  });

  testWidgets('with the window not in front a desktop toasts instead', (
    tester,
  ) async {
    await start(tester, platform: TargetPlatform.linux);
    await open(tester, channelId, 'Boats');
    DesktopShell.windowFocused = false;
    await arrives(tester, _directId, 'see you at the dock');
    await tester.pump(const Duration(milliseconds: 200));
    expect(banner('see you at the dock'), findsNothing);
    expect(toasts.shownNotices, hasLength(1));
    DesktopShell.windowFocused = true;
    await harness.close(tester);
  });

  testWidgets('a phone that is not in front shows nothing', (tester) async {
    await start(tester);
    await open(tester, channelId, 'Boats');
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await arrives(tester, _directId, 'see you at the dock');
    await tester.pump(const Duration(milliseconds: 200));
    expect(banner('see you at the dock'), findsNothing);
    expect(toasts.shownNotices, isEmpty);
    for (final state in [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await harness.close(tester);
  });
}
