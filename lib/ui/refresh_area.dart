import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';

/// Pull to refresh, which F5 and Ctrl+R also start on desktop while the
/// page it is on is the one on top.
class RefreshArea extends StatefulWidget {
  const RefreshArea({required this.onRefresh, required this.child, super.key});

  final RefreshCallback onRefresh;
  final Widget child;

  @override
  State<RefreshArea> createState() => _RefreshAreaState();
}

class _RefreshAreaState extends State<RefreshArea> {
  final _indicator = GlobalKey<RefreshIndicatorState>();

  /// Shown areas, the newest last; a key press refreshes the newest one on
  /// the page on top.
  static final _shown = <_RefreshAreaState>[];

  @override
  void initState() {
    super.initState();
    if (!isDesktop) return;
    if (_shown.isEmpty) HardwareKeyboard.instance.addHandler(_onKey);
    _shown.add(this);
  }

  @override
  void dispose() {
    if (_shown.remove(this) && _shown.isEmpty) {
      HardwareKeyboard.instance.removeHandler(_onKey);
    }
    super.dispose();
  }

  static bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || !_isRefreshKey(event.logicalKey)) {
      return false;
    }
    final target = _shown.reversed
        .where((a) => ModalRoute.isCurrentOf(a.context) ?? true)
        .firstOrNull;
    if (target == null) return false;
    target._indicator.currentState?.show().ignore();
    return true;
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    key: _indicator,
    onRefresh: widget.onRefresh,
    child: widget.child,
  );
}

/// F5, or Ctrl+R as in browsers.
bool _isRefreshKey(LogicalKeyboardKey key) =>
    key == LogicalKeyboardKey.f5 ||
    (key == LogicalKeyboardKey.keyR &&
        HardwareKeyboard.instance.isControlPressed);
