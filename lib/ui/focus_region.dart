import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/ui/app_sheet.dart';

/// Where the focus lands when F6 moves into a region.
enum RegionEntry {
  /// Its first focusable widget.
  first,

  /// Its text field.
  textField,

  /// The region itself, outlined, as for a list read with the keyboard.
  self,
}

/// A part of the window (rail, channel list, conversation, composer) that
/// F6 and Shift+F6 move the focus between, in reading order. Tab stays
/// within it. Only on desktop.
class FocusRegion extends StatefulWidget {
  const FocusRegion({
    required this.child,
    this.entry = RegionEntry.first,
    super.key,
  });

  final Widget child;
  final RegionEntry entry;

  static final _live = <_FocusRegionState>{};

  /// Moves the focus into the next region of the page on top, or the
  /// previous one, from the region that has it.
  static void move({required bool forward}) {
    final shown = [
      for (final region in _live)
        if (region.mounted &&
            (ModalRoute.of(region.context)?.isCurrent ?? true))
          if (globalRectOf(region.context) case final rect? when !rect.isEmpty)
            (region: region, rect: rect),
    ];
    if (shown.isEmpty) return;
    shown.sort(
      (a, b) => a.rect.left.round() != b.rect.left.round()
          ? a.rect.left.compareTo(b.rect.left)
          : a.rect.top.compareTo(b.rect.top),
    );
    final at = shown.indexWhere((s) => s.region._node.hasFocus);
    final count = shown.length;
    final next = at < 0
        ? (forward ? 0 : count - 1)
        : (at + (forward ? 1 : -1)) % count;
    shown[next].region._enter();
  }

  @override
  State<FocusRegion> createState() => _FocusRegionState();
}

class _FocusRegionState extends State<FocusRegion> {
  final _node = FocusNode(debugLabel: 'Region', skipTraversal: true);
  var _outlined = false;

  @override
  void initState() {
    super.initState();
    FocusRegion._live.add(this);
    _node.addListener(_focusChanged);
  }

  @override
  void dispose() {
    FocusRegion._live.remove(this);
    _node.dispose();
    super.dispose();
  }

  void _focusChanged() {
    final outlined = _node.hasPrimaryFocus;
    if (outlined != _outlined) setState(() => _outlined = outlined);
  }

  void _enter() {
    // In reading order; the tree keeps them in the order they appeared.
    final inside =
        _node.traversalDescendants
            .where((n) => n.canRequestFocus && !n.skipTraversal)
            .toList()
          ..sort(
            (a, b) => a.rect.top != b.rect.top
                ? a.rect.top.compareTo(b.rect.top)
                : a.rect.left.compareTo(b.rect.left),
          );
    bool isField(FocusNode n) =>
        n.context?.findAncestorWidgetOfExactType<EditableText>() != null;
    final target = switch (widget.entry) {
      RegionEntry.self => null,
      RegionEntry.textField =>
        inside.where(isField).firstOrNull ?? inside.firstOrNull,
      RegionEntry.first => inside.firstOrNull,
    };
    (target ?? _node).requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) return widget.child;
    return Focus(
      focusNode: _node,
      child: FocusTraversalGroup(
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: _outlined
              ? BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                )
              : const BoxDecoration(),
          child: widget.child,
        ),
      ),
    );
  }
}
