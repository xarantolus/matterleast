import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/post_details.dart';
import 'package:matterleast/markdown/links.dart';
import 'package:matterleast/ui/markdown/image_box.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/tokens.dart';

/// The server's OpenGraph preview of a link in the message.
class LinkPreviewCard extends StatelessWidget {
  const LinkPreviewCard({required this.preview, super.key});

  final LinkPreview preview;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final env = PostEnvironment.maybeOf(context);
    final imageUrl = preview.imageUrl;
    final size = preview.imageSize;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: Card.outlined(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: env == null || preview.url.isEmpty
              ? null
              : () => env.onLink(classifyLink(preview.url, env.server)),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (preview.siteName.isNotEmpty)
                  Text(preview.siteName.toUpperCase(), style: tokens.smallCaps),
                if (preview.title.isNotEmpty)
                  Text(
                    preview.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall?.copyWith(color: tokens.accent),
                  ),
                if (preview.description.isNotEmpty)
                  Text(
                    preview.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(color: tokens.muted),
                  ),
                if (imageUrl != null && size != null)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final box = imageBox(
                        measuredWidth: size.width,
                        measuredHeight: size.height,
                        maxWidth: constraints.maxWidth,
                        maxHeight: 200,
                      );
                      return box == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: Spacing.sm),
                              child: ImageSlot(url: imageUrl, size: box),
                            );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
