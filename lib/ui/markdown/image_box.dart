import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/json/post_extras.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/tokens.dart';

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

/// An image written in a message, in a box reserved from its known size.
/// Images the server did not measure are not shown, as in Mattermost's apps.
class MessageImage extends StatelessWidget {
  const MessageImage({required this.image, required this.measured, super.key});

  final ImagePart image;
  final ImageSize? measured;

  @override
  Widget build(BuildContext context) {
    final measured = this.measured;
    if (measured == null) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final box = imageBox(
          measuredWidth: measured.width,
          measuredHeight: measured.height,
          width: image.width,
          height: image.height,
          maxWidth: constraints.maxWidth,
          maxHeight: MediaQuery.sizeOf(context).height * 0.45,
        );
        if (box == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
          child: ImageSlot(url: image.url, size: box),
        );
      },
    );
  }
}

/// [url] drawn into exactly [size]; a tonal box until it loads.
class ImageSlot extends StatelessWidget {
  const ImageSlot({required this.url, required this.size, super.key});

  final String url;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final env = PostEnvironment.maybeOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox.fromSize(
        size: size,
        child:
            env?.image?.call(url, size) ??
            ColoredBox(color: context.tokens.codeBackground),
      ),
    );
  }
}
