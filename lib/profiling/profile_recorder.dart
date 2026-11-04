import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:ui' show FramePhase;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' show debugProfileBuildsEnabledUserWidgets;
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

/// Records the VM timeline and frame timings in profile builds only and
/// writes them as files to open in ui.perfetto.dev.
class ProfileRecorder {
  ProfileRecorder._();

  static final instance = ProfileRecorder._();
  static const _window = Duration(seconds: 60);

  final _frames = Queue<FrameTiming>();
  VmService? _service;

  /// Does nothing outside profile builds.
  static Future<void> start() async {
    if (!kProfileMode) return;
    SchedulerBinding.instance.addTimingsCallback(instance._onTimings);
    debugProfileBuildsEnabledUserWidgets = true;
    debugProfileLayoutsEnabled = true;
    debugProfilePaintsEnabled = true;
    try {
      final info = await developer.Service.controlWebServer(enable: true);
      final http = info.serverUri;
      final ws =
          info.serverWebSocketUri ??
          http?.replace(
            scheme: 'ws',
            path: '${http.path.endsWith('/') ? http.path : '${http.path}/'}ws',
          );
      if (ws == null) throw StateError('no VM service uri');
      final service = await vmServiceConnectUri(ws.toString());
      await service.setVMTimelineFlags(['Dart', 'Embedder', 'GC', 'API']);
      await service.clearVMTimeline();
      instance._service = service;
    } on Object catch (e) {
      debugPrint('Profile recorder: no timeline ($e)');
    }
  }

  void _onTimings(List<FrameTiming> timings) {
    _frames.addAll(timings);
    final newest = timings.last.timestampInMicroseconds(
      FramePhase.rasterFinish,
    );
    while (_frames.isNotEmpty &&
        newest - _frames.first.timestampInMicroseconds(FramePhase.vsyncStart) >
            _window.inMicroseconds) {
      _frames.removeFirst();
    }
  }

  Future<Directory> _outputDir() async {
    if (Platform.isAndroid) {
      return (await getExternalStorageDirectory()) ??
          await getApplicationDocumentsDirectory();
    }
    return (await getDownloadsDirectory()) ??
        Directory(Platform.environment['HOME'] ?? '.');
  }

  /// Writes the trace and the frame CSV; returns the files written.
  Future<List<File>> export() async {
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final dir = await _outputDir();
    final files = <File>[];
    final service = _service;
    if (service != null) {
      final timeline = await service.getVMTimeline();
      final trace = File('${dir.path}/matterleast-trace-$stamp.json');
      await trace.writeAsString(
        jsonEncode({
          'traceEvents': [
            for (final e in timeline.traceEvents ?? <TimelineEvent>[]) e.json,
          ],
        }),
      );
      files.add(trace);
    }
    final csv = File('${dir.path}/matterleast-frames-$stamp.csv');
    final rows = StringBuffer(
      'vsync_start_us,build_ms,raster_ms,total_ms,vsync_overhead_ms\n',
    );
    for (final f in _frames) {
      rows.writeln(
        '${f.timestampInMicroseconds(FramePhase.vsyncStart)},'
        '${_ms(f.buildDuration)},${_ms(f.rasterDuration)},'
        '${_ms(f.totalSpan)},${_ms(f.vsyncOverhead)}',
      );
    }
    await csv.writeAsString(rows.toString());
    files.add(csv);
    return files;
  }

  static String _ms(Duration d) => (d.inMicroseconds / 1000).toStringAsFixed(2);

  /// Saves the recording, says where, and on [share] opens the share sheet.
  Future<void> exportAndReport(
    BuildContext context, {
    required bool share,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final files = await export();
      messenger.showSnackBar(
        SnackBar(content: Text('Saved ${files.map((f) => f.path).join('\n')}')),
      );
      if (share) {
        await SharePlus.instance.share(
          ShareParams(files: [for (final f in files) XFile(f.path)]),
        );
      }
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}

/// A long press on the title saves and shares the recording (Android profile).
class ProfileLongPress extends StatelessWidget {
  const ProfileLongPress({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kProfileMode || !Platform.isAndroid) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => unawaited(
        ProfileRecorder.instance.exportAndReport(context, share: true),
      ),
      child: child,
    );
  }
}
