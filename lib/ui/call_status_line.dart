import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/call_providers.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/domain/call_presentation.dart';

/// One line about the call: how the connection is and, once connected, how
/// long the call has run. Only this line ticks.
class CallStatusLine extends ConsumerStatefulWidget {
  const CallStatusLine({
    required this.state,
    this.style,
    this.maxLines = 1,
    super.key,
  });

  final CallConnection state;
  final TextStyle? style;
  final int maxLines;

  @override
  ConsumerState<CallStatusLine> createState() => _CallStatusLineState();
}

class _CallStatusLineState extends ConsumerState<CallStatusLine> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _follow();
  }

  @override
  void didUpdateWidget(CallStatusLine old) {
    super.didUpdateWidget(old);
    _follow();
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _follow() {
    if (widget.state.phase == CallPhase.connected) {
      _tick ??= Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() {}),
      );
    } else {
      _tick?.cancel();
      _tick = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final startAt = ref
        .watch(callInChannelProvider(state.url, state.channelId))
        ?.startAt;
    final running = state.phase == CallPhase.connected && startAt != null;
    final text = callConnectionText(state);
    return Text(
      running
          ? '$text · ${callTimerLabel(callElapsed(startAt, clock.now()))}'
          : text,
      maxLines: widget.maxLines,
      overflow: TextOverflow.ellipsis,
      style: widget.style,
    );
  }
}
