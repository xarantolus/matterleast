import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/tokens.dart';

/// The address of the link under the mouse; null while none is.
typedef LinkHover = ValueNotifier<String?>;

/// Shows the address of a hovered link at the bottom left of [child], as a
/// browser's status line does. Links report to it through [maybeOf].
class LinkStatus extends StatefulWidget {
  const LinkStatus({required this.child, super.key});

  final Widget child;

  /// Where a link reports that the mouse entered (its address) or left
  /// (null); null where no status line shows.
  static LinkHover? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_LinkHoverScope>()?.hover;

  @override
  State<LinkStatus> createState() => _LinkStatusState();
}

class _LinkStatusState extends State<LinkStatus> {
  final _hover = LinkHover(null);

  @override
  void dispose() {
    _hover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _LinkHoverScope(
    hover: _hover,
    child: Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          bottom: 0,
          child: IgnorePointer(
            child: ValueListenableBuilder(
              valueListenable: _hover,
              builder: (context, address, _) =>
                  address == null ? const SizedBox.shrink() : _Address(address),
            ),
          ),
        ),
      ],
    ),
  );
}

class _LinkHoverScope extends InheritedWidget {
  const _LinkHoverScope({required this.hover, required super.child});

  final LinkHover hover;

  @override
  bool updateShouldNotify(_LinkHoverScope old) => hover != old.hover;
}

class _Address extends StatelessWidget {
  const _Address(this.address);

  final String address;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.6,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
            right: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          borderRadius: const BorderRadius.only(topRight: Radius.circular(6)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: 2,
          ),
          child: Text(
            address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
