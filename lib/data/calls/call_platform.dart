import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/log.dart';
import 'package:permission_handler/permission_handler.dart';

/// What the phone does for a call besides the media itself: the microphone
/// permission, the foreground service, the audio session and its routes.
abstract interface class CallPlatform {
  /// Asks for the microphone; false when the user said no.
  Future<bool> requestMicrophone();

  /// Keeps the call alive in the background, with a Hang up action.
  Future<void> startService({required String title, required String text});
  Future<void> stopService();

  /// The user pressed Hang up on the notification.
  Stream<void> get hangUps;

  /// Prepares the audio session for a voice call.
  Future<void> prepareAudio();

  /// The routes the phone offers now, and again when they change.
  Future<List<AudioRoute>> routes();
  Stream<void> get routesChanged;
  Future<void> setRoute(AudioRoute route);

  /// The microphones and speakers a desktop offers; nothing on a phone,
  /// which has routes instead.
  Future<AudioDevices> devices();
  Future<void> selectDevice({required bool input, required String id});
}

/// [CallPlatform] on the phone.
class PhoneCallPlatform implements CallPlatform {
  PhoneCallPlatform() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'hangUp') _hangUps.add(null);
    });
  }

  void _watchDevices() {
    navigator.mediaDevices.ondevicechange = (_) => _routesChanged.add(null);
  }

  static const _channel = MethodChannel('matterleast/call_service');
  final _hangUps = StreamController<void>.broadcast();
  late final _routesChanged = StreamController<void>.broadcast(
    onListen: _watchDevices,
  );

  @override
  Stream<void> get hangUps => _hangUps.stream;

  @override
  Stream<void> get routesChanged => _routesChanged.stream;

  @override
  Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    if (hasAndroidServices) {
      // Headsets need it on Android 12 and later; a refusal only hides them.
      await Permission.bluetoothConnect.request();
    }
    return status.isGranted;
  }

  @override
  Future<void> startService({
    required String title,
    required String text,
  }) async {
    if (!hasAndroidServices) return;
    await _channel.invokeMethod<void>('start', {'title': title, 'text': text});
  }

  @override
  Future<void> stopService() async {
    if (!hasAndroidServices) return;
    await _channel.invokeMethod<void>('stop');
  }

  @override
  Future<void> prepareAudio() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    await Helper.setAppleAudioConfiguration(
      AppleAudioConfiguration(
        appleAudioCategory: AppleAudioCategory.playAndRecord,
        appleAudioCategoryOptions: {
          AppleAudioCategoryOption.allowBluetooth,
          AppleAudioCategoryOption.allowBluetoothA2DP,
          AppleAudioCategoryOption.duckOthers,
        },
        appleAudioMode: AppleAudioMode.voiceChat,
      ),
    );
  }

  @override
  Future<List<AudioRoute>> routes() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const [AudioRoute.earpiece, AudioRoute.speaker];
    }
    try {
      final devices = await navigator.mediaDevices.enumerateDevices();
      return [
        for (final d in devices)
          if (d.kind == 'audiooutput')
            ?switch (d.deviceId) {
              'earpiece' => AudioRoute.earpiece,
              'speaker' => AudioRoute.speaker,
              'bluetooth' => AudioRoute.bluetooth,
              'wired-headset' => AudioRoute.wired,
              _ => null,
            },
      ];
    } on Object catch (e) {
      Log.warn('calls', 'Listing the audio routes failed', e);
      return const [];
    }
  }

  @override
  Future<void> setRoute(AudioRoute route) async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await Helper.setSpeakerphoneOn(route == AudioRoute.speaker);
        return;
      }
      await Helper.selectAudioOutput(switch (route) {
        AudioRoute.earpiece => 'earpiece',
        AudioRoute.speaker => 'speaker',
        AudioRoute.bluetooth => 'bluetooth',
        AudioRoute.wired => 'wired-headset',
      });
    } on Object catch (e) {
      Log.warn('calls', 'Switching the audio route failed', e);
    }
  }

  @override
  Future<AudioDevices> devices() async => noDevices;

  @override
  Future<void> selectDevice({required bool input, required String id}) async {}
}

/// Lists the audio devices the platform offers now.
typedef DeviceLister = Future<AudioDevices> Function();

/// Selects a device by the id the lister gave.
typedef DeviceSelector = Future<void> Function({
  required bool input,
  required String id,
});

/// [CallPlatform] on the desktop: no permission, no service and no routes,
/// but a choice of microphone and speaker. The platform gives no change
/// events, so the list is polled while a call listens.
class DesktopCallPlatform implements CallPlatform {
  DesktopCallPlatform({
    DeviceLister? lister,
    DeviceSelector? selector,
    this.pollEvery = const Duration(seconds: 3),
  }) : _lister = lister ?? _listDevices,
       _selector = selector ?? _selectDevice;

  final DeviceLister _lister;
  final DeviceSelector _selector;
  final Duration pollEvery;

  Timer? _timer;
  var _polling = false;
  AudioDevices _last = noDevices;

  late final _changes = StreamController<void>.broadcast(
    onListen: () =>
        _timer = Timer.periodic(pollEvery, (_) => unawaited(_poll())),
    onCancel: () {
      _timer?.cancel();
      _timer = null;
    },
  );

  Future<void> _poll() async {
    if (_polling) return;
    _polling = true;
    try {
      final now = await _lister();
      if (!listEquals(now.inputs, _last.inputs) ||
          !listEquals(now.outputs, _last.outputs)) {
        _last = now;
        if (!_changes.isClosed) _changes.add(null);
      }
    } on Object catch (e) {
      Log.warn('calls', 'Listing the audio devices failed', e);
    } finally {
      _polling = false;
    }
  }

  @override
  Stream<void> get routesChanged => _changes.stream;

  @override
  Stream<void> get hangUps => const Stream.empty();

  @override
  Future<bool> requestMicrophone() async => true;

  @override
  Future<void> startService({
    required String title,
    required String text,
  }) async {}

  @override
  Future<void> stopService() async {}

  @override
  Future<void> prepareAudio() async {}

  @override
  Future<List<AudioRoute>> routes() async => const [];

  @override
  Future<void> setRoute(AudioRoute route) async {}

  @override
  Future<AudioDevices> devices() async {
    try {
      final now = await _lister();
      _last = now;
      return now;
    } on Object catch (e) {
      Log.warn('calls', 'Listing the audio devices failed', e);
      return noDevices;
    }
  }

  @override
  Future<void> selectDevice({required bool input, required String id}) async {
    try {
      await _selector(input: input, id: id);
    } on Object catch (e) {
      Log.warn('calls', 'Selecting the audio device failed', e);
    }
  }

  static Future<AudioDevices> _listDevices() async {
    final all = await navigator.mediaDevices.enumerateDevices();
    AudioDevice device(MediaDeviceInfo d) => (id: d.deviceId, label: d.label);
    return (
      inputs: [
        for (final d in all)
          if (d.kind == 'audioinput') device(d),
      ],
      outputs: [
        for (final d in all)
          if (d.kind == 'audiooutput') device(d),
      ],
    );
  }

  static Future<void> _selectDevice({
    required bool input,
    required String id,
  }) => input ? Helper.selectAudioInput(id) : Helper.selectAudioOutput(id);
}
