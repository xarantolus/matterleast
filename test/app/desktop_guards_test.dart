import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/app/incoming_shares.dart';
import 'package:matterleast/app/shortcuts.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/notifications/notification_launch.dart';
import 'package:matterleast/notifications/stay_connected.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:quick_actions_platform_interface/quick_actions_platform_interface.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:workmanager/workmanager.dart';

class _FakeWorkmanager extends WorkmanagerPlatform
    with MockPlatformInterfaceMixin {
  final calls = <String>[];

  @override
  Future<void> initialize(
    Function callbackDispatcher, {
    bool isInDebugMode = false,
  }) async => calls.add('initialize');

  @override
  Future<void> registerPeriodicTask(
    String uniqueName,
    String taskName, {
    Duration? frequency,
    Duration? flexInterval,
    Map<String, dynamic>? inputData,
    Duration? initialDelay,
    Constraints? constraints,
    ExistingPeriodicWorkPolicy? existingWorkPolicy,
    BackoffPolicy? backoffPolicy,
    Duration? backoffPolicyDelay,
    String? tag,
    ForegroundServiceConfig? foregroundServiceConfig,
  }) async => calls.add('register $uniqueName');

  @override
  Future<void> cancelByUniqueName(String uniqueName) async =>
      calls.add('cancel $uniqueName');
}

class _FakeQuickActions extends QuickActionsPlatform
    with MockPlatformInterfaceMixin {
  final calls = <String>[];

  @override
  Future<void> initialize(QuickActionHandler handler) async =>
      calls.add('initialize');

  @override
  Future<void> setShortcutItems(List<ShortcutItem> items) async =>
      calls.add('show ${items.length}');
}

final _server = ServerEntry(
  url: 'https://chat.example.com',
  displayName: 'Example',
  siteName: null,
  serverVersion: null,
  diagnosticId: null,
  lastActiveAt: DateTime.utc(2026, 10, 27),
  ssoScheme: null,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeWorkmanager workmanager;
  late _FakeQuickActions quickActions;
  late List<String> stayConnected;

  setUp(() {
    // The first Workmanager() picks the host's implementation; the fake
    // replaces it afterwards.
    Workmanager();
    workmanager = _FakeWorkmanager();
    WorkmanagerPlatform.instance = workmanager;
    quickActions = _FakeQuickActions();
    QuickActionsPlatform.instance = quickActions;
    stayConnected = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('matterleast/stay_connected'),
          (call) async {
            stayConnected.add(call.method);
            return null;
          },
        );
    ReceiveSharingIntent.setMockValues(
      initialMedia: [
        SharedMediaFile(path: '/shared/photo.jpg', type: SharedMediaType.image),
      ],
      mediaStream: const Stream.empty(),
    );
  });

  tearDown(() => debugDefaultTargetPlatformOverride = null);

  Future<void> startUp() async {
    await followSignedIn([_server]);
    await followSignedIn([]);
    await StayConnected.resume();
    const shortcuts = LauncherShortcuts();
    await shortcuts.initialize((_) {});
    await shortcuts.show(const <SwitchItem>[]);
  }

  test('on the phone, the background check, the stay-connected service, '
      'shortcuts and shares all start', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await startUp();
    expect(workmanager.calls, contains('register notification-check'));
    expect(workmanager.calls, contains('cancel notification-check'));
    expect(stayConnected, containsAll(['disable', 'resume']));
    expect(quickActions.calls, ['initialize', 'show 0']);
    expect(await IncomingShares.initial(), hasLength(1));
  });

  for (final platform in [TargetPlatform.linux, TargetPlatform.windows]) {
    test('on ${platform.name}, nothing polls while the app is closed and no '
        'phone-only service starts', () async {
      debugDefaultTargetPlatformOverride = platform;
      await startUp();
      expect(workmanager.calls, isEmpty);
      expect(stayConnected, isEmpty);
      expect(await StayConnected.enabled(), isFalse);
      expect(quickActions.calls, isEmpty);
      expect(await IncomingShares.initial(), isEmpty);
      expect(await IncomingShares.later().isEmpty, isTrue);
    });
  }
}
