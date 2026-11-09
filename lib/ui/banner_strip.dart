import 'package:material_ui/material_ui.dart';
import 'package:matterleast/screens/channel/message_environment.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/motion.dart';
import 'package:matterleast/ui/sheet_header.dart';
import 'package:matterleast/ui/tokens.dart';

/// A banner of one line in [background] and [foreground]: the text without
/// its formatting, cut at the end. A tap calls [onTap].
class BannerStrip extends StatelessWidget {
  const BannerStrip({
    required this.text,
    required this.background,
    required this.foreground,
    required this.tooltip,
    required this.onTap,
    this.icon = Icons.info_outline,
    this.onDismiss,
    super.key,
  });

  final String text;
  final Color background;
  final Color foreground;
  final String tooltip;
  final VoidCallback onTap;
  final IconData icon;

  /// Shows a close button when set.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium!
        .copyWith(color: foreground);
    return Material(
      color: background,
      child: Row(
        children: [
          Expanded(
            child: Tooltip(
              message: tooltip,
              child: InkWell(
                onTap: onTap,
                mouseCursor: clickCursor,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: Spacing.md,
                    right: onDismiss == null ? Spacing.md : 0,
                    top: Spacing.sm,
                    bottom: Spacing.sm,
                  ),
                  child: Row(
                    spacing: Spacing.sm,
                    children: [
                      Icon(icon, size: 20, color: foreground),
                      Expanded(
                        child: Text(
                          text,
                          style: style,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              tooltip: 'Dismiss',
              icon: const Icon(Icons.close),
              iconSize: 20,
              color: foreground,
              visualDensity: VisualDensity.compact,
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}

/// Grows and shrinks as a banner comes and goes, and takes no room while
/// there is none.
class BannerSlot extends StatelessWidget {
  const BannerSlot({required this.child, super.key});

  final Widget? child;

  @override
  Widget build(BuildContext context) => AnimatedSize(
    alignment: Alignment.topCenter,
    duration: motion(context, const Duration(milliseconds: 200)),
    child: SizedBox(width: double.infinity, child: child),
  );
}

/// The whole of [text] as formatted text, in a sheet (a popout on
/// desktop); [onDismiss] adds a Dismiss button.
Future<void> showBannerSheet(
  BuildContext context, {
  required String title,
  required String url,
  required String teamId,
  required String text,
  VoidCallback? onDismiss,
}) => showAppSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (sheet) => ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(sheet).height * 0.6,
    ),
    child: SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetHeader(title),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: MessageEnvironment(
                url: url,
                teamId: teamId,
                child: PostBody(
                  postId: '$title:$url:${text.hashCode}',
                  message: text,
                  collapsible: false,
                ),
              ),
            ),
          ),
          if (onDismiss != null)
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () {
                    onDismiss();
                    Navigator.of(sheet).pop();
                  },
                  child: const Text('Dismiss'),
                ),
              ),
            ),
        ],
      ),
    ),
  ),
);

/// The text of a banner without its formatting, for its one line.
String bannerLine(BuildContext context, String id, String text) =>
    spokenMessage(
      context,
      postId: id,
      message: text,
    ).text.replaceAll(RegExp(r'\s*\n\s*'), ' ');
