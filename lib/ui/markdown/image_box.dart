import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/json/post_extras.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/density.dart';
import 'package:matterleast/ui/hover_tint.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/tokens.dart';

/// The tallest an inline image may be: 45 % of the phone screen's longer
/// side, so a portrait picture takes the same room whichever way the phone
/// is held; 40 % of the window's height on desktop.
double imageMaxHeight(Size screen, {required bool desktop}) => desktop
    ? max(screen.height * _desktopHeightShare, _desktopFloor)
    : screen.longestSide * 0.45;

/// The widest an inline image may be, given the room the message leaves:
/// 60 % of it on desktop, never narrower than a small floor.
double imageMaxWidth(double available, {required bool desktop}) => desktop
    ? max(available * _desktopWidthShare, min(available, _desktopFloor))
    : available;

/// Pictures in a grid are smaller than a single one on desktop.
double gridMaxHeight(Size screen, {required bool desktop}) => desktop
    ? max(screen.height * _desktopGridShare, _desktopFloor * 0.75)
    : imageMaxHeight(screen, desktop: false);

const _desktopHeightShare = 0.4;
const _desktopWidthShare = 0.6;
const _desktopGridShare = 0.22;
const _desktopFloor = 160.0;

/// Pure: the 16:9 box of a video whose size is unknown, within [maxWidth] and
/// [maxHeight].
Size unmeasuredVideoBox(double maxWidth, double maxHeight) {
  final height = min(maxWidth * 9 / 16, maxHeight);
  return Size(height * 16 / 9, height);
}

/// Pure: the box an image takes before its bytes arrive. The size typed in
/// the message (`=WxH`) wins, a missing side follows the measured aspect
/// ratio, and the box shrinks to fit [maxWidth] × [maxHeight] keeping the
/// ratio. Null when nothing is known about the size.
Size? imageBox({
  required int? measuredWidth,
  required int? measuredHeight,
  int? width,
  int? height,
  required double maxWidth,
  required double maxHeight,
}) {
  final mw = measuredWidth ?? 0;
  final mh = measuredHeight ?? 0;
  double w;
  double h;
  if (width != null && height != null) {
    (w, h) = (width.toDouble(), height.toDouble());
  } else if (width != null && mw > 0 && mh > 0) {
    (w, h) = (width.toDouble(), width * mh / mw);
  } else if (height != null && mw > 0 && mh > 0) {
    (w, h) = (height * mw / mh, height.toDouble());
  } else if (mw > 0 && mh > 0) {
    (w, h) = (mw.toDouble(), mh.toDouble());
  } else {
    return null;
  }
  if (w <= 0 || h <= 0) return null;
  final scale = [
    1.0,
    maxWidth / w,
    maxHeight / h,
  ].reduce((a, b) => a < b ? a : b);
  return Size(w * scale, h * scale);
}

/// What a tap on an image in a message's text does: opens it in the
/// gallery with the message's other pictures. Read at tap time only, so a
/// new callback never rebuilds the message.
class MessageImageOpener extends InheritedWidget {
  const MessageImageOpener({
    required this.open,
    required super.child,
    super.key,
  });

  final ValueChanged<String> open;

  static ValueChanged<String>? of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<MessageImageOpener>()?.open;

  @override
  bool updateShouldNotify(MessageImageOpener oldWidget) => false;
}

/// An image written in a message, in a box reserved from its known size;
/// one the server did not measure gets a fixed box it fits into. An
/// address no image can come from shows its alt text.
class MessageImage extends StatelessWidget {
  const MessageImage({required this.image, required this.measured, super.key});

  final ImagePart image;
  final ImageSize? measured;

  static const unmeasured = Size(240, 160);

  @override
  Widget build(BuildContext context) {
    if (!canLoadImage(image.url)) {
      return image.alt.isEmpty ? const SizedBox.shrink() : Text(image.alt);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = imageMaxHeight(
          MediaQuery.sizeOf(context),
          desktop: isDesktop,
        );
        final maxWidth = imageMaxWidth(
          constraints.maxWidth,
          desktop: isDesktop,
        );
        final known = imageBox(
          measuredWidth: measured?.width,
          measuredHeight: measured?.height,
          width: image.width,
          height: image.height,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
        final box =
            known ??
            Size(
              unmeasured.width.clamp(0, constraints.maxWidth),
              unmeasured.height,
            );
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Semantics(
              button: true,
              label: image.alt.isEmpty ? 'Image' : image.alt,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => MessageImageOpener.of(context)?.call(image.url),
                child: HoverTint(
                  cursor: SystemMouseCursors.zoomIn,
                  child: ImageSlot(
                    url: image.url,
                    size: box,
                    fit: known == null ? BoxFit.contain : BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// [url] drawn into exactly [size]; a tonal box until it loads.
class ImageSlot extends StatelessWidget {
  const ImageSlot({
    required this.url,
    required this.size,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String url;
  final Size size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final env = PostEnvironment.maybeOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.density.radius),
      child: SizedBox.fromSize(
        size: size,
        child:
            env?.image?.call(url, size, fit) ??
            ColoredBox(color: context.tokens.codeBackground),
      ),
    );
  }
}
